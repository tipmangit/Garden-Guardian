// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _shieldCtrl;
  late AnimationController _pawCtrl;
  late AnimationController _textCtrl;
  late AnimationController _dotCtrl;

  late Animation<double> _shieldScale;
  late Animation<double> _shieldOpacity;
  late Animation<double> _pawScale;
  late Animation<double> _pawOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();

    // Shield pop-in
    _shieldCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _shieldScale   = CurvedAnimation(parent: _shieldCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _shieldOpacity = CurvedAnimation(parent: _shieldCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // Paw bounce
    _pawCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pawScale   = CurvedAnimation(parent: _pawCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _pawOpacity = CurvedAnimation(parent: _pawCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // Text fade + slide
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    // Loading dots
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _dotOpacity = CurvedAnimation(parent: _dotCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.3, end: 1.0));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _shieldCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _pawCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _shieldCtrl.dispose();
    _pawCtrl.dispose();
    _textCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // ── Decorative background circles ──────────────
          Positioned(top: -60, right: -60,
            child: _DecorCircle(size: 220, color: AppColors.primaryGreen.withOpacity(0.06))),
          Positioned(bottom: -80, left: -50,
            child: _DecorCircle(size: 260, color: AppColors.soilBrown.withOpacity(0.05))),
          Positioned(top: 100, left: -30,
            child: _DecorCircle(size: 120, color: AppColors.leafGreen.withOpacity(0.07))),

          // ── Small floating paw prints ──────────────────
          Positioned(top: 120, right: 60,
            child: FadeTransition(opacity: _textOpacity,
              child: const Text('🐾', style: TextStyle(fontSize: 18, color: Colors.transparent)))),

          // ── Main content ──────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _shieldCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _shieldOpacity.value,
                    child: Transform.scale(
                      scale: _shieldScale.value,
                      child: _LogoBadge(pawAnimation: _pawCtrl),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        Text(
                          'Garden Guardian',
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Smart Feline Detection System',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                FadeTransition(
                  opacity: _textOpacity,
                  child: _LoadingDots(controller: _dotCtrl),
                ),
              ],
            ),
          ),

          // ── Version tag ───────────────────────────────
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Text(
                'v1.0.0  ·  Garden Guardian',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 11, color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo badge (shield + paw) ─────────────────────────────
class _LogoBadge extends StatelessWidget {
  final AnimationController pawAnimation;
  const _LogoBadge({required this.pawAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 28,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield icon
          Icon(Icons.security_rounded, size: 56, color: Colors.white.withOpacity(0.2)),
          // Paw
          ScaleTransition(
            scale: Animation<double>.fromValueListenable(
              ValueNotifier(pawAnimation.value),
            ),
            child: AnimatedBuilder(
              animation: pawAnimation,
              builder: (_, __) => Opacity(
                opacity: pawAnimation.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: Tween(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(
                          parent: pawAnimation, curve: Curves.elasticOut))
                      .value,
                  child: const Text('🐾',
                      style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final v = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.3 + 0.7 * v),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
