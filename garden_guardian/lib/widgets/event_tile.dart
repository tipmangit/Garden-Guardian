// lib/widgets/event_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/system_provider.dart';

class EventTile extends StatelessWidget {
  final CatEvent     event;
  final bool         showTime;
  final VoidCallback? onTap;

  const EventTile({
    super.key,
    required this.event,
    this.showTime = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _config(event.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color:        cfg.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(cfg.icon, color: cfg.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(cfg.label,
                        style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (event.isKnownCat) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color:        AppColors.soilBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Known',
                            style: GoogleFonts.nunito(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: AppColors.soilBrown,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(cfg.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Text(
              showTime
                  ? DateFormat('hh:mm a').format(event.timestamp)
                  : _relativeTime(event.timestamp),
              style: GoogleFonts.nunito(
                fontSize: 11, color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  ({IconData icon, Color color, String label, String subtitle}) _config(
      EventType type) {
    return switch (type) {
      EventType.detected => (
        icon:     Icons.pets_rounded,
        color:    AppColors.terracotta,
        label:    'Cat Detected',
        subtitle: 'Motion detected in garden',
      ),
      EventType.sprinklerActivated => (
        icon:     Icons.water_drop_rounded,
        color:    AppColors.sprinklerBlue,
        label:    'Sprinkler Activated',
        subtitle: 'Deterrent deployed',
      ),
      EventType.ignored => (
        icon:     Icons.block_rounded,
        color:    AppColors.textTertiary,
        label:    'Alert Ignored',
        subtitle: event.isKnownCat
            ? 'Known cat — skipped'
            : 'Manually dismissed',
      ),
    };
  }
}

// ── Section Header ────────────────────────────────────────
// Kept in the same file to reduce clutter.
// Imported elsewhere via section_header.dart re-export.
class SectionHeader extends StatelessWidget {
  final String  title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

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
