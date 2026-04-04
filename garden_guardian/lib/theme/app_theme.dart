// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // === Primary Palette (Garden) ===
  static const Color primaryGreen      = Color(0xFF4A7C59);
  static const Color primaryGreenLight = Color(0xFF6A9E78);
  static const Color primaryGreenDark  = Color(0xFF2F5A3A);

  // === Soil / Brown ===
  static const Color soilBrown  = Color(0xFF8B6F47);
  static const Color soilLight  = Color(0xFFB8966A);
  static const Color soilDark   = Color(0xFF5C4830);

  // === Accent (Terracotta) ===
  static const Color terracotta      = Color(0xFFE07A5F);
  static const Color terracottaLight = Color(0xFFF0A08A);
  static const Color terracottaDark  = Color(0xFFA85040);

  // === Backgrounds ===
  static const Color cream      = Color(0xFFF5F0E8);
  static const Color creamDark  = Color(0xFFEDE5D8);
  static const Color cardWhite  = Color(0xFFFFFFFF);
  static const Color cardTinted = Color(0xFFFAF7F2);

  // === Alert / Status ===
  static const Color alertRed       = Color(0xFFD64045);
  static const Color alertRedLight  = Color(0xFFFF6B6F);
  static const Color alertRedBg     = Color(0xFFFFF0F0);
  static const Color successGreen   = Color(0xFF3A9B6B);
  static const Color warningAmber   = Color(0xFFE8A020);

  // === Text ===
  static const Color textPrimary   = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6460);
  static const Color textTertiary  = Color(0xFFA09890);
  static const Color textOnDark    = Color(0xFFFAF7F2);

  // === Border / Divider ===
  static const Color border  = Color(0xFFE0D9CC);
  static const Color divider = Color(0xFFEDE8E0);

  // === Leaf accent ===
  static const Color leafGreen = Color(0xFF7FB349);
  static const Color leafDark  = Color(0xFF4A7C21);

  // === Sprinkler Blue ===
  static const Color sprinklerBlue      = Color(0xFF2E86C1);
  static const Color sprinklerBlueLight = Color(0xFF5DADE2);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary:     AppColors.primaryGreen,
        secondary:   AppColors.soilBrown,
        tertiary:    AppColors.terracotta,
        surface:     AppColors.cardWhite,
        onPrimary:   AppColors.textOnDark,
        onSecondary: AppColors.textOnDark,
      ),
      scaffoldBackgroundColor: AppColors.cream,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        displayMedium:  GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge:  GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall:  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:     GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleMedium:    GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleSmall:     GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        bodyLarge:      GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium:     GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall:      GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
        labelLarge:     GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium:    GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        labelSmall:     GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:  AppColors.primaryGreen,
        foregroundColor:  AppColors.textOnDark,
        elevation:        0,
        centerTitle:      false,
        titleTextStyle:   GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
      ),
      // ── FIX: use CardThemeData instead of CardTheme ──────
      cardTheme: CardThemeData(
        color:     AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        margin: const EdgeInsets.all(0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.textOnDark,
          elevation:       0,
          padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side:            const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryGreen
                : AppColors.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryGreenLight.withOpacity(0.4)
                : AppColors.border),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.cardWhite,
        selectedItemColor:   AppColors.primaryGreen,
        unselectedItemColor: AppColors.textTertiary,
        elevation:           8,
        type:                BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.cardTinted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color:     AppColors.divider,
        space:     0,
        thickness: 0.8,
      ),
    );
  }
}