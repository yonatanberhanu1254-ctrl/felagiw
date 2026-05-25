import 'package:flutter/material.dart';

/// CareerConnect design token colors.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFFEAE9FF);
  static const Color secondary = Color(0xFF00D4AA);
  static const Color secondaryLight = Color(0xFFE0FBF5);
  static const Color accent = Color(0xFFFF6B6B);

  // Neutrals - Dark theme
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkBorder = Color(0xFF2A2A4A);
  static const Color darkText = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFFA0A0C0);

  // Neutrals - Light theme
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E8F0);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B8A);

  // Status colors
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4FC3F7);

  // Application status
  static const Color statusPending = Color(0xFFFFB347);
  static const Color statusReviewed = Color(0xFF4FC3F7);
  static const Color statusAccepted = Color(0xFF00D4AA);
  static const Color statusRejected = Color(0xFFFF6B6B);
  static const Color statusShortlisted = Color(0xFF6C63FF);

  // Job type tags
  static const Color fullTime = Color(0xFF6C63FF);
  static const Color partTime = Color(0xFF00D4AA);
  static const Color internship = Color(0xFFFFB347);
  static const Color remote = Color(0xFF4FC3F7);
  static const Color contract = Color(0xFFFF6B6B);
}
