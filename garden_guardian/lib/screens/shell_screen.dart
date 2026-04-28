// lib/screens/shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/system_provider.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/camera'))        return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/settings'))      return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home');          break;
      case 1: context.go('/camera');        break;
      case 2: context.go('/notifications'); break;
      case 3: context.go('/settings');      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemProvider>();
    final idx = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.8),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => _onTap(context, i),
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor:    AppColors.primaryGreen,
          unselectedItemColor:  AppColors.textTertiary,
          selectedLabelStyle:   const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon:  Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon:  Icon(Icons.videocam_rounded),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded),
                  if (sys.isAlerting)
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 9, height: 9,
                        decoration: const BoxDecoration(
                          color:  AppColors.alertRed,
                          shape:  BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Events',
            ),
            const BottomNavigationBarItem(
              icon:  Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
