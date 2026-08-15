import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/models/daily_log.dart';
import '../../../data/repositories/logs_repo.dart';

class GratitudeJournal extends ConsumerStatefulWidget {
  const GratitudeJournal({super.key});

  @override
  ConsumerState<GratitudeJournal> createState() => _GratitudeJournalState();
}

class _GratitudeJournalState extends ConsumerState<GratitudeJournal> {
  late final TextEditingController _controller;
  Timer? _debounce;
  String? _seededFor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _seedIfNeeded(String dateStr, String value) {
    if (_seededFor != dateStr) {
      _seededFor = dateStr;
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void _onChanged(String dateStr, String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final notifier = ref.read(logsProvider.notifier);
      final current = notifier.forDate(dateStr);
      notifier.save(current.copyWith(journal: value.isEmpty ? null : value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final log = ref.watch(logsProvider)[dateStr] ?? DailyLog(date: dateStr);
    _seedIfNeeded(dateStr, log.journal ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gratitude Journal',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          onChanged: (v) => _onChanged(dateStr, v),
          decoration: InputDecoration(
            hintText: "What are you grateful for today?",
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
