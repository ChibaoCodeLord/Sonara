import React from 'react';
import { Link } from 'react-router-dom';
import { Play, Pause } from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { playableTrack, playbackLabel } from '../../utils/catalogEntities';

export function YouTubeTrackCard({ track, tracks = [track], index = 0 }) {
  const current = usePlayerStore(s => s.currentSong?.id === track.id), playing = usePlayerStore(s => s.isPlaying);
  const canPlay = playableTrack(track);
  const play = () => current ? usePlayerStore.getState().togglePlay() : usePlayerStore.getState().setQueue(tracks,Math.max(0,index));
  return <article className="ui-content-card youtube-track-card"><div className="relative"><Link to={`/track/${track.id}`} aria-label={`Chi tiết ${track.title}`}><img src={track.coverUrl || '/images/catalog-placeholder.svg'} alt="" loading="lazy" /></Link>
    {canPlay && <button className="youtube-card-play" aria-label={`${current && playing ? 'Tạm dừng' : 'Phát'} ${track.title}`} onClick={play}>{current && playing ? <Pause size={18} fill="currentColor" /> : <Play size={18} fill="currentColor" />}</button>}</div>
    <Link className="youtube-track-title" to={`/track/${track.id}`}>{track.title}</Link><p>{track.artist}</p>
    {!canPlay && <span className="youtube-source">{playbackLabel(track)}</span>}
  </article>;
}
