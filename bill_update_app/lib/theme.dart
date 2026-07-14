import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF1A2A6C);
  static const darkNavy = Color(0xFF0D1B4A);
  static const blue = Color(0xFF2D9CDB);
  static const lightBlue = Color(0xFFE8F4FD);
  static const accent = Color(0xFFF39C12);
  static const green = Color(0xFF27AE60);
  static const red = Color(0xFFE74C3C);
  static const bgLight = Color(0xFFF5F7FA);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF1A1A2E);
  static const textMedium = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const fieldBg = Color(0xFFF0F4FF);
  static const fieldBorder = Color(0xFFE2E8F0);
  static const shadow = Color(0xFF1A2A6C);
}

class AppStyles {
  static const headerStyle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5,
  );
  static const subHeaderStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy,
  );
  static const cardTitleStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy,
  );
  static const amountStyle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.blue,
  );
  static const amountStyleWhite = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
  );
  static const labelStyle = TextStyle(
    fontWeight: FontWeight.w700, color: AppColors.navy, fontSize: 14,
  );
  static const bodySmall = TextStyle(
    color: AppColors.textMedium, fontSize: 13,
  );
  static const trustBadgeStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.green,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.fieldBorder),
    boxShadow: [
      BoxShadow(color: AppColors.shadow.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, 4)),
      BoxShadow(color: AppColors.shadow.withValues(alpha: .03), blurRadius: 8, offset: const Offset(0, 1)),
    ],
  );

  static BoxDecoration primaryGradient = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.navy, AppColors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration blueGradient = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF2D9CDB), Color(0xFF1A2A6C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration headerGradient = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF5A3AA8), Color(0xFF1A2A6C)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );

  static ButtonStyle primaryButton(double width) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.blue,
    disabledBackgroundColor: Colors.grey.shade400,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: Size(width, 54),
    elevation: 2,
    shadowColor: AppColors.blue.withValues(alpha: .4),
  );

  static ButtonStyle accentButton(double width) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    disabledBackgroundColor: Colors.grey.shade400,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: Size(width, 54),
    elevation: 2,
    shadowColor: AppColors.accent.withValues(alpha: .4),
  );

  static InputDecoration textFieldDecoration(String hint, {Widget? prefixIcon}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textLight),
    filled: true,
    fillColor: AppColors.fieldBg,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.fieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.blue, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
