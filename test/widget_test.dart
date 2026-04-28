import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:speakr_app/theme/typography.dart';
import 'package:speakr_app/widgets/mono_eyebrow.dart';

void main() {
  testWidgets('Theme builder produces a valid ThemeData', (tester) async {
    final theme = buildSpeakrTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, isNotNull);
  });

  testWidgets('MonoEyebrow renders the upper-cased text', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MonoEyebrow('hello world')),
        ),
      ),
    );
    expect(find.text('HELLO WORLD'), findsOneWidget);
  });
}
