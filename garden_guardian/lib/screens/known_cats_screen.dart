// lib/screens/known_cats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class KnownCatsScreen extends StatefulWidget {
  const KnownCatsScreen({super.key});

  @override
  State<KnownCatsScreen> createState() => _KnownCatsScreenState();
}

class _KnownCatsScreenState extends State<KnownCatsScreen> {
  final List<_KnownCat> _cats = [
    _KnownCat(name: 'Mochi',   color: AppColors.soilBrown, emoji: '🐱'),
    _KnownCat(name: 'Shadow',  color: AppColors.textPrimary, emoji: '🐈‍⬛'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Known Cats'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.soilBrown.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.soilBrown.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Add your own cats so the system ignores them '
                    'and won\'t send false alerts.',
                    style: GoogleFonts.nunito(
                      fontSize: 12, color: AppColors.soilDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_cats.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('🌱', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text('No known cats yet',
                    style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text('Tap + to add your cat',
                    style: GoogleFonts.nunito(
                      fontSize: 12, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._cats.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: entry.value.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(entry.value.emoji,
                          style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.value.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.alertRed, size: 20),
                      onPressed: () => setState(() => _cats.removeAt(entry.key)),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Cat',
          style: GoogleFonts.nunito(
            color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Known Cat',
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cat\'s name',
            hintStyle: GoogleFonts.nunito(color: AppColors.textTertiary),
            prefixText: '🐱  ',
          ),
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: GoogleFonts.nunito(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _cats.add(_KnownCat(
                  name: ctrl.text.trim(),
                  color: AppColors.primaryGreen,
                  emoji: '🐱',
                )));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Add', style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _KnownCat {
  final String name;
  final Color  color;
  final String emoji;
  _KnownCat({required this.name, required this.color, required this.emoji});
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/event_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Event Detail'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📸', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('Event #$eventId',
                style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Snapshot, detection confidence, timestamp, '
                'and Firestore data would display here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
