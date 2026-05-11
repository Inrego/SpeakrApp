import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/live/widgets/recording_widgets.dart';

MetadataCard _card({
  required bool micEnabled,
  required bool systemEnabled,
  required bool systemAudioSupported,
  bool micPending = false,
  bool systemPending = false,
  ValueChanged<bool>? onMicChanged,
  ValueChanged<bool>? onSystemChanged,
}) {
  return MetadataCard(
    speakers: 1,
    onSpeakersChanged: (_) {},
    activeTags: const [],
    tagPickerOpen: false,
    onToggleTag: (_) {},
    onToggleEdit: () {},
    micEnabled: micEnabled,
    systemEnabled: systemEnabled,
    systemAudioSupported: systemAudioSupported,
    micPending: micPending,
    systemPending: systemPending,
    onMicChanged: onMicChanged ?? (_) {},
    onSystemChanged: onSystemChanged ?? (_) {},
  );
}

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('MetadataCard capture row', () {
    testWidgets('renders Mic and System chips when system audio is supported',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: true,
        systemAudioSupported: true,
      )));
      expect(find.text('CAPTURE'), findsOneWidget);
      expect(find.text('MIC'), findsOneWidget);
      expect(find.text('SYSTEM'), findsOneWidget);
    });

    testWidgets('hides the System chip when system audio is unsupported',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: false,
        systemAudioSupported: false,
      )));
      expect(find.text('MIC'), findsOneWidget);
      expect(find.text('SYSTEM'), findsNothing);
    });

    testWidgets('shows a spinner in place of the icon while pending',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: true,
        systemAudioSupported: true,
        micPending: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping the Mic chip toggles its value', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: true,
        systemAudioSupported: true,
        onMicChanged: (v) => lastValue = v,
      )));
      await tester.tap(find.text('MIC'));
      await tester.pump();
      expect(lastValue, isFalse);
    });

    testWidgets('tapping the System chip toggles its value', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: false,
        systemAudioSupported: true,
        onSystemChanged: (v) => lastValue = v,
      )));
      await tester.tap(find.text('SYSTEM'));
      await tester.pump();
      expect(lastValue, isTrue);
    });

    testWidgets('pending chip ignores taps', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(_wrap(_card(
        micEnabled: true,
        systemEnabled: true,
        systemAudioSupported: true,
        micPending: true,
        onMicChanged: (v) => lastValue = v,
      )));
      // The CircularProgressIndicator sits where the icon would; tapping the
      // chip's label should be a no-op while pending.
      await tester.tap(find.text('MIC'));
      await tester.pump();
      expect(lastValue, isNull);
    });
  });
}
