// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/system_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipCtrl;

  @override
  void initState() {
    super.initState();
    final sys = context.read<SystemProvider>();
    _ipCtrl = TextEditingController(text: sys.esp32StreamUrl);
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile Card ──────────────────────────
          _ProfileCard(),

          const SizedBox(height: 20),

          // ── System ────────────────────────────────
          _SectionTitle('System'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.security_rounded,
                iconColor: AppColors.primaryGreen,
                title: 'System Armed',
                subtitle: sys.isArmed ? 'Garden is being monitored' : 'Monitoring paused',
                value: sys.isArmed,
                onChanged: (v) => sys.setStatus(
                    v ? SystemStatus.armed : SystemStatus.disarmed),
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.notifications_rounded,
                iconColor: AppColors.warningAmber,
                title: 'Push Notifications',
                subtitle: 'Get alerted when a cat is detected',
                value: sys.notificationsEnabled,
                onChanged: sys.setNotificationsEnabled,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Detection ─────────────────────────────
          _SectionTitle('Detection'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded,
                        size: 18, color: AppColors.terracotta),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detection Sensitivity',
                            style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text('Confidence threshold: ${(sys.detectionSensitivity * 100).round()}%',
                            style: GoogleFonts.nunito(
                              fontSize: 11, color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:   AppColors.terracotta,
                  inactiveTrackColor: AppColors.border,
                  thumbColor:         AppColors.terracotta,
                  overlayColor:       AppColors.terracotta.withOpacity(0.1),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: sys.detectionSensitivity,
                  min: 0.3, max: 1.0,
                  divisions: 7,
                  onChanged: sys.setDetectionSensitivity,
                ),
              ),
              const Divider(),
              _NavTile(
                icon: Icons.pets_rounded,
                iconColor: AppColors.soilBrown,
                title: 'Known Cats',
                subtitle: 'Cats to ignore when detected',
                onTap: () => context.push('/known-cats'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Sprinkler ─────────────────────────────
          _SectionTitle('Sprinkler'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.sprinklerBlue,
                title: 'Auto-Activate',
                subtitle: 'Automatically spray when cat detected',
                value: sys.autoSprinkler,
                onChanged: sys.setAutoSprinkler,
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.sprinklerBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timer_rounded,
                        size: 18, color: AppColors.sprinklerBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spray Duration',
                            style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text('${sys.sprinklerDuration} seconds per activation',
                            style: GoogleFonts.nunito(
                              fontSize: 11, color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:   AppColors.sprinklerBlue,
                  inactiveTrackColor: AppColors.border,
                  thumbColor:         AppColors.sprinklerBlue,
                  overlayColor:       AppColors.sprinklerBlue.withOpacity(0.1),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: sys.sprinklerDuration.toDouble(),
                  min: 2, max: 30, divisions: 14,
                  onChanged: (v) => sys.setSprinklerDuration(v.round()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Hardware ──────────────────────────────
          _SectionTitle('Hardware'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.router_rounded,
                            size: 18, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('ESP32-CAM IP Address',
                            style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ipCtrl,
                            style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'http://192.168.1.100',
                              hintStyle: GoogleFonts.nunito(
                                fontSize: 13, color: AppColors.textTertiary,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: AppColors.creamDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.border, width: 0.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.border, width: 0.8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryGreen, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            sys.setEsp32Url(_ipCtrl.text.trim());
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Camera URL updated',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600)),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: GoogleFonts.nunito(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── About ─────────────────────────────────
          _SectionTitle('About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _InfoTile(label: 'Version',       value: '1.0.0 (build 1)'),
              const Divider(),
              _InfoTile(label: 'Platform',      value: 'Flutter Web'),
              const Divider(),
              _InfoTile(label: 'Hardware',      value: 'ESP32-CAM + Arduino IDE'),
              const Divider(),
              _InfoTile(label: 'Backend',       value: 'Firebase (Firestore · FCM)'),
              const Divider(),
              _InfoTile(label: 'AI Detection',  value: 'TensorFlow Lite'),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── Reusable tiles ────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.nunito(
      fontSize: 11, fontWeight: FontWeight.w800,
      color: AppColors.textTertiary,
      letterSpacing: 1.0,
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 0.8),
    ),
    child: Column(children: children),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData  icon;
  final Color     iconColor;
  final String    title;
  final String    subtitle;
  final bool      value;
  final void Function(bool) onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 11, color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData  icon;
  final Color     iconColor;
  final String    title;
  final String    subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
              color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label,
            style: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(value,
            style: GoogleFonts.nunito(
              fontSize: 12, color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
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
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🐾',
                style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Garden Owner',
                  style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text('Garden Guardian System',
                  style: GoogleFonts.nunito(
                    fontSize: 12, color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Edit',
              style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
