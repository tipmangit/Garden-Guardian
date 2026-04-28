// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/system_provider.dart';
import '../widgets/event_tile.dart';

enum _Filter { all, detected, sprinkler, ignored }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _Filter _filter = _Filter.all;

  List<CatEvent> _filtered(List<CatEvent> events) {
    return switch (_filter) {
      _Filter.all       => events,
      _Filter.detected  => events.where((e) => e.type == EventType.detected).toList(),
      _Filter.sprinkler => events.where((e) => e.type == EventType.sprinklerActivated).toList(),
      _Filter.ignored   => events.where((e) => e.type == EventType.ignored).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final sys    = context.watch<SystemProvider>();
    final events = _filtered(sys.events);

    // Group by date
    final Map<String, List<CatEvent>> grouped = {};
    for (final e in events) {
      final key = _dateLabel(e.timestamp);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Event Log'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Clear All',
              style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Chips ───────────────────────────
          Container(
            color: AppColors.cardWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    icon: Icons.list_rounded,
                    active: _filter == _Filter.all,
                    count: sys.events.length,
                    onTap: () => setState(() => _filter = _Filter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Detected',
                    icon: Icons.pets_rounded,
                    active: _filter == _Filter.detected,
                    color: AppColors.terracotta,
                    count: sys.events.where((e) => e.type == EventType.detected).length,
                    onTap: () => setState(() => _filter = _Filter.detected),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Sprinkler',
                    icon: Icons.water_drop_rounded,
                    active: _filter == _Filter.sprinkler,
                    color: AppColors.sprinklerBlue,
                    count: sys.events.where((e) => e.type == EventType.sprinklerActivated).length,
                    onTap: () => setState(() => _filter = _Filter.sprinkler),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Ignored',
                    icon: Icons.block_rounded,
                    active: _filter == _Filter.ignored,
                    color: AppColors.textTertiary,
                    count: sys.events.where((e) => e.type == EventType.ignored).length,
                    onTap: () => setState(() => _filter = _Filter.ignored),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 0.5),

          // ── Event List ─────────────────────────────
          Expanded(
            child: events.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: grouped.length,
                    itemBuilder: (ctx, gi) {
                      final dateKey = grouped.keys.elementAt(gi);
                      final dayEvents = grouped[dateKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gi > 0) const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, bottom: 8, top: 4),
                            child: Text(dateKey,
                              style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...dayEvents.map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: EventTile(
                              event: event,
                              showTime: true,
                              onTap: () => context.go('/event/${event.id}'),
                            ),
                          )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'TODAY';
    if (diff.inDays == 1) return 'YESTERDAY';
    return DateFormat('MMMM d, yyyy').format(dt).toUpperCase();
  }
}

// ── Filter Chip ───────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final bool      active;
  final Color     color;
  final int       count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.count,
    required this.onTap,
    this.color = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : AppColors.creamDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color.withOpacity(0.4) : AppColors.border,
            width: active ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
              size: 14,
              color: active ? color : AppColors.textTertiary),
            const SizedBox(width: 5),
            Text(label,
              style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: active ? color : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? color.withOpacity(0.15) : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                  style: GoogleFonts.nunito(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: active ? color : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌿', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('All clear!',
            style: GoogleFonts.nunito(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text('No events match this filter.',
            style: GoogleFonts.nunito(
              fontSize: 13, color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
