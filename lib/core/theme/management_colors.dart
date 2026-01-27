import 'package:flutter/material.dart';

class ManagementColors {
  static const List<int> categoryColors = [
    0xFF4361EE, // Primary
    0xFF06D6A0, // Income
    0xFFEF476F, // Expense
    0xFFFFD166, // Warning
    0xFF4B5563, // gray600
    0xFF1F2937, // gray800
  ];

  static const List<int> tagColors = [
    0xFF4361EE, // Primary
    0xFF06D6A0, // Income
    0xFFEF476F, // Expense
    0xFFFFD166, // Warning
    0xFF118AB2, // Blue
    0xFF073B4C, // Dark Blue
    0xFF9D4EDD, // Purple
    0xFFFF9F1C, // Orange
  ];

  static int defaultColor(List<int> colors) {
    return colors.isNotEmpty ? colors.first : 0xFF4361EE;
  }

  static Color parseColor(int colorValue) {
    return Color(colorValue);
  }

  static int parseColorHex(String hexColor) {
    return int.parse(hexColor.replaceAll('#', '0xFF'));
  }

  static String toColorHex(int colorValue) {
    return '#${colorValue.toRadixString(16).substring(2).toUpperCase()}';
  }
}
