// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/system_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _fullscreen = false;

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _fullscreen ? null : AppBar(
        title: const Text('Camera Control'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded),
            onPressed: () => setState(() => _fullscreen = true),
          ),
        ],
      ),
      body: _fullscreen
          ? _FullscreenView(
              sys: sys,
              onExit: () => setState(() => _fullscreen = false),
            )
          : _NormalView(sys: sys),
    );
  }
}

// ── Normal layout ─────────────────────────────────────────
class _NormalView extends StatelessWidget {
  final SystemProvider sys;
  const _NormalView({required this.sys});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed card
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1A0D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded,
                        size: 40, color: Colors.white.withOpacity(0.25)),
                      const SizedBox(height: 8),
                      Text('Live Stream Feed',
                        style: GoogleFonts.nunito(
                          color: Colors.white38, fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text('${sys.esp32StreamUrl}/stream',
                        style: GoogleFonts.nunito(
                          color: Colors.white24, fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status pill
                Positioned(top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record,
                          size: 7, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('LIVE',
                          style: GoogleFonts.nunito(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pan-Tilt section
          Text('Pan & Tilt Control',
            style: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _PtzPanel(sys: sys),

          const SizedBox(height: 20),

          // Sprinkler section
          Text('Sprinkler',
            style: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _SprinklerPanel(sys: sys),

          const SizedBox(height: 20),

          // Snapshot
          Text('Snapshot',
            style: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Snapshot captured!',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Capture Snapshot'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PTZ Panel ─────────────────────────────────────────────
class _PtzPanel extends StatelessWidget {
  final SystemProvider sys;
  const _PtzPanel({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          // D-pad
          SizedBox(
            width: 130,
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [_PtzButton(icon: Icons.keyboard_arrow_up_rounded, onTap: sys.tiltUp)]),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PtzButton(icon: Icons.keyboard_arrow_left_rounded,  onTap: sys.panLeft),
                    const SizedBox(width: 6),
                    _PtzButton(icon: Icons.gps_fixed_rounded, onTap: sys.resetCamera, accent: true),
                    const SizedBox(width: 6),
                    _PtzButton(icon: Icons.keyboard_arrow_right_rounded, onTap: sys.panRight),
                  ],
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [_PtzButton(icon: Icons.keyboard_arrow_down_rounded, onTap: sys.tiltDown)]),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Angles
          Expanded(
            child: Column(
              children: [
                _AngleSlider(
                  label: 'Pan',
                  icon: Icons.swap_horiz_rounded,
                  value: sys.panAngle,
                  onChanged: sys.setPan,
                ),
                const SizedBox(height: 12),
                _AngleSlider(
                  label: 'Tilt',
                  icon: Icons.swap_vert_rounded,
                  value: sys.tiltAngle,
                  onChanged: sys.setTilt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PtzButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         accent;
  const _PtzButton({required this.icon, required this.onTap, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: accent
              ? AppColors.primaryGreen.withOpacity(0.1)
              : AppColors.creamDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accent ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Icon(icon,
          size: 22,
          color: accent ? AppColors.primaryGreen : AppColors.textSecondary),
      ),
    );
  }
}

class _AngleSlider extends StatelessWidget {
  final String   label;
  final IconData icon;
  final double   value;
  final void Function(double) onChanged;
  const _AngleSlider({
    required this.label, required this.icon,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          child: Text('$label',
            style: GoogleFonts.nunito(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   AppColors.primaryGreen,
              inactiveTrackColor: AppColors.border,
              thumbColor:         AppColors.primaryGreen,
              overlayColor:       AppColors.primaryGreen.withOpacity(0.1),
              trackHeight:        3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: 0, max: 180,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text('${value.round()}°',
            style: GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Sprinkler Panel ───────────────────────────────────────
class _SprinklerPanel extends StatelessWidget {
  final SystemProvider sys;
  const _SprinklerPanel({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: sys.sprinklerActive
                  ? AppColors.sprinklerBlue.withOpacity(0.1)
                  : AppColors.creamDark,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.water_drop_rounded,
              color: sys.sprinklerActive
                  ? AppColors.sprinklerBlue
                  : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sys.sprinklerActive ? 'Sprinkler running…' : 'Sprinkler ready',
                  style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text('Duration: ${sys.sprinklerDuration}s',
                  style: GoogleFonts.nunito(
                    fontSize: 11, color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: sys.sprinklerActive
                ? sys.deactivateSprinkler
                : sys.activateSprinkler,
            style: ElevatedButton.styleFrom(
              backgroundColor: sys.sprinklerActive
                  ? AppColors.alertRed
                  : AppColors.sprinklerBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: Text(sys.sprinklerActive ? 'Stop' : 'Activate'),
          ),
        ],
      ),
    );
  }
}

// ── Fullscreen view ───────────────────────────────────────
class _FullscreenView extends StatelessWidget {
  final SystemProvider sys;
  final VoidCallback   onExit;
  const _FullscreenView({required this.sys, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded,
                    size: 56, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 10),
                  Text('Full Screen Live View',
                    style: GoogleFonts.nunito(
                      color: Colors.white38, fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(top: 12, right: 12,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit_rounded,
                  color: Colors.white70, size: 28),
                onPressed: onExit,
              ),
            ),
            Positioned(bottom: 20, right: 20,
              child: FloatingActionButton.small(
                backgroundColor: AppColors.sprinklerBlue,
                onPressed: sys.activateSprinkler,
                child: const Icon(Icons.water_drop_rounded,
                  color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
