import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/providers.dart';
import '../../api/speakr_api.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../library/library_controller.dart';
import 'detail_controller.dart';

enum ReprocessKind { transcription, summary }

Future<void> toggleRecordingField(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
  required Map<String, dynamic> patch,
  required String successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);
  try {
    await api.updateRecording(recordingId, patch);
    container.invalidate(recordingDetailProvider(recordingId));
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> reprocessRecording(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
  required ReprocessKind kind,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text(
        kind == ReprocessKind.transcription
            ? 'Reprocess transcription?'
            : 'Reprocess summary?',
        style: SpeakrText.serif(size: 20),
      ),
      content: Text(
        kind == ReprocessKind.transcription
            ? 'The current transcript and any speaker labels will be replaced. Processing happens on the server and may take a few minutes.'
            : 'The current summary will be replaced. Processing happens on the server and may take a few minutes.',
        style: SpeakrText.sans(size: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancel',
            style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Reprocess',
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.ink,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    if (kind == ReprocessKind.transcription) {
      await api.reprocessTranscription(recordingId);
    } else {
      await api.reprocessSummary(recordingId);
    }
    container.invalidate(recordingDetailProvider(recordingId));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kind == ReprocessKind.transcription
              ? 'Transcription queued — refresh in a moment'
              : 'Summary queued — refresh in a moment',
        ),
      ),
    );
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> deleteRecording(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
}) async {
  final goRouter = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text('Delete recording?', style: SpeakrText.serif(size: 20)),
      content: Text(
        'This permanently deletes the recording, its transcript, and its audio. This cannot be undone.',
        style: SpeakrText.sans(size: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancel',
            style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: SpeakrColors.danger),
          child: Text(
            'Delete',
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.danger,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await api.deleteRecording(recordingId);
    container.read(uploadKickProvider.notifier).state++;
    container.invalidate(recordingDetailProvider(recordingId));
    if (goRouter.canPop()) goRouter.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Recording deleted')),
    );
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}
