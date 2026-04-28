import 'package:flutter/material.dart';

import '../../theme/colors.dart';

const presetTags = <(String, Color)>[
  ('Internal', SpeakrColors.tagInternal),
  ('1:1', SpeakrColors.tag1on1),
  ('Customer', SpeakrColors.tagCustomer),
  ('Roadmap', SpeakrColors.tagRoadmap),
  ('Design', SpeakrColors.tagDesign),
  ('Personal', SpeakrColors.tagPersonal),
  ('Engineering', SpeakrColors.tagEngineering),
];

Color colorForTag(String name) {
  final preset = presetTags.firstWhere(
    (t) => t.$1 == name,
    orElse: () => ('', SpeakrColors.ink),
  );
  return preset.$1.isEmpty ? SpeakrColors.ink : preset.$2;
}
