import 'package:flutter/material.dart';

/// Direction A — Calm Minimal palette, ported from the React mockup
/// (`Speakr_extracted/direction-a-1.jsx` lines 5-16).
class SpeakrColors {
  static const bg = Color(0xFFFAFAF7);
  static const bgAlt = Color(0xFFF3F1EC);
  static const ink = Color(0xFF1A1A1A);
  static const ink2 = Color(0xFF3A3A36);
  static const muted = Color(0xFF8A8A83);
  static const line = Color(0xFFE6E3DC);

  // Accents pulled from the design's tag colors and indicators.
  static const recordingDot = Color(0xFFC2562B);
  static const ok = Color(0xFF3A8A5A);
  static const danger = Color(0xFFC2562B);

  // Tag preset colors (tags from data.js / direction-a-3.jsx)
  static const tagRoadmap = Color(0xFFC2562B);
  static const tagEngineering = Color(0xFF3A6A5A);
  static const tag1on1 = Color(0xFF6A4F8A);
  static const tagCustomer = Color(0xFF1F6B8C);
  static const tagDesign = Color(0xFF8A5A2A);
  static const tagPersonal = Color(0xFF5A6A3A);
  static const tagInternal = Color(0xFF3A6A5A);
}

/// Convert a hex string from the API (`#c2562b`, `c2562b`, `#c2562bff`)
/// into a [Color]. Returns [SpeakrColors.muted] on parse failure.
Color parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return SpeakrColors.muted;
  var v = hex.replaceAll('#', '').trim();
  if (v.length == 6) v = 'FF$v';
  if (v.length != 8) return SpeakrColors.muted;
  final n = int.tryParse(v, radix: 16);
  if (n == null) return SpeakrColors.muted;
  return Color(n);
}
