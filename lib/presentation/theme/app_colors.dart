import 'package:flutter/material.dart';

import '../../domain/models/skill_level.dart';

abstract final class AppColors {
  // Surfaces – deep "night match" greens.
  static const background = Color(0xFF07110C);
  static const surface = Color(0xFF0E1C15);
  static const surfaceRaised = Color(0xFF15281E);
  static const outline = Color(0xFF22392C);

  // Pitch & accents.
  static const pitch = Color(0xFF1F7A45);
  static const pitchDark = Color(0xFF0D3A21);
  static const accent = Color(0xFF34D27B);
  static const accentBright = Color(0xFFB4F461);
  static const onAccent = Color(0xFF04140B);

  // Text.
  static const textPrimary = Color(0xFFF2F7F4);
  static const textSecondary = Color(0xFF8FA89A);

  // Feedback.
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  /// Kit colours that make the three teams instantly distinguishable.
  static const teamKits = [
    Color(0xFFFFB020), // Team A – amber
    Color(0xFF3BB3FF), // Team B – sky blue
    Color(0xFFFF4D6D), // Team C – crimson
  ];

  static Color teamColor(int index) => teamKits[index % teamKits.length];
}

extension SkillLevelStyle on SkillLevel {
  Color get color => switch (this) {
    SkillLevel.elite => const Color(0xFFFFD43B),
    SkillLevel.excellent => const Color(0xFFB4F461),
    SkillLevel.good => const Color(0xFF34D27B),
    SkillLevel.average => const Color(0xFF2DD4BF),
    SkillLevel.developing => const Color(0xFF60A5FA),
    SkillLevel.beginner => const Color(0xFF94A3B8),
  };
}
