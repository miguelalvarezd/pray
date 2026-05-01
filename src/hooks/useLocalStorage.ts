import { useState, useEffect, useCallback, useRef } from 'react';

/**
 * A localStorage-backed React state hook that is safe against
 * concurrent writes from multiple tabs.
 *
 * Two guarantees on top of a naive implementation:
 *
 * 1. Every write re-reads the current value from localStorage before
 *    applying a functional updater, so a second tab that started from
 *    stale React state won't clobber fields written by the first tab.
 *
 * 2. A `storage` event listener keeps the local React state in sync with
 *    writes made by other tabs to the same key.
 */
export function useLocalStorage<T>(key: string, initialValue: T) {
  const initialRef = useRef(initialValue);

  const readValue = useCallback((): T => {
    if (typeof window === 'undefined') return initialRef.current;
    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialRef.current;
    } catch (error) {
      console.warn(`Error reading localStorage key "${key}":`, error);
      return initialRef.current;
    }
  }, [key]);

  const [storedValue, setStoredValue] = useState<T>(readValue);

  const setValue = useCallback(
    (value: T | ((val: T) => T)) => {
      try {
        // Re-read the current value from storage so we never overwrite
        // updates written by another tab between render and commit.
        const current = readValue();
        const next =
          value instanceof Function ? (value as (v: T) => T)(current) : value;
        setStoredValue(next);
        if (typeof window !== 'undefined') {
          const serialized = JSON.stringify(next);
          window.localStorage.setItem(key, serialized);
        }
      } catch (error) {
        console.warn(`Error setting localStorage key "${key}":`, error);
      }
    },
    [key, readValue]
  );

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const handleStorage = (event: StorageEvent) => {
      if (event.key !== key) return;
      if (event.newValue === null) {
        setStoredValue(initialRef.current);
        return;
      }
      try {
        setStoredValue(JSON.parse(event.newValue) as T);
      } catch (error) {
        console.warn(`Error parsing storage event for "${key}":`, error);
      }
    };
    window.addEventListener('storage', handleStorage);
    return () => window.removeEventListener('storage', handleStorage);
  }, [key]);

  return [storedValue, setValue] as const;
}
