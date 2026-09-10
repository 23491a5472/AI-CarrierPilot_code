import 'package:flutter/material.dart';

/// Consistent corner-radius scale for AI CareerPilot.
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  // Semantic double constants
  static const double card = 16.0;
  static const double button = 12.0;
  static const double input = 12.0;
  static const double chip = 8.0;
  static const double pill = 999.0;

  // BorderRadius helper getters
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
