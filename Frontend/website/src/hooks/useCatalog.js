import { useAppStore } from '../store/useAppStore';
import { useEffect, useMemo } from 'react';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { mergeCatalog } from '../utils/remoteCatalog';
import { forAudioPlayback } from '../utils/audioCatalog';

export function useCatalog() {
  const imported = useAppStore(state => state.importedTracks);
  const audioVersions = useAppStore(state => state.audioVersions);
  const remote = useRemoteCatalogStore(state => state.tracks);
  const load = useRemoteCatalogStore(state => state.load);
  useEffect(() => { load(); }, [load]);
  return useMemo(() => mergeCatalog(remote, imported).map(track => forAudioPlayback(track, audioVersions[track.youtubeId])), [remote, imported, audioVersions]);
}
