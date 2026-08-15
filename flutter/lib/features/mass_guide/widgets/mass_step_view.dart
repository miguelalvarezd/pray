import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/mass/index.dart';

/// Renders one merged step group (1+ MassSteps that share a `mergeGroup`).
class MassStepGroupView extends StatelessWidget {
  const MassStepGroupView({
    super.key,
    required this.steps,
    required this.lang,
    this.secondaryLang,
  });

  final List<MassStep> steps;
  final Lang lang;
  final Lang? secondaryLang;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepBlock(step: steps[i], lang: lang, secondaryLang: secondaryLang),
            if (i < steps.length - 1) const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  const _StepBlock({required this.step, required this.lang, this.secondaryLang});
  final MassStep step;
  final Lang lang;
  final Lang? secondaryLang;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (step.kind == MassStepKind.complete) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: scheme.secondary),
            const SizedBox(height: 12),
            Text(
              'Mass Complete',
              style: GoogleFonts.newsreader(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (step.kind == MassStepKind.sectionHeader) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          step.title?.forLang(lang).toUpperCase() ?? '',
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: scheme.onTertiaryContainer,
          ),
        ),
      );
    }

    if (step.kind == MassStepKind.silence) {
      return Center(
        child: Column(
          children: [
            Text(
              '✝',
              style: TextStyle(fontSize: 22, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              step.text?.forLang(lang) ?? 'Silence',
              style: GoogleFonts.newsreader(
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.title != null)
          Text(
            step.title!.forLang(lang).toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              letterSpacing: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        if (step.title != null) const SizedBox(height: 6),
        if (step.kind == MassStepKind.response)
          _ResponseBlock(step: step, lang: lang, secondaryLang: secondaryLang)
        else
          _PrayerBlock(step: step, lang: lang, secondaryLang: secondaryLang),
      ],
    );
  }
}

/// Stacked bilingual text: primary language large, secondary smaller + muted below.
/// Guards against showing secondary when it is identical to primary (I18nText fallback).
/// The ✝ character is rendered larger and in the tertiary colour to match the
/// standalone cross used in silence steps.
class _DualText extends StatelessWidget {
  const _DualText({required this.primary, this.secondary});
  final String primary;
  final String? secondary;

  Widget _buildText(String text, TextStyle base, Color crossColor) {
    if (!text.contains('✝')) return Text(text, style: base);
    final parts = text.split('✝');
    final crossStyle = base.copyWith(
      fontSize: (base.fontSize ?? 17) + 3,
      color: crossColor,
      height: 1,
    );
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i], style: base));
      if (i < parts.length - 1) spans.add(TextSpan(text: '✝', style: crossStyle));
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          primary,
          GoogleFonts.newsreader(fontSize: 17, height: 1.5, color: scheme.onSurface),
          scheme.onSurfaceVariant,
        ),
        if (secondary != null && secondary != primary) ...[
          const SizedBox(height: 8),
          _buildText(
            secondary!,
            GoogleFonts.newsreader(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
            scheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _PrayerBlock extends StatelessWidget {
  const _PrayerBlock({required this.step, required this.lang, this.secondaryLang});
  final MassStep step;
  final Lang lang;
  final Lang? secondaryLang;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final speakerLabel = switch (step.speaker) {
      Speaker.priest => 'PRIEST',
      Speaker.all => 'ALL',
      Speaker.reader => 'READER',
      null => null,
    };

    final labelColor = switch (step.speaker) {
      Speaker.all => scheme.tertiary,
      Speaker.reader => scheme.onSurfaceVariant,
      _ => scheme.primary,
    };

    final primary = step.text?.forLang(lang) ?? '';
    final secondary = secondaryLang != null ? step.text?.forLang(secondaryLang!) : null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (speakerLabel != null) ...[
          Text(
            speakerLabel,
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        _DualText(primary: primary, secondary: secondary),
      ],
    );

    // ALL sections always rendered in a highlighted box for visual consistency.
    if (step.speaker == Speaker.all) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: content,
      );
    }

    return content;
  }
}

class _ResponseBlock extends StatelessWidget {
  const _ResponseBlock({required this.step, required this.lang, this.secondaryLang});
  final MassStep step;
  final Lang lang;
  final Lang? secondaryLang;

  /// Splits call+response text into parallel exchange pairs.
  /// Tries paragraph breaks (\n\n) first, then line breaks (\n).
  /// Returns null if the text is a single block or lines don't match.
  ({String sep, List<String> call, List<String> response})? _detectExchanges(
      String call, String response) {
    // Paragraph-style (e.g. Penitential Form B)
    if (call.contains('\n\n')) {
      final c = call.split('\n\n');
      final r = response.split('\n\n');
      if (c.length > 1 && c.length == r.length) {
        return (sep: '\n\n', call: c, response: r);
      }
    }
    // Line-by-line style (e.g. Preface Dialogue)
    if (call.contains('\n')) {
      final c = call.split('\n');
      final r = response.split('\n');
      if (c.length > 1 && c.length == r.length) {
        return (sep: '\n', call: c, response: r);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final callPrimary = step.call?.forLang(lang) ?? '';
    final callSecondary = secondaryLang != null ? step.call?.forLang(secondaryLang!) : null;
    final responsePrimary = step.response?.forLang(lang) ?? '';
    final responseSecondary =
        secondaryLang != null ? step.response?.forLang(secondaryLang!) : null;

    final exchanges = _detectExchanges(callPrimary, responsePrimary);

    if (exchanges != null) {
      // Split secondary with the same separator if it produces a matching count
      final callSecParts = callSecondary?.split(exchanges.sep);
      final responseSecParts = responseSecondary?.split(exchanges.sep);
      final callSecMatch = callSecParts?.length == exchanges.call.length;
      final responseSecMatch = responseSecParts?.length == exchanges.response.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < exchanges.call.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            if (step.call != null) ...[
              Text(
                'PRIEST',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              _DualText(
                primary: exchanges.call[i],
                secondary: callSecMatch ? callSecParts![i] : null,
              ),
              const SizedBox(height: 12),
            ],
            if (step.response != null)
              _AllLane(
                primary: exchanges.response[i],
                secondary: responseSecMatch ? responseSecParts![i] : null,
                scheme: scheme,
              ),
          ],
        ],
      );
    }

    // Single exchange
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (step.call != null) ...[
          Text(
            'PRIEST',
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          _DualText(primary: callPrimary, secondary: callSecondary),
          const SizedBox(height: 12),
        ],
        if (step.response != null)
          _AllLane(
            primary: responsePrimary,
            secondary: responseSecondary,
            scheme: scheme,
          ),
      ],
    );
  }
}

/// Highlighted box used for ALL congregational text.
class _AllLane extends StatelessWidget {
  const _AllLane({
    required this.primary,
    this.secondary,
    required this.scheme,
  });

  final String primary;
  final String? secondary;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALL',
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(height: 6),
          _DualText(primary: primary, secondary: secondary),
        ],
      ),
    );
  }
}
