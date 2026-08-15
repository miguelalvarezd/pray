import 'package:flutter/material.dart';

import '../../../domain/mass/index.dart';

const _unset = Object();

class MassSettings {
  final MassOptions options;
  final Lang lang;
  final Lang? secondaryLang;

  const MassSettings({
    required this.options,
    required this.lang,
    this.secondaryLang,
  });

  MassSettings copyWith({
    MassOptions? options,
    Lang? lang,
    Object? secondaryLang = _unset,
  }) =>
      MassSettings(
        options: options ?? this.options,
        lang: lang ?? this.lang,
        secondaryLang:
            secondaryLang == _unset ? this.secondaryLang : secondaryLang as Lang?,
      );
}

Future<MassSettings?> showMassSettingsSheet(
  BuildContext context, {
  required MassSettings current,
}) {
  return showModalBottomSheet<MassSettings>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SettingsSheet(initial: current),
  );
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.initial});
  final MassSettings initial;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late MassSettings _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mass options', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _SectionLabel('Primary Language'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final l in Lang.values)
                  ChoiceChip(
                    label: Text(l.native),
                    selected: _draft.lang == l,
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(
                        lang: l,
                        // clear secondary if it now matches primary
                        secondaryLang:
                            _draft.secondaryLang == l ? null : _draft.secondaryLang,
                      );
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Secondary Language'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('None'),
                  selected: _draft.secondaryLang == null,
                  onSelected: (_) =>
                      setState(() => _draft = _draft.copyWith(secondaryLang: null)),
                ),
                for (final l in Lang.values)
                  ChoiceChip(
                    label: Text(l.native),
                    selected: _draft.secondaryLang == l,
                    onSelected: l == _draft.lang
                        ? null
                        : (_) => setState(
                              () => _draft = _draft.copyWith(secondaryLang: l),
                            ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Penitential Act'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final v in PenitentialVariant.values)
                  ChoiceChip(
                    label: Text(penitentialVariantLabels[v]!.forLang(_draft.lang)),
                    selected: _draft.options.penitential == v,
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(
                          options: _draft.options.copyWith(penitential: v));
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Profession of Faith'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final v in CreedVariant.values)
                  ChoiceChip(
                    label: Text(creedVariantLabels[v]!.forLang(_draft.lang)),
                    selected: _draft.options.creed == v,
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(
                          options: _draft.options.copyWith(creed: v));
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Eucharistic Prayer'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final v in EucharisticVariant.values)
                  ChoiceChip(
                    label: Text(eucharisticVariantLabels[v]!.forLang(_draft.lang)),
                    selected: _draft.options.eucharistic == v,
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(
                          options: _draft.options.copyWith(eucharistic: v));
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('Mystery of Faith'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final v in MysteryOfFaithVariant.values)
                  ChoiceChip(
                    label: Text(mysteryOfFaithVariantLabels[v]!.forLang(_draft.lang)),
                    selected: _draft.options.mysteryOfFaith == v,
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(
                          options: _draft.options.copyWith(mysteryOfFaith: v));
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_draft),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
