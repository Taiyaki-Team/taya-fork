import 'package:flutter/material.dart';

/// UI Guidelines to ensure consistent styling throughout the app
/// Use this class for reference when creating new UI components
class AppStyles {
  // Text Styles - Light mode
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F5878),
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF0D1F40),
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: Color(0xFF0D1F40),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Color(0xFF4A5568),
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: Color(0xFF4A5568),
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF4A5568),
  );

  // Colors - Light mode
  static final Color backgroundPrimary = const Color(0xFFFFFFFF); // Pure white
  static final Color backgroundSecondary = const Color(0xFFFFFFFF); // White
  static final Color backgroundTertiary = const Color(0xFFF5F5F5); // Light gray

  static const Color textPrimary = Color(0xFF0F5878); // Dark teal
  static final Color textSecondary = const Color(0xFF0D1F40); // Dark blue
  static final Color textTertiary = const Color(0xFF4A5568); // Medium gray

  static const Color accent = Color(0xFF4FAFBE); // Teal
  static final Color error = const Color(0xFFEF4444); // Red
  static final Color success = const Color(0xFF10B981); // Green

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // Radius
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusCircular = 100.0;

  // Widget specific
  static final cardDecoration = BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF0D1F40).withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: backgroundTertiary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
  );

  static final chipDecoration = BoxDecoration(
    color: backgroundTertiary.withOpacity(0.6),
    borderRadius: BorderRadius.circular(radiusCircular),
  );
}

/// Theme extension to provide app styles as part of the theme
class AppTheme extends ThemeExtension<AppTheme> {
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle small;
  final TextStyle label;

  AppTheme({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
    required this.small,
    required this.label,
  });

  @override
  ThemeExtension<AppTheme> copyWith({
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? small,
    TextStyle? label,
  }) {
    return AppTheme(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      small: small ?? this.small,
      label: label ?? this.label,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return AppTheme(
      title: TextStyle.lerp(title, other.title, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      small: TextStyle.lerp(small, other.small, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
    );
  }

  /// Apply AppTheme to ThemeData
  static ThemeData applyToTheme(ThemeData theme) {
    return theme.copyWith(
      extensions: [
        AppTheme(
          title: AppStyles.title,
          subtitle: AppStyles.subtitle,
          body: AppStyles.body,
          caption: AppStyles.caption,
          small: AppStyles.small,
          label: AppStyles.label,
        ),
      ],
    );
  }
}
