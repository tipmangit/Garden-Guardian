// lib/providers/system_provider.dart  (UPDATED)
// Key change: detectionEnabled is now separate from systemArmed.
// Detection must be ON before the sprinkler can be activated (two-step flow).
import 'package:flutter/foundation.dart';

enum SystemStatus { armed, disarmed, alerting }

class CatEvent {
  final String    id;
  final DateTime  timestamp;
  final String    imageUrl;
  final EventType type;
  final bool      isKnownCat;
  final double    confidence;

  const CatEvent({
    required this.id,
    required this.timestamp,
    required this.imageUrl,
    required this.type,
    this.isKnownCat  = false,
    this.confidence  = 0,
  });
}

enum EventType { detected, ignored, sprinklerActivated }

class SystemProvider extends ChangeNotifier {
  // ── System State ──────────────────────────────────────
  SystemStatus _status = SystemStatus.armed;

  // Step 1 — Detection toggle (user must turn this on first)
  bool _detectionEnabled = false;

  // Step 2 — Sprinkler (only activatable when detection is on)
  bool _sprinklerActive  = false;

  // Settings
  bool   _notificationsEnabled = true;
  bool   _autoSprinkler        = false;
  int    _sprinklerDuration    = 5;
  double _detectionSensitivity = 0.75;

  // Hardware
  String _esp32StreamUrl = 'http://192.168.1.100';

  // Camera angles
  double _panAngle  = 90;
  double _tiltAngle = 90;

  // Event log
  final List<CatEvent> _events = _sampleEvents();

  // ── Getters ───────────────────────────────────────────
  SystemStatus   get status               => _status;
  bool           get detectionEnabled     => _detectionEnabled;
  bool           get sprinklerActive      => _sprinklerActive;
  bool           get notificationsEnabled => _notificationsEnabled;
  bool           get autoSprinkler        => _autoSprinkler;
  int            get sprinklerDuration    => _sprinklerDuration;
  double         get detectionSensitivity => _detectionSensitivity;
  String         get esp32StreamUrl       => _esp32StreamUrl;
  double         get panAngle             => _panAngle;
  double         get tiltAngle            => _tiltAngle;
  List<CatEvent> get events               => List.unmodifiable(_events);

  bool get isAlerting  => _status == SystemStatus.alerting;
  bool get isArmed     => _status != SystemStatus.disarmed;

  // Sprinkler can only be activated if detection is ON
  bool get canActivateSprinkler => _detectionEnabled;

  int get todayEventCount => _events.where((e) {
    final now = DateTime.now();
    return e.timestamp.day   == now.day   &&
           e.timestamp.month == now.month &&
           e.timestamp.year  == now.year;
  }).length;

  int get totalDetectedCount =>
      _events.where((e) => e.type == EventType.detected).length;

  // ── Actions ───────────────────────────────────────────

  // STEP 1: Toggle detection
  void setDetectionEnabled(bool v) {
    _detectionEnabled = v;
    // If turning detection off, also stop sprinkler and clear alert
    if (!v) {
      _sprinklerActive = false;
      if (_status == SystemStatus.alerting) {
        _status = SystemStatus.armed;
      }
    }
    notifyListeners();

    // TODO: Call ESP32 endpoint
    // v ? Esp32Service().enableDetection() : Esp32Service().disableDetection();
  }

  void setStatus(SystemStatus s) { _status = s; notifyListeners(); }

  // Called by cat detection model when a cat is found
  void triggerAlert({double confidence = 0.85}) {
    if (!_detectionEnabled) return; // Guard: detection must be on

    _status = SystemStatus.alerting;
    notifyListeners();

    // Add event to log
    _events.insert(0, CatEvent(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp:  DateTime.now(),
      imageUrl:   '',
      type:       EventType.detected,
      confidence: confidence,
    ));

    // Auto-sprinkler (if enabled in settings)
    if (_autoSprinkler) {
      activateSprinkler();
    }
  }

  void dismissAlert() {
    if (isAlerting) {
      _events.insert(0, CatEvent(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        imageUrl:  '',
        type:      EventType.ignored,
      ));
    }
    _status = SystemStatus.armed;
    notifyListeners();
  }

  // STEP 2: Sprinkler (guarded by detectionEnabled)
  void activateSprinkler() {
    if (!_detectionEnabled) {
      // Can't activate sprinkler without detection being on
      return;
    }

    _sprinklerActive = true;
    notifyListeners();

    // Log event
    _events.insert(0, CatEvent(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      imageUrl:  '',
      type:      EventType.sprinklerActivated,
    ));

    // Auto-shutoff
    Future.delayed(Duration(seconds: _sprinklerDuration), () {
      _sprinklerActive = false;
      notifyListeners();
    });

    // TODO: Call ESP32 HTTP endpoint
    // Esp32Service().activateSprinkler(duration: _sprinklerDuration);
  }

  void deactivateSprinkler() {
    _sprinklerActive = false;
    notifyListeners();
    // TODO: Esp32Service().deactivateSprinkler();
  }

  // Settings
  void setNotificationsEnabled(bool v) { _notificationsEnabled = v; notifyListeners(); }
  void setAutoSprinkler(bool v)        { _autoSprinkler = v; notifyListeners(); }
  void setSprinklerDuration(int v)     { _sprinklerDuration = v; notifyListeners(); }
  void setDetectionSensitivity(double v) { _detectionSensitivity = v; notifyListeners(); }
  void setEsp32Url(String url)         { _esp32StreamUrl = url; notifyListeners(); }

  // Camera
  void setPan(double angle) {
    _panAngle = angle.clamp(0, 180);
    notifyListeners();
    // TODO: Esp32Service().setPan(_panAngle.round());
  }
  void setTilt(double angle) {
    _tiltAngle = angle.clamp(0, 180);
    notifyListeners();
    // TODO: Esp32Service().setTilt(_tiltAngle.round());
  }
  void panLeft()    => setPan(_panAngle   - 15);
  void panRight()   => setPan(_panAngle   + 15);
  void tiltUp()     => setTilt(_tiltAngle + 15);
  void tiltDown()   => setTilt(_tiltAngle - 15);
  void resetCamera(){ _panAngle = 90; _tiltAngle = 90; notifyListeners(); }

  // ── Sample Data ───────────────────────────────────────
  static List<CatEvent> _sampleEvents() {
    final now = DateTime.now();
    return [
      CatEvent(id: '1', timestamp: now.subtract(const Duration(minutes: 12)),
          imageUrl: '', type: EventType.detected, confidence: 0.91),
      CatEvent(id: '2', timestamp: now.subtract(const Duration(hours: 1)),
          imageUrl: '', type: EventType.sprinklerActivated),
      CatEvent(id: '3', timestamp: now.subtract(const Duration(hours: 3)),
          imageUrl: '', type: EventType.ignored, isKnownCat: true),
      CatEvent(id: '4', timestamp: now.subtract(const Duration(hours: 5)),
          imageUrl: '', type: EventType.detected, confidence: 0.78),
      CatEvent(id: '5', timestamp: now.subtract(const Duration(days: 1)),
          imageUrl: '', type: EventType.sprinklerActivated),
    ];
  }
}
