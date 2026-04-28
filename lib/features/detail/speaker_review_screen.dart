import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../api/speakr_api.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import 'detail_controller.dart';

class SpeakerReviewScreen extends ConsumerStatefulWidget {
  const SpeakerReviewScreen({super.key, required this.recordingId});
  final int recordingId;

  @override
  ConsumerState<SpeakerReviewScreen> createState() =>
      _SpeakerReviewScreenState();
}

class _SpeakerReviewScreenState extends ConsumerState<SpeakerReviewScreen> {
  bool _loading = true;
  String? _error;
  bool _saving = false;
  bool _regenerateSummary = false;

  final List<_SpeakerRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.controller.dispose();
      r.focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final api = ref.read(speakrApiProvider);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = await api.getRecordingSpeakers(widget.recordingId);
      if (!mounted) return;
      final parsed = _parseSpeakers(body);
      for (final r in _rows) {
        r.controller.dispose();
        r.focusNode.dispose();
      }
      _rows
        ..clear()
        ..addAll(parsed.map((s) {
          // Pre-fill the editable name with whatever the server already
          // suggests/has assigned. The label is shown read-only above the
          // field so the user can map it back to the transcript.
          final initial = s.identifiedName ?? '';
          return _SpeakerRow(
            label: s.label,
            identifiedName: s.identifiedName,
            segmentCount: s.segmentCount,
            controller: TextEditingController(text: initial),
            focusNode: FocusNode(),
          );
        }));
      setState(() => _loading = false);
    } on SpeakrApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Parses GET /recordings/{id}/speakers. Expected shape:
  ///   {"speakers": [{"label": "...", "identified_name": "..." | null,
  ///                   "segment_count": int, "speaker_id": int | null}],
  ///    "suggestions": {}}
  List<_ParsedSpeaker> _parseSpeakers(Map<String, dynamic> body) {
    final raw = body['speakers'];
    if (raw is! List) return const [];
    final out = <_ParsedSpeaker>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final label = entry['label']?.toString();
      if (label == null || label.isEmpty) continue;
      final identified = entry['identified_name'];
      final segCount = entry['segment_count'];
      out.add(_ParsedSpeaker(
        label: label,
        identifiedName:
            (identified is String && identified.isNotEmpty) ? identified : null,
        segmentCount: segCount is int ? segCount : null,
      ));
    }
    // Stable order: by descending segment count, then label.
    out.sort((a, b) {
      final byCount = (b.segmentCount ?? 0).compareTo(a.segmentCount ?? 0);
      return byCount != 0 ? byCount : a.label.compareTo(b.label);
    });
    return out;
  }

  Future<void> _apply() async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final api = container.read(speakrApiProvider);

    final speakerMap = <String, dynamic>{};
    for (final r in _rows) {
      final value = r.controller.text.trim();
      if (value.isEmpty) continue;
      if (value == r.label) continue; // unchanged from current label
      speakerMap[r.label] = value;
    }
    if (speakerMap.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No name changes to apply')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await api.assignSpeakers(
        widget.recordingId,
        speakerMap: speakerMap,
        regenerateSummary: _regenerateSummary,
      );
      container.invalidate(recordingDetailProvider(widget.recordingId));
      container.invalidate(allSpeakersProvider);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _regenerateSummary
                ? 'Speakers assigned — summary regenerating'
                : 'Speakers assigned',
          ),
        ),
      );
    } on SpeakrApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GhostIconButton(
                    icon: SpeakrIcon.back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: MonoEyebrow('Edit speakers', size: 10),
                    ),
                  ),
                  const SizedBox(width: 36), // balance the back button
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: SpeakrColors.ink, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoEyebrow('Couldn’t load speakers'),
            const SizedBox(height: 8),
            Text(_error!, style: SpeakrText.sans(size: 14)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: Text('Retry',
                  style: SpeakrText.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: SpeakrColors.ink)),
            ),
          ],
        ),
      );
    }
    if (_rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No speakers were detected in this recording.',
          style: SpeakrText.sans(size: 14, color: SpeakrColors.muted),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Text(
                'Rename each speaker as you’d like them to appear in the transcript, then apply.',
                style: SpeakrText.serif(
                  size: 14.5,
                  height: 1.45,
                  color: SpeakrColors.ink2,
                  style: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              for (final row in _rows) ...[
                _SpeakerField(row: row),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _regenerateSummary,
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _regenerateSummary = v),
                title: Text('Regenerate summary',
                    style: SpeakrText.sans(size: 14)),
                subtitle: Text(
                  'Rewrites the summary using the new names.',
                  style:
                      SpeakrText.sans(size: 12, color: SpeakrColors.muted),
                ),
                activeThumbColor: SpeakrColors.ink,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: const BoxDecoration(
            color: SpeakrColors.bg,
            border: Border(top: BorderSide(color: SpeakrColors.line)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _apply,
                style: FilledButton.styleFrom(
                  backgroundColor: SpeakrColors.ink,
                  foregroundColor: SpeakrColors.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SpeakrColors.bg,
                        ),
                      )
                    : Text(
                        'Apply',
                        style: SpeakrText.sans(
                          size: 14,
                          weight: FontWeight.w600,
                          color: SpeakrColors.bg,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParsedSpeaker {
  const _ParsedSpeaker({
    required this.label,
    required this.identifiedName,
    required this.segmentCount,
  });

  final String label;
  final String? identifiedName;
  final int? segmentCount;
}

class _SpeakerRow {
  _SpeakerRow({
    required this.label,
    required this.identifiedName,
    required this.segmentCount,
    required this.controller,
    required this.focusNode,
  });

  final String label;
  final String? identifiedName;
  final int? segmentCount;
  final TextEditingController controller;
  final FocusNode focusNode;
}

class _SpeakerField extends ConsumerWidget {
  const _SpeakerField({required this.row});
  final _SpeakerRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segs = row.segmentCount;
    final speakers = ref.watch(allSpeakersProvider).maybeWhen(
          data: (list) => list,
          orElse: () => const <Speaker>[],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: MonoEyebrow(row.label, size: 10)),
            if (segs != null) ...[
              const SizedBox(width: 8),
              Text(
                segs == 1 ? '1 segment' : '$segs segments',
                style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = constraints.maxWidth;
            return RawAutocomplete<Speaker>(
              textEditingController: row.controller,
              focusNode: row.focusNode,
              displayStringForOption: (s) => s.name,
              optionsBuilder: (TextEditingValue value) {
                if (speakers.isEmpty) return const Iterable<Speaker>.empty();
                final q = value.text.trim().toLowerCase();
                if (q.isEmpty) return speakers;
                return speakers
                    .where((s) => s.name.toLowerCase().contains(q));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: SpeakrText.sans(size: 14),
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: row.identifiedName ?? row.label,
                    hintStyle:
                        SpeakrText.sans(size: 14, color: SpeakrColors.muted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: SpeakrColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: SpeakrColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: SpeakrColors.ink, width: 1.2),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(4),
                      color: SpeakrColors.bg,
                      child: SizedBox(
                        width: fieldWidth,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 280),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SpeakrColors.line),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    child: Text(
                                      option.name,
                                      style: SpeakrText.sans(size: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
