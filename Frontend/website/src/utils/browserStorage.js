// A blocked/full browser store must not prevent forms and playback from working.
const fallback = new Map();
let temporary = false;
const markTemporary = () => {
  if (temporary) return;
  temporary = true;
  if (typeof window !== 'undefined') window.dispatchEvent(new Event('sonara-storage-fallback'));
};
export const isTemporaryStorage = () => temporary;
export const browserStorage = {
  getItem(key) { try { return globalThis.localStorage?.getItem(key) ?? fallback.get(key) ?? null; } catch { markTemporary(); return fallback.get(key) ?? null; } },
  setItem(key, value) { fallback.set(key,value); try { if (globalThis.localStorage) globalThis.localStorage.setItem(key,value); } catch { markTemporary(); } },
  removeItem(key) { fallback.delete(key); try { globalThis.localStorage?.removeItem(key); } catch { markTemporary(); } }
};
