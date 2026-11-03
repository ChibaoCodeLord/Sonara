import { useEffect } from 'react';
import { useAppStore } from '../store/useAppStore';
import { mediaRequest } from '../utils/mediaApi';

// Imports continue while browsing other pages; a reload resumes pending job IDs.
export function useMediaImportSync() {
  const pending = useAppStore(state => state.pendingImportIds);
  useEffect(() => {
    if (!pending.length) return;
    const controller = new AbortController(); let timer;
    const sync = async () => {
      await Promise.all(pending.map(async id => {
        try {
          const job = await mediaRequest(`/jobs/${id}`, { signal: controller.signal });
          if (controller.signal.aborted) return;
          if (job.status === 'ready' && job.track) useAppStore.getState().saveImportedTrack(job.track);
          else if (['failed', 'cancelled'].includes(job.status)) useAppStore.getState().finishImport(id);
        } catch (error) { if (!controller.signal.aborted && error.status === 404) useAppStore.getState().finishImport(id); }
      }));
      if (!controller.signal.aborted) timer = setTimeout(sync, 5000);
    };
    void sync();
    return () => { controller.abort(); clearTimeout(timer); };
  }, [pending]);
}
