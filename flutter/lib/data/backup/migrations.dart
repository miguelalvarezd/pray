/// Transforms backup data from one schema version to the next. Step `n` in
/// a chain (0-based) migrates data at version `n` to version `n + 1`.
/// [today] is the current Day, for steps that depend on it.
typedef MigrationStep = Map<String, dynamic> Function(
  Map<String, dynamic> data,
  DateTime today,
);

/// The production migration chain. Add one step per schema change; the
/// schema version is always the length of this list.
const List<MigrationStep> kMigrationSteps = [
  identityStep,
  intentionStatusStep,
  answeredIntentionsStep,
  novenaIntentionsStep,
];

/// Schema version for exported backups and for data stored on the device.
/// Version 1 matches `SCHEMA_VERSION` in `src/types.ts`.
final int kSchemaVersion = kMigrationSteps.length;

/// v0 → v1: the unversioned React shape is already a subset of v1.
Map<String, dynamic> identityStep(Map<String, dynamic> data, DateTime today) =>
    data;

/// v1 → v2: the `isArchived` flag becomes an Intention `status`.
Map<String, dynamic> intentionStatusStep(
  Map<String, dynamic> data,
  DateTime today,
) =>
    _mapIntentions(data, (i) {
      final archived = i.remove('isArchived');
      if (archived is bool) i['status'] = archived ? 'archived' : 'active';
      return i;
    });

/// v2 → v3: adds the Answered status with its Day and note. Nothing to
/// transform; the version bump keeps older apps from misreading Answered
/// Intentions as active.
Map<String, dynamic> answeredIntentionsStep(
  Map<String, dynamic> data,
  DateTime today,
) =>
    data;

/// v3 → v4: each Novena's free-text intention becomes a linked Intention.
/// Novenas with the same text (trimmed, case-insensitive) share one. The new
/// Intention is Archived if every Novena sharing it has finished its nine
/// Days by [today], and active otherwise.
Map<String, dynamic> novenaIntentionsStep(
  Map<String, dynamic> data,
  DateTime today,
) {
  final novenas = data['prayer-novenas'];
  if (novenas is! List) return data;

  final intentions = [
    for (final raw in (data['prayer-intentions'] as List?) ?? const [])
      Map<String, dynamic>.from(raw as Map),
  ];
  final created = <String, Map<String, dynamic>>{};
  final migratedNovenas = <Map<String, dynamic>>[];

  for (final raw in novenas) {
    final novena = Map<String, dynamic>.from(raw as Map);
    final text = (novena.remove('intention') as String?)?.trim() ?? '';
    migratedNovenas.add(novena);
    if (text.isEmpty || novena['intentionId'] != null) continue;

    final finished = _novenaFinished(novena['startDate'] as String, today);
    final intention = created.putIfAbsent(text.toLowerCase(), () {
      final i = <String, dynamic>{
        'id': 'novena-intention-${novena['id']}',
        'title': text,
        'createdAt': novena['createdAt'],
        'priority': 'medium',
        'status': 'archived',
      };
      intentions.add(i);
      return i;
    });
    if (!finished) intention['status'] = 'active';
    novena['intentionId'] = intention['id'];
  }

  return {
    ...data,
    'prayer-novenas': migratedNovenas,
    if (intentions.isNotEmpty) 'prayer-intentions': intentions,
  };
}

bool _novenaFinished(String startDate, DateTime today) {
  final start = DateTime.parse(startDate);
  final days = DateTime.utc(today.year, today.month, today.day)
      .difference(DateTime.utc(start.year, start.month, start.day))
      .inDays;
  return days >= 9;
}

Map<String, dynamic> _mapIntentions(
  Map<String, dynamic> data,
  Map<String, dynamic> Function(Map<String, dynamic>) f,
) {
  final list = data['prayer-intentions'];
  if (list is! List) return data;
  return {
    ...data,
    'prayer-intentions': [
      for (final raw in list) f(Map<String, dynamic>.from(raw as Map)),
    ],
  };
}
