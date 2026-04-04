// lib/screens/home_screen.dart  (UPDATED — Two-Step Flow)
// Step 1: User activates Detection
// Step 2: Cat is detected → Alert shown → User confirms → Sprinkler offered
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/system_provider.dart';
import '../widgets/event_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned:   false,
            backgroundColor: AppColors.primaryGreen,
            toolbarHeight: 60,
            titleSpacing: 20,
            title: Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Garden Guardian',
                  style: GoogleFonts.nunito(
                    fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                    onPressed: () => context.go('/notifications'),
                  ),
                  if (sys.isAlerting)
                    Positioned(top: 8, right: 8,
                      child: Container(width: 10, height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.alertRedLight, shape: BoxShape.circle))),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                onPressed: () => context.go('/settings'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Main Control Card (Two-Step) ──────
                  _TwoStepControlCard(sys: sys),
                  const SizedBox(height: 16),

                  // ── Stats Row ─────────────────────────
                  _StatsRow(sys: sys),
                  const SizedBox(height: 20),

                  // ── Latest Snapshot ───────────────────
                  _SectionHeader(
                    title: 'Latest Snapshot',
                    trailing: TextButton(
                      onPressed: () => context.go('/camera'),
                      child: const Text('Live View →'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SnapshotCard(),
                  const SizedBox(height: 20),

                  // ── Recent Events ─────────────────────
                  _SectionHeader(
                    title: 'Recent Events',
                    trailing: TextButton(
                      onPressed: () => context.go('/notifications'),
                      child: const Text('See all →'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i >= sys.events.take(4).length) return null;
                  final event = sys.events[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EventTile(
                      event: event,
                      onTap: () => context.go('/event/${event.id}'),
                    ),
                  );
                },
                childCount: sys.events.take(4).length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TWO-STEP CONTROL CARD
//  Step 1 → Toggle Detection ON/OFF
//  Step 2 → (only visible after detection ON + cat found) → Activate Sprinkler
// ─────────────────────────────────────────────────────────
class _TwoStepControlCard extends StatelessWidget {
  final SystemProvider sys;
  const _TwoStepControlCard({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Step 1: Detection ─────────────────────────
        _StepCard(
          stepNumber: '1',
          stepLabel:  'Start Detection',
          isActive:   sys.detectionEnabled,
          isComplete: sys.detectionEnabled,
          child: _DetectionToggleContent(sys: sys),
        ),

        // Connector line
        _StepConnector(unlocked: sys.detectionEnabled),

        // ── Step 2: Sprinkler (locked until detection ON + cat found) ──
        _StepCard(
          stepNumber:  '2',
          stepLabel:   'Water Pump',
          isActive:    sys.isAlerting || sys.sprinklerActive,
          isComplete:  sys.sprinklerActive,
          locked:      !sys.detectionEnabled,
          lockedMsg:   'Enable detection first',
          child: _SprinklerStepContent(sys: sys),
        ),
      ],
    );
  }
}

// ── Step Card wrapper ─────────────────────────────────────
class _StepCard extends StatelessWidget {
  final String  stepNumber;
  final String  stepLabel;
  final bool    isActive;
  final bool    isComplete;
  final bool    locked;
  final String  lockedMsg;
  final Widget  child;

  const _StepCard({
    required this.stepNumber,
    required this.stepLabel,
    required this.isActive,
    required this.isComplete,
    this.locked    = false,
    this.lockedMsg = '',
    required this.child,
  });

  Color get _borderColor {
    if (locked)     return AppColors.border;
    if (isActive)   return AppColors.primaryGreen;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.creamDark.withOpacity(0.5)
            : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: locked ? 0.8 : 1.5),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Step badge
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: locked
                        ? AppColors.border
                        : isActive
                            ? AppColors.primaryGreen
                            : AppColors.creamDark,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isComplete
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : Text(stepNumber,
                            style: GoogleFonts.nunito(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: locked
                                  ? AppColors.textTertiary
                                  : isActive
                                      ? Colors.white
                                      : AppColors.textSecondary,
                            )),
                  ),
                ),
                const SizedBox(width: 10),
                Text(stepLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: locked ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (locked)
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                        size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(lockedMsg,
                        style: GoogleFonts.nunito(
                          fontSize: 11, color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 0.5),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: locked
                ? const SizedBox.shrink()  // hide content when locked
                : child,
          ),
        ],
      ),
    );
  }
}

// ── Step Connector ────────────────────────────────────────
class _StepConnector extends StatelessWidget {
  final bool unlocked;
  const _StepConnector({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const SizedBox(width: 29), // align with step badge center
          Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: unlocked
                      ? AppColors.primaryGreen
                      : AppColors.border,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            unlocked ? 'Detection active ✓' : 'Complete step 1 first',
            style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: unlocked
                  ? AppColors.primaryGreen
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1 Content: Detection Toggle ─────────────────────
class _DetectionToggleContent extends StatelessWidget {
  final SystemProvider sys;
  const _DetectionToggleContent({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status icon
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: sys.detectionEnabled
                ? AppColors.primaryGreen.withOpacity(0.1)
                : AppColors.creamDark,
            shape: BoxShape.circle,
          ),
          child: Icon(
            sys.detectionEnabled
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: sys.detectionEnabled
                ? AppColors.primaryGreen
                : AppColors.textTertiary,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sys.detectionEnabled ? 'Detection is ON' : 'Detection is OFF',
                style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: sys.detectionEnabled
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                sys.detectionEnabled
                    ? 'Monitoring garden for cats 🐱'
                    : 'Tap to start monitoring',
                style: GoogleFonts.nunito(
                  fontSize: 11, color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Big toggle button
        GestureDetector(
          onTap: () {
            if (sys.detectionEnabled) {
              sys.setDetectionEnabled(false);
              // Also call ESP32: GET /detection/off
            } else {
              sys.setDetectionEnabled(true);
              // Also call ESP32: GET /detection/on
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 64,
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: sys.detectionEnabled
                  ? AppColors.primaryGreen
                  : AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: sys.detectionEnabled
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step 2 Content: Sprinkler ─────────────────────────────
class _SprinklerStepContent extends StatelessWidget {
  final SystemProvider sys;
  const _SprinklerStepContent({required this.sys});

  @override
  Widget build(BuildContext context) {
    // If cat detected → show alert banner above button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cat detected banner
        if (sys.isAlerting) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.alertRed.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                const Text('🐱', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cat detected in garden!',
                        style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.alertRed,
                        ),
                      ),
                      Text('Use the sprinkler to deter it',
                        style: GoogleFonts.nunito(
                          fontSize: 10, color: AppColors.alertRed.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/alert'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.alertRed,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text('View →',
                    style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Sprinkler status + button
        Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: sys.sprinklerActive
                    ? AppColors.sprinklerBlue.withOpacity(0.12)
                    : AppColors.creamDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: sys.sprinklerActive
                    ? AppColors.sprinklerBlue
                    : AppColors.textTertiary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sys.sprinklerActive ? 'Sprinkler running…' : 'Sprinkler ready',
                    style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: sys.sprinklerActive
                          ? AppColors.sprinklerBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text('Duration: ${sys.sprinklerDuration}s per burst',
                    style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: !sys.detectionEnabled
                  ? null
                  : sys.sprinklerActive
                      ? sys.deactivateSprinkler
                      : sys.activateSprinkler,
              style: ElevatedButton.styleFrom(
                backgroundColor: sys.sprinklerActive
                    ? AppColors.alertRed
                    : AppColors.sprinklerBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
              child: Text(sys.sprinklerActive ? '⏹ Stop' : '💧 Activate'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final SystemProvider sys;
  const _StatsRow({required this.sys});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.today_rounded,
          iconColor: AppColors.primaryGreen,
          label: 'Today',
          value: '${sys.todayEventCount}',
          sub: 'events',
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          icon: Icons.pets_rounded,
          iconColor: AppColors.terracotta,
          label: 'Total',
          value: '${sys.totalDetectedCount}',
          sub: 'detected',
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          icon: Icons.visibility_rounded,
          iconColor: sys.detectionEnabled
              ? AppColors.primaryGreen
              : AppColors.textTertiary,
          label: 'Status',
          value: sys.detectionEnabled ? 'ON' : 'OFF',
          sub: 'detection',
          highlight: sys.detectionEnabled,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   value;
  final String   sub;
  final bool     highlight;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? iconColor.withOpacity(0.4) : AppColors.border,
          width: highlight ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(value,
            style: GoogleFonts.nunito(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: highlight ? iconColor : AppColors.textPrimary,
            ),
          ),
          Text(sub,
            style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Snapshot Card ─────────────────────────────────────────
class _SnapshotCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/camera'),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.creamDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Garden scene placeholder
            Container(color: const Color(0xFFD4EAD0)),
            Positioned(bottom: 0, left: 0, right: 0, height: 80,
              child: Container(
                color: const Color(0xFF5A8A3A).withOpacity(0.5))),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_outdoor_rounded,
                    size: 34, color: AppColors.textTertiary),
                  SizedBox(height: 6),
                  Text('Latest Garden Snapshot',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end:   Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record,
                      size: 7, color: AppColors.successGreen),
                    const SizedBox(width: 5),
                    Text(
                      'Last updated ${DateFormat('hh:mm a').format(DateTime.now())}',
                      style: GoogleFonts.nunito(
                        color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.open_in_full_rounded,
                      size: 13, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String  title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
          style: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
