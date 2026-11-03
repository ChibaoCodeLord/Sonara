import { useMemo } from 'react';
import { useCatalog } from './useCatalog';
import { deriveCatalogEntities } from '../utils/catalogEntities';

export function useCatalogEntities() {
  const tracks = useCatalog();
  const entities = useMemo(() => deriveCatalogEntities(tracks), [tracks]);
  return { tracks, ...entities };
}
