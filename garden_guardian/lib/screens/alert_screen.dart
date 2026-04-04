// lib/screens/alert_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/system_provider.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  bool _sprinklerJustActivated = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _activateSprinkler(SystemProvider sys) {
    sys.activateSprinkler();
    setState(() => _sprinklerJustActivated = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sprinklerJustActivated = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.water_drop_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text('Sprinkler activated for ${sys.sprinklerDuration}s!',
              style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.sprinklerBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _ignoreAlert(SystemProvider sys) {
    sys.dismissAlert();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      body: SafeArea(
        child: Column(
          children: [
            // ── Alert Header ──────────────────────────
            _AlertHeader(pulse: _pulseAnim),

            // ── Live Feed ─────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Video feed placeholder
                  _LiveFeedView(),

                  // Bounding box overlay
                  const _BoundingBoxOverlay(),

                  // Sprinkler active overlay
                  if (sys.sprinklerActive)
                    const _SprinklerActiveOverlay(),
                ],
              ),
            ),

            // ── PTZ Controls ──────────────────────────
            Container(
              color: const Color(0xFF1A0000),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _PanTiltControls(sys: sys),
            ),

            // ── Action Buttons ────────────────────────
            Container(
              color: const Color(0xFF1A0000),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ActionButtons(
                sys: sys,
                sprinklerJustActivated: _sprinklerJustActivated,
                onIgnore:    () => _ignoreAlert(sys),
                onSprinkler: () => _activateSprinkler(sys),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alert Header ──────────────────────────────────────────
class _AlertHeader extends StatelessWidget {
  final Animation<double> pulse;
  const _AlertHeader({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        color: Color.lerp(
          AppColors.alertRed,
          const Color(0xFFFF1A1A),
          pulse.value,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back
            GestureDetector(
              onTap: () => context.go('/home'),
              child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            // Pulsing dot
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('LIVE VIEW — ALERT!',
                style: GoogleFonts.nunito(
                  color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Record indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('REC',
                style: GoogleFonts.nunito(
                  color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live Feed ─────────────────────────────────────────────
class _LiveFeedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual MJPEG stream from ESP32:
    // Image.network('${sys.esp32StreamUrl}/stream', ...)
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1A0D),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_outdoor_rounded,
              size: 48, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 10),
            Text('ESP32-CAM MJPEG Stream',
              style: GoogleFonts.nunito(
                color: Colors.white38, fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text('Connecting to camera...',
              style: GoogleFonts.nunito(
                color: Colors.white24, fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );

    // When connected, use this instead:
    // return Image.network(
    //   '${sys.esp32StreamUrl}/stream',
    //   fit: BoxFit.cover,
    //   loadingBuilder: (ctx, child, progress) =>
    //       progress == null ? child : const Center(child: CircularProgressIndicator()),
    // );
  }
}

// ── Bounding Box Overlay ──────────────────────────────────
class _BoundingBoxOverlay extends StatelessWidget {
  const _BoundingBoxOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoundingBoxPainter(),
      child: Container(),
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Simulated bounding box position (replace with ML inference coords)
    final rect = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.45,
    );

    final boxPaint = Paint()
      ..color = AppColors.alertRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Corner markers instead of full box (cleaner look)
    const len = 22.0;
    final corners = [
      [Offset(rect.left, rect.top + len),   Offset(rect.left, rect.top),   Offset(rect.left + len, rect.top)],
      [Offset(rect.right - len, rect.top),  Offset(rect.right, rect.top),  Offset(rect.right, rect.top + len)],
      [Offset(rect.right, rect.bottom - len),Offset(rect.right, rect.bottom),Offset(rect.right - len, rect.bottom)],
      [Offset(rect.left + len, rect.bottom),Offset(rect.left, rect.bottom), Offset(rect.left, rect.bottom - len)],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, boxPaint);
    }

    // Label
    final bg = Paint()..color = AppColors.alertRed;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(rect.left, rect.top - 22, 90, 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(labelRect, bg);

    final tp = TextPainter(
      text: const TextSpan(
        text: '🐱 Cat  82%',
        style: TextStyle(color: Colors.white, fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 5, rect.top - 18));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Sprinkler Active Overlay ──────────────────────────────
class _SprinklerActiveOverlay extends StatelessWidget {
  const _SprinklerActiveOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sprinklerBlue.withOpacity(0.15),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.sprinklerBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop_rounded,
                color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Sprinkler Active!',
                style: GoogleFonts.nunito(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pan-Tilt Controls ─────────────────────────────────────
class _PanTiltControls extends StatelessWidget {
  final SystemProvider sys;
  const _PanTiltControls({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Camera Control',
              style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: sys.resetCamera,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Reset',
                  style: GoogleFonts.nunito(
                    color: Colors.white60, fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Arrow pad
            SizedBox(
              width: 140,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_PtzBtn(icon: Icons.keyboard_arrow_up_rounded,   onTap: sys.tiltUp)],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PtzBtn(icon: Icons.keyboard_arrow_left_rounded,  onTap: sys.panLeft),
                      const SizedBox(width: 8),
                      _PtzBtn(icon: Icons.adjust_rounded, onTap: sys.resetCamera, small: true),
                      const SizedBox(width: 8),
                      _PtzBtn(icon: Icons.keyboard_arrow_right_rounded, onTap: sys.panRight),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_PtzBtn(icon: Icons.keyboard_arrow_down_rounded,  onTap: sys.tiltDown)],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            // Angle display
            Column(
              children: [
                _AnglePill(label: 'Pan',  value: sys.panAngle.round()),
                const SizedBox(height: 8),
                _AnglePill(label: 'Tilt', value: sys.tiltAngle.round()),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PtzBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool small;
  const _PtzBtn({required this.icon, required this.onTap, this.small = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: small ? 32 : 40,
        height: small ? 32 : 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Icon(icon,
          color: Colors.white, size: small ? 16 : 22),
      ),
    );
  }
}

class _AnglePill extends StatelessWidget {
  final String label;
  final int    value;
  const _AnglePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ',
            style: GoogleFonts.nunito(
              color: Colors.white54, fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text('$value°',
            style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final SystemProvider sys;
  final bool           sprinklerJustActivated;
  final VoidCallback   onIgnore;
  final VoidCallback   onSprinkler;

  const _ActionButtons({
    required this.sys,
    required this.sprinklerJustActivated,
    required this.onIgnore,
    required this.onSprinkler,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ignore button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onIgnore,
            icon: const Icon(Icons.block_rounded, size: 18),
            label: const Text('Ignore Alert'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: const BorderSide(color: Colors.white30, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sprinkler button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: sys.sprinklerActive ? null : onSprinkler,
            icon: Icon(
              sys.sprinklerActive
                  ? Icons.water_rounded
                  : Icons.water_drop_rounded,
              size: 20,
            ),
            label: Text(
              sys.sprinklerActive ? '💦 Running...' : 'ACTIVATE SPRINKLER',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: sys.sprinklerActive
                  ? AppColors.sprinklerBlueLight
                  : AppColors.sprinklerBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.sprinklerBlueLight,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
