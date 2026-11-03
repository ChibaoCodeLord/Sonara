import React from 'react';
import { useCatalog } from '../hooks/useCatalog';
import { usePlayerStore } from '../store/usePlayerStore';
import { TrackRow } from '../components/ui/TrackRow';
import { PageHeading, EmptyState, SectionHeading } from '../components/ui/Screen';
import { CatalogState } from '../components/ui/CatalogState';
import { playableTrack } from '../utils/catalogEntities';

export function ChartsPage() {
  const tracks = useCatalog();
  const play = usePlayerStore(s => s.playSong);
  const trending = tracks.filter(t => t.metadataSource === 'audius' && playableTrack(t));
  return <div className="ui-page"><PageHeading title="Khám phá đang thịnh hành" description="Các bản thu từ danh sách weekly trending của Audius tại thời điểm crawl. Chưa có bảng xếp hạng lượt nghe riêng của Sonara." /><CatalogState />
    <section><SectionHeading title="Audius · Weekly trending" />{trending.length ? <div className="ui-panel p-2">{trending.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div> : <EmptyState title="Chưa có dữ liệu thịnh hành" />}</section>
  </div>;
}
