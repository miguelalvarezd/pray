import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/time/current_date_provider.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/backup/backup_envelope.dart';
import '../../data/backup/backup_service.dart';
import '../../data/boxes.dart';
import '../../data/providers.dart';
import '../../data/repositories/intentions_repo.dart';
import '../../data/repositories/logs_repo.dart';
import '../../data/repositories/novenas_repo.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _flash;
  bool _flashIsError = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFlash(String msg, {bool isError = false}) {
    setState(() {
      _flash = msg;
      _flashIsError = isError;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _flash == msg) setState(() => _flash = null);
    });
  }

  Future<void> _handleExport() async {
    final boxes = ref.read(appBoxesProvider);
    final service = BackupService(boxes);
    final envelope = service.buildExport();
    final json = const JsonEncoder.withIndent('  ').convert(envelope.toJson());
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final filename = 'prayer-backup-v$kSchemaVersion-$dateStr.json';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: filename,
      ),
    );
    _showFlash('Exported');
  }

  Future<void> _handleImport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    try {
      final raw = await File(result.files.single.path!).readAsString();
      final parsed = jsonDecode(raw);
      final boxes = ref.read(appBoxesProvider);
      final service = BackupService(boxes);
      final outcome = service.parseBackup(parsed);
      switch (outcome) {
        case ImportFail(:final error):
          _showFlash(error, isError: true);
        case ImportOk(:final data):
          await service.applyImport(data);
          // Force the data providers to re-read from boxes.
          ref.invalidate(intentionsProvider);
          ref.invalidate(novenasProvider);
          ref.invalidate(logsProvider);
          _showFlash('Imported');
      }
    } catch (e) {
      _showFlash('Could not parse backup file.', isError: true);
    }
  }

  Future<void> _pickDateOverride() async {
    final box = ref.read(settingsBoxProvider);
    final current = box.get(SettingsKeys.dateOverride) as String?;
    final initial =
        current != null ? DateTime.parse(current) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 5),
      lastDate: DateTime(initial.year + 5),
    );
    if (picked == null) return;
    await box.put(
      SettingsKeys.dateOverride,
      DateFormat('yyyy-MM-dd').format(picked),
    );
    ref.invalidate(currentDateProvider);
    setState(() {});
  }

  Future<void> _clearDateOverride() async {
    await ref.read(settingsBoxProvider).delete(SettingsKeys.dateOverride);
    ref.invalidate(currentDateProvider);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scrollTriggersProvider.select((m) => m[4] ?? 0),
      (_, _) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubicEmphasized,
          );
        }
      },
    );
    final scheme = Theme.of(context).colorScheme;
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final settingsBox = ref.watch(settingsBoxProvider);
    final dateOverride = settingsBox.get(SettingsKeys.dateOverride) as String?;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          controller: _scrollController,

          cacheExtent: 300,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 96),
          children: [
            _Header(scheme: scheme),
            const SizedBox(height: 28),
            _Section(
              title: 'Appearance',
              subtitle: 'Customize how the app looks.',
              child: Row(
                children: [
                  for (final entry in const [
                    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
                    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                    (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
                  ]) ...[
                    Expanded(
                      child: _ThemePill(
                        label: entry.$2,
                        icon: entry.$3,
                        selected: mode == entry.$1,
                        onTap: () => controller.set(entry.$1),
                      ),
                    ),
                    if (entry != const (ThemeMode.system, 'System', Icons.brightness_auto_outlined))
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Data & Backup',
              subtitle: 'Export or import your prayer data.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          label: 'Export',
                          icon: Icons.upload_outlined,
                          onTap: _handleExport,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTile(
                          label: 'Import',
                          icon: Icons.download_outlined,
                          onTap: _handleImport,
                        ),
                      ),
                    ],
                  ),
                  if (_flash != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _flashIsError
                            ? scheme.errorContainer.withValues(alpha: 0.4)
                            : scheme.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _flashIsError
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 18,
                            color: _flashIsError
                                ? scheme.error
                                : scheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _flash!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _flashIsError
                                    ? scheme.error
                                    : scheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Your data stays on this device. Export regularly to avoid losing it.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Developer Mode',
              subtitle: 'Override the current date for testing.',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIMULATE DATE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDateOverride,
                            icon: const Icon(Icons.calendar_today_outlined,
                                size: 16),
                            label: Text(
                              dateOverride ?? 'Pick a date',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        if (dateOverride != null) ...[
                          const SizedBox(width: 10),
                          FilledButton.tonal(
                            onPressed: _clearDateOverride,
                            child: const Text('Reset'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'About',
              subtitle: null,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prayer & Intention Tracker helps you maintain a consistent prayer life. Your data is stored locally on your device for privacy.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Intentions are automatically sorted by urgency. High priority items and those with approaching target dates appear at the top.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
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

class _Header extends StatelessWidget {
  const _Header({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BE STILL AND KNOW THAT I AM GOD',
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Settings',
          style: GoogleFonts.newsreader(
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.manrope(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.secondaryContainer : scheme.surfaceContainerLow;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Icon(icon, size: 22, color: scheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
