import { useEffect } from 'react';
import { useAppStore } from '../store/useAppStore';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { createTestLibrary, normalizeEmail, testLibraryEmail, testLibraryVersion } from '../utils/testLibrary';

export function useTestLibrary() {
  const email = useAppStore(state => state.session?.email), marker = useAppStore(state => state.libraryTestSeed);
  const owner = useAppStore(state => state.profile.name), seed = useAppStore(state => state.seedTestLibrary);
  const tracks = useRemoteCatalogStore(state => state.tracks), status = useRemoteCatalogStore(state => state.status), dataset = useRemoteCatalogStore(state => state.dataset);
  useEffect(() => {
    if (normalizeEmail(email) !== testLibraryEmail || marker?.version === testLibraryVersion || status !== 'ready') return;
    const fixture = createTestLibrary(tracks, { email, owner, dataset });
    if (fixture) seed(fixture);
  }, [email, marker, owner, seed, tracks, status, dataset]);
}
