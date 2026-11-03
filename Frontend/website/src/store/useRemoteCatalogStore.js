import { create } from 'zustand';
import { fetchActiveCatalog } from '../utils/remoteCatalog';

let inFlight;
export const useRemoteCatalogStore = create((set, get) => ({
  tracks: [], dataset: '', status: 'idle', error: '',
  load: (force = false) => {
    if (inFlight) return inFlight;
    if (!force && ['ready', 'error', 'partial'].includes(get().status)) return Promise.resolve();
    set({ status: 'loading', error: '' });
    const base = import.meta.env.VITE_CATALOG_API_URL || '/api/v1/catalog';
    inFlight = fetchActiveCatalog(fetch, base)
      .then(({ tracks, dataset }) => set({ tracks, dataset, status: 'ready', error: '' }))
      .catch(() => set({ status: 'error', error: 'Chưa tải được tuyển tập mới.' }))
      .finally(() => { inFlight = undefined; });
    return inFlight;
  }
}));
