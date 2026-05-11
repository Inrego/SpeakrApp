import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/live/widgets/source_picker.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SourcePicker', () {
    testWidgets('shows Off / Off subtitles in the default state',
        (tester) async {
      await tester.pumpWidget(_wrap(SourcePicker(
        micEnabled: false,
        systemEnabled: false,
        systemAudioSupported: true,
        micPending: false,
        systemPending: false,
        onMicChanged: (_) {},
        onSystemChanged: (_) {},
      )));
      expect(find.text('Off'), findsNWidgets(2));
      expect(find.text('Recording'), findsNothing);
    });

    testWidgets('renders Recording when a source is enabled', (tester) async {
      await tester.pumpWidget(_wrap(SourcePicker(
        micEnabled: true,
        systemEnabled: false,
        systemAudioSupported: true,
        micPending: false,
        systemPending: false,
        onMicChanged: (_) {},
        onSystemChanged: (_) {},
      )));
      expect(find.text('Recording'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('disables the system row when capability is absent',
        (tester) async {
      bool? lastSysChange;
      await tester.pumpWidget(_wrap(SourcePicker(
        micEnabled: true,
        systemEnabled: false,
        systemAudioSupported: false,
        micPending: false,
        systemPending: false,
        onMicChanged: (_) {},
        onSystemChanged: (v) => lastSysChange = v,
      )));
      expect(find.text('Windows or Android 10+ only'), findsOneWidget);
      // Tap the second switch (system); it should not propagate.
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));
      await tester.tap(switches.at(1));
      await tester.pump();
      expect(lastSysChange, isNull);
    });

    testWidgets('shows a spinner instead of a switch while pending',
        (tester) async {
      await tester.pumpWidget(_wrap(SourcePicker(
        micEnabled: true,
        systemEnabled: false,
        systemAudioSupported: true,
        micPending: true,
        systemPending: false,
        onMicChanged: (_) {},
        onSystemChanged: (_) {},
      )));
      // Mic row → spinner; system row → switch. So one switch and one
      // CircularProgressIndicator are expected.
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Working…'), findsOneWidget);
    });
  });
}
