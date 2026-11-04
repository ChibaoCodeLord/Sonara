import React from 'react';
import { useParams } from 'react-router-dom';
import { Play, UserPlus, UserCheck } from 'lucide-react';
import { useCatalogEntities } from '../hooks/useCatalogEntities';
import { usePlayerStore } from '../store/usePlayerStore';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { TrackRow } from '../components/ui/TrackRow';
import { CatalogState } from '../components/ui/CatalogState';
import { SectionHeading, ContentCard, NotFound } from '../components/ui/Screen';
import { sourceLabels, playableTrack } from '../utils/catalogEntities';

export function ArtistDetailPage() {
  const { id } = useParams();
  const { tracks, artists, albums } = useCatalogEntities();
  const status = useRemoteCatalogStore(s => s.status);
  const followed = usePlayerStore(s => s.followedArtistIds), follow = usePlayerStore(s => s.toggleFollow), queue = usePlayerStore(s => s.setQueue), play = usePlayerStore(s => s.playSong);
  const artist = artists.find(a => a.id === id);
  if (!artist) return status !== 'ready' ? <CatalogState /> : <NotFound title="Không tìm thấy nghệ sĩ" />;
  const songs = tracks.filter(t => artist.topTrackIds.includes(t.id));
  const releases = albums.filter(a => artist.albumIds?.includes(a.id) || a.songIds.some(key => artist.topTrackIds.includes(key)));
  return <div className="ui-page"><div className="ui-split-hero"><img src={artist.avatarUrl} alt="" /><div className="min-w-0"><p className="ui-eyebrow">NGHỆ SĨ / CREDIT · {sourceLabels[artist.source]}</p><h1>{artist.name}</h1><p className="ui-description">{songs.length} bản ghi trong catalog hiện tại</p></div></div>
    <div className="ui-actions"><button className="ui-button" disabled={!songs.some(playableTrack)} onClick={() => queue(songs.filter(playableTrack))}><Play size={17} />Phát các bài có audio</button><button className="ui-button ui-button-secondary" aria-pressed={followed.includes(id)} onClick={() => follow(id)}>{followed.includes(id) ? <UserCheck size={17} /> : <UserPlus size={17} />}{followed.includes(id) ? 'Đang theo dõi' : 'Theo dõi'}</button></div>
    <section><SectionHeading title="Bản thu" /><div className="ui-panel p-2">{songs.map((song,index) => <TrackRow key={song.id} song={song} index={index} onPlay={() => play(song)} />)}</div></section>
    <section><SectionHeading title="Bản phát hành" /><div className="ui-grid">{releases.map(a => <ContentCard key={a.id} to={`/album/${a.id}`} title={a.title} subtitle={a.year} image={a.coverUrl} />)}</div></section>
  </div>;
}
