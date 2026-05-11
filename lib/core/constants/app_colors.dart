import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- Brand ----
  static const primary = Color(0xFF1A73E8);     
  static const primaryDark = Color(0xFF1557B0);
  static const primaryLight = Color(0xFFD2E3FC);

  // ---- Background ----
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F3F4);

  // ---- Chat Bubbles ----
  static const userBubble = primary;
  static const userBubbleText = Color(0xFFFFFFFF);
  static const botBubble = Color(0xFFFFFFFF);
  static const botBubbleText = Color(0xFF1F1F1F);
  static const botBubbleBorder = Color(0xFFE0E0E0);

  // ---- Status ----
  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFF9DEDC);
  static const online = Color(0xFF34A853);
  static const offline = Color(0xFFEA4335);
  static const checking = Color(0xFFFBBC04);

  // ---- Text ----
  static const textPrimary = Color(0xFF1F1F1F);
  static const textSecondary = Color(0xFF5F6368);
  static const textHint = Color(0xFF9AA0A6);

  // ---- Input ----
  static const inputFill = Color(0xFFF1F3F4);
  static const inputBorder = Color(0xFFE0E0E0);
  static const inputBorderFocused = primary;

  // ---- Divider ----
  static const divider = Color(0xFFE0E0E0);
}