import { create } from 'zustand';
import { browserStorage } from '../utils/browserStorage';

const key = 'sonara-theme';
const valid = value => ['light', 'dark', 'system'].includes(value);
const systemDark = () => typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches;
export const resolveTheme = (preference, dark = systemDark()) => preference === 'dark' || (preference !== 'light' && dark) ? 'dark' : 'light';
function apply(preference) {
  const resolved = resolveTheme(preference);
  if (typeof document !== 'undefined') {
    document.documentElement.dataset.theme = resolved;
    document.documentElement.classList.toggle('dark', resolved === 'dark');
    document.documentElement.style.colorScheme = resolved;
  }
  return resolved;
}
const saved = browserStorage.getItem(key);
const initial = valid(saved) ? saved : 'system';
export const useThemeStore = create((set, get) => ({
  preference: initial, resolved: resolveTheme(initial),
  setPreference: preference => {
    if (!valid(preference)) return;
    browserStorage.setItem(key, preference);
    set({ preference, resolved: apply(preference) });
  },
  toggle: () => get().setPreference(get().resolved === 'dark' ? 'light' : 'dark'),
  sync: () => set({ resolved: apply(get().preference) }),
  receive: value => { const preference = valid(value) ? value : 'system'; set({ preference, resolved: apply(preference) }); }
}));

export function watchTheme() {
  useThemeStore.getState().sync();
  const media = window.matchMedia('(prefers-color-scheme: dark)');
  const onSystem = () => { if (useThemeStore.getState().preference === 'system') useThemeStore.getState().sync(); };
  const onStorage = event => { if (event.key === key || event.key === null) useThemeStore.getState().receive(event.newValue); };
  media.addEventListener('change', onSystem);
  window.addEventListener('storage', onStorage);
  return () => { media.removeEventListener('change', onSystem); window.removeEventListener('storage', onStorage); };
}
