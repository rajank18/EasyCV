import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const bgPrimary = Color(0xFFFAFAF8);
  static const bgSurface = Color(0xFFF3F2EF);
  static const bgSurfaceRaised = Color(0xFFECEAE6);
  static const borderSubtle = Color(0xFFE4E2DD);
  static const borderMid = Color(0xFFC8C5BE);
  static const textPrimary = Color(0xFF0D0D0D);
  static const textSecondary = Color(0xFF5C5B57);
  static const textTertiary = Color(0xFF9C9A95);
  static const accent = Color(0xFF1A1A2E);
  static const accentTint = Color(0xFFEBEBF5);
  static const accentMid = Color(0xFF3D3D6B);
  static const success = Color(0xFF1A7A58);
  static const successTint = Color(0xFFE8F5F0);
  static const warning = Color(0xFFC47A1E);
  static const warningTint = Color(0xFFFDF3E4);
  static const danger = Color(0xFFB83232);
  static const dangerTint = Color(0xFFFCEAEA);

  static const darkBgPrimary = Color(0xFF0E0E0E);
  static const darkBgSurface = Color(0xFF181818);
  static const darkBgSurfaceRaised = Color(0xFF212121);
  static const darkBorderSubtle = Color(0xFF2C2C2C);
  static const darkBorderMid = Color(0xFF404040);
  static const darkTextPrimary = Color(0xFFF0EDE8);
  static const darkTextSecondary = Color(0xFFA8A5A0);
  static const darkTextTertiary = Color(0xFF666460);
  static const darkAccent = Color(0xFF7B7FD4);
  static const darkAccentTint = Color(0xFF1C1C2E);
}

class AppSpacing {
  const AppSpacing._();

  static const sp4 = 4.0;
  static const sp8 = 8.0;
  static const sp12 = 12.0;
  static const sp16 = 16.0;
  static const sp20 = 20.0;
  static const sp24 = 24.0;
  static const sp32 = 32.0;
  static const sp40 = 40.0;
  static const sp48 = 48.0;
  static const sp64 = 64.0;
  static const sp80 = 80.0;
}

class AppRadius {
  const AppRadius._();

  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radius2xl = 32.0;
  static const radiusPill = 999.0;
}

class AppShadows {
  const AppShadows._();

  static const shadowSm = [
    BoxShadow(
      color: Color(0x0D0D0D0D),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const shadowMd = [
    BoxShadow(
      color: Color(0x120D0D0D),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0D0D0D),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}

class AppText {
  const AppText._();

  static TextTheme lightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        height: 1.15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: AppColors.textTertiary,
      ),
    );
  }

  static TextStyle monoLarge(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle monoMedium(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle monoSmall(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      );
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final textTheme = AppText.lightTextTheme();
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      surface: AppColors.bgSurface,
      primary: AppColors.accent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSurface,
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.borderSubtle,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: _outline(AppColors.borderSubtle),
        enabledBorder: _outline(AppColors.borderSubtle),
        focusedBorder: _outline(AppColors.accent),
        errorBorder: _outline(AppColors.danger),
        focusedErrorBorder: _outline(AppColors.danger),
        labelStyle: textTheme.bodySmall,
        floatingLabelStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.accent,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.borderMid, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          ),
          foregroundColor: AppColors.textPrimary,
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: const IconThemeData(color: AppColors.textPrimary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = AppText.lightTextTheme().apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAccent,
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
    );
  }

  static OutlineInputBorder _outline(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
