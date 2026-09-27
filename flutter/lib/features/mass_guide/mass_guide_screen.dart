import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/current_date_provider.dart';
import '../../core/time/logical_day.dart';
import '../../data/settings/mass_lang.dart';
import '../../data/boxes.dart';
import '../../data/providers.dart';
import '../../data/repositories/logs_repo.dart';
import '../../domain/mass/index.dart';
import 'sheets/mass_settings_sheet.dart';
import 'widgets/mass_step_view.dart';

class MassGuideScreen extends ConsumerStatefulWidget {
  const MassGuideScreen({super.key});

  @override
  ConsumerState<MassGuideScreen> createState() => _MassGuideScreenState();
}

class _MassGuideScreenState extends ConsumerState<MassGuideScreen> {
  final _pageController = PageController();
  late MassSettings _settings;
  late List<StepGroup> _groups;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _settings = _loadPersistedSettings();
    _rebuild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _restorePageIndex();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  MassSettings _loadPersistedSettings() {
    final box = ref.read(settingsBoxProvider);
    final langName = box.get(SettingsKeys.massLang) as String?;
    final secondaryName = box.get(SettingsKeys.massSecondaryLang) as String?;
    final lang = langName != null
        ? (Lang.values.where((l) => l.name == langName).firstOrNull ?? Lang.en)
        : Lang.en;
    final secondaryLang = secondaryName != null
        ? Lang.values.where((l) => l.name == secondaryName).firstOrNull
        : null;
    return MassSettings(
      options: kDefaultMassOptions,
      lang: lang,
      secondaryLang: secondaryLang,
    );
  }

  void _restorePageIndex() {
    final box = ref.read(settingsBoxProvider);
    final savedDate = box.get(SettingsKeys.massPageDate) as String?;
    final today = formatLogDate(ref.read(currentDateProvider));
    if (savedDate != today) return;
    final savedIndex = box.get(SettingsKeys.massPageIndex) as int?;
    if (savedIndex != null && savedIndex > 0 && savedIndex < _groups.length) {
      _pageController.jumpToPage(savedIndex);
    }
  }

  void _saveSettings(MassSettings s) {
    final box = ref.read(settingsBoxProvider);
    box.put(SettingsKeys.massLang, s.lang.name);
    ref.invalidate(massLangProvider);
    if (s.secondaryLang != null) {
      box.put(SettingsKeys.massSecondaryLang, s.secondaryLang!.name);
    } else {
      box.delete(SettingsKeys.massSecondaryLang);
    }
  }

  void _savePageIndex(int index) {
    final box = ref.read(settingsBoxProvider);
    final today = formatLogDate(ref.read(currentDateProvider));
    box.put(SettingsKeys.massPageIndex, index);
    box.put(SettingsKeys.massPageDate, today);
  }

  void _rebuild() {
    final steps = generateMassSteps(_settings.options);
    _groups = groupMassSteps(steps);
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _groups.length - 1);
    if (next == _index) return;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openSettings() async {
    final updated = await showMassSettingsSheet(context, current: _settings);
    if (updated == null) return;
    setState(() {
      _settings = updated;
      _rebuild();
      if (_index >= _groups.length) _index = _groups.length - 1;
      _pageController.jumpToPage(_index);
    });
    _saveSettings(updated);
  }

  Future<void> _markComplete() async {
    final today = ref.read(currentDateProvider);
    final dateStr = formatLogDate(today);
    await ref.read(logsProvider.notifier).togglePrayer(dateStr, 'mass');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final group = _groups[_index];
    final isComplete =
        group.length == 1 && group.first.kind == MassStepKind.complete;
    final currentSection = group.first.section;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              sectionLabels[currentSection]!.forLang(_settings.lang),
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Step ${_index + 1} / ${_groups.length}',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mass options',
            onPressed: _openSettings,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _groups.length,
              minHeight: 3,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: scheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _groups.length,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  _savePageIndex(i);
                },
                itemBuilder: (_, i) => MassStepGroupView(
                  steps: _groups[i],
                  lang: _settings.lang,
                  secondaryLang: _settings.secondaryLang,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: FilledButton.tonal(
                        onPressed: _index == 0 ? null : () => _go(-1),
                        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Icon(Icons.chevron_left, size: 28),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: isComplete
                          ? FilledButton.icon(
                              onPressed: _markComplete,
                              icon: const Icon(Icons.check),
                              label: const Text('Mark Mass as attended'),
                            )
                          : FilledButton.tonal(
                              onPressed: _index >= _groups.length - 1
                                  ? null
                                  : () => _go(1),
                              child: const Text('Next'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
