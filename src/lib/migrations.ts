import { SCHEMA_VERSION } from '@/types';

/**
 * Shape of a versioned export produced by Settings > Export.
 */
export interface BackupEnvelope {
  version: number;
  exportedAt: string;
  data: Record<string, unknown>;
}

export const STORAGE_KEYS = [
  'prayer-intentions',
  'prayer-novenas',
  'prayer-logs',
  'prayer-date-override',
] as const;

export type StorageKey = typeof STORAGE_KEYS[number];

/**
 * A backup payload read from a file. The import path accepts both the new
 * versioned envelope and legacy unversioned dumps.
 */
export type ImportResult =
  | { ok: true; data: Record<string, unknown>; version: number }
  | { ok: false; error: string };

/**
 * Wraps the current localStorage state in a versioned envelope ready to be
 * serialized to JSON.
 */
export function buildExport(): BackupEnvelope {
  const data: Record<string, unknown> = {};
  for (const key of STORAGE_KEYS) {
    const raw = localStorage.getItem(key);
    if (raw === null) continue;
    try {
      data[key] = JSON.parse(raw);
    } catch {
      data[key] = raw;
    }
  }
  return {
    version: SCHEMA_VERSION,
    exportedAt: new Date().toISOString(),
    data,
  };
}

/**
 * Validates a parsed backup JSON blob and normalizes legacy (v0) exports
 * into the current schema shape. Returns a ready-to-apply data object on
 * success, or a descriptive error on failure.
 */
export function parseBackup(raw: unknown): ImportResult {
  if (!raw || typeof raw !== 'object') {
    return { ok: false, error: 'Backup file is not a valid JSON object.' };
  }

  const asEnvelope = raw as Partial<BackupEnvelope> & Record<string, unknown>;

  // Versioned envelope path.
  if (typeof asEnvelope.version === 'number' && asEnvelope.data && typeof asEnvelope.data === 'object') {
    const migrated = migrate(asEnvelope.data as Record<string, unknown>, asEnvelope.version);
    if (migrated.ok === false) {
      return { ok: false, error: migrated.error };
    }
    return { ok: true, data: migrated.data, version: SCHEMA_VERSION };
  }

  // Legacy path: the file is a flat object of storage keys.
  const flat = raw as Record<string, unknown>;
  const hasAnyKnownKey = STORAGE_KEYS.some((k) => k in flat);
  if (!hasAnyKnownKey) {
    return {
      ok: false,
      error: 'Backup file does not contain any recognized prayer data.',
    };
  }
  const migrated = migrate(flat, 0);
  if (migrated.ok === false) {
    return { ok: false, error: migrated.error };
  }
  return { ok: true, data: migrated.data, version: SCHEMA_VERSION };
}

/**
 * Applies a chain of migrations from `fromVersion` up to SCHEMA_VERSION.
 *
 * Currently the schema is v1 and no transforms are needed for v0 → v1
 * (the unversioned shape is a subset of v1), but this function is where
 * future migrations should live.
 */
function migrate(
  data: Record<string, unknown>,
  fromVersion: number
): { ok: true; data: Record<string, unknown> } | { ok: false; error: string } {
  let current = { ...data };
  let version = fromVersion;

  // Future: if (version < 2) { current = migrateV1toV2(current); version = 2; }

  if (version > SCHEMA_VERSION) {
    return {
      ok: false,
      error: `Backup is from a newer version (v${version}) than this app supports (v${SCHEMA_VERSION}).`,
    };
  }

  return { ok: true, data: current };
}

/**
 * Writes a migrated backup back to localStorage. Only keys in STORAGE_KEYS
 * are applied so arbitrary keys in a crafted file can't pollute storage.
 */
export function applyImport(data: Record<string, unknown>): void {
  for (const key of STORAGE_KEYS) {
    if (key in data) {
      localStorage.setItem(key, JSON.stringify(data[key]));
    }
  }
}
