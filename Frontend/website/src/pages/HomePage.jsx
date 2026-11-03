import React from 'react';
import { Link } from 'react-router-dom';
import { Headphones, ArrowRight, Flame, Disc3, Mic2, Sparkles, Music, Radio } from 'lucide-react';
import { useCatalogEntities } from '../hooks/useCatalogEntities';
import { useRemoteCatalogStore } from '../store/useRemoteCatalogStore';
import { SectionHeading, ContentCard } from '../components/ui/Screen';
import { CatalogState } from '../components/ui/CatalogState';
import { YouTubeTrackCard } from '../components/ui/YouTubeTrackCard';
import { playableTrack, sourceLabels } from '../utils/catalogEntities';

export function HomePage() {
  const { tracks, albums, artists } = useCatalogEntities();
  const ready = useRemoteCatalogStore(s => s.status === 'ready');
  const audio = tracks.filter(playableTrack);

  // 1. Phân nhóm các bài hát theo thể loại và độ phổ biến
  const popularTracks = React.useMemo(() => {
    return [...audio].sort((a, b) => (b.popularity || 0) - (a.popularity || 0)).slice(0, 8);
  }, [audio]);

  const popTracks = React.useMemo(() => {
    return audio.filter(t => (t.genre || '').toLowerCase().includes('pop')).slice(0, 8);
  }, [audio]);

  const rockAlternativeTracks = React.useMemo(() => {
    return audio.filter(t => {
      const g = (t.genre || '').toLowerCase();
      return g.includes('rock') || g.includes('alternative') || g.includes('metal');
    }).slice(0, 8);
  }, [audio]);

  const acousticSoundtrackTracks = React.useMemo(() => {
    return audio.filter(t => {
      const g = (t.genre || '').toLowerCase();
      return g.includes('soundtrack') || g.includes('classical') || g.includes('score') || g.includes('instrumental') || g.includes('new age');
    }).slice(0, 8);
  }, [audio]);

  const vietnameseTracks = React.useMemo(() => {
    return tracks.filter(t => t.region === 'VN');
  }, [tracks]);

  // Lọc Album và Artist có ảnh chất lượng cao
  const validAlbums = React.useMemo(() => {
    return albums.filter(a => a.coverUrl && !a.coverUrl.includes('placeholder')).slice(0, 6);
  }, [albums]);

  const validArtists = React.useMemo(() => {
    return artists.filter(a => a.avatarUrl && !a.avatarUrl.includes('placeholder')).slice(0, 6);
  }, [artists]);

  // Các thể loại có bài trong catalog
  const popularGenres = React.useMemo(() => {
    const counts = {};
    for (const t of tracks) {
      if (t.genre) counts[t.genre] = (counts[t.genre] || 0) + 1;
    }
    return Object.entries(counts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8);
  }, [tracks]);

  return (
    <div className="ui-page home-page max-w-7xl mx-auto space-y-10">
      {/* Hero Section */}
      <section className="home-hero theme-inverse relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#9A1B2F] via-[#B3122E] to-[#E11D48] text-white border border-rose-500/30 p-8 sm:p-12 shadow-xl">
        <p className="ui-eyebrow text-rose-100 flex items-center gap-2">
          <Headphones size={18} /> KHÁM PHÁ ÂM NHẠC SONARA
        </p>
        <h1 className="text-3xl sm:text-5xl font-black mt-4 max-w-2xl leading-tight">
          Kho âm nhạc chất lượng cao Cloudinary
        </h1>
        <p className="text-white/85 mt-4 max-w-xl text-base sm:text-lg">
          Trải nghiệm 300 tuyệt phẩm âm nhạc quốc tế với âm thanh chân thực, hình ảnh album sắc nét và phát trực tiếp mượt mà.
        </p>
        <div className="flex flex-wrap items-center gap-4 mt-6">
          <Link className="ui-button bg-white text-rose-900 font-bold hover:bg-rose-50 shadow-md" to="/youtube">
            Khám phá toàn bộ <ArrowRight size={17} />
          </Link>
          <span className="text-sm text-white/70">
            {tracks.length} bài hát · {albums.length} album · {artists.length} nghệ sĩ
          </span>
        </div>
      </section>

      <CatalogState />

      {ready && (
        <div className="space-y-12">
          {/* Thanh thể loại nổi bật */}
          {popularGenres.length > 0 && (
            <section className="space-y-3">
              <div className="flex items-center gap-2 text-rose-500 font-semibold text-sm">
                <Sparkles size={16} /> THỂ LOẠI NỔI BẬT
              </div>
              <div className="flex flex-wrap gap-2.5">
                {popularGenres.map(([genre, count]) => (
                  <Link
                    key={genre}
                    to={`/youtube?q=${encodeURIComponent(genre)}`}
                    className="ui-chip transition-all hover:border-rose-500 hover:text-rose-500"
                  >
                    {genre} <span className="opacity-60 text-xs ml-1">({count})</span>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {/* Section 1: Nghe Nhiều & Thịnh Hành */}
          {popularTracks.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Thịnh hành & Được nghe nhiều" to="/youtube?kind=full" />
              <div className="ui-grid">
                {popularTracks.map((track, index) => (
                  <YouTubeTrackCard
                    key={track.id}
                    track={track}
                    tracks={popularTracks}
                    index={index}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 2: Pop & Quốc Tế */}
          {popTracks.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Pop Hits & Giai Điệu Bắt Tai" to="/youtube?q=Pop" />
              <div className="ui-grid">
                {popTracks.map((track, index) => (
                  <YouTubeTrackCard
                    key={track.id}
                    track={track}
                    tracks={popTracks}
                    index={index}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 3: Rock & Alternative */}
          {rockAlternativeTracks.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Rock & Alternative Sôi Động" to="/youtube?q=Rock" />
              <div className="ui-grid">
                {rockAlternativeTracks.map((track, index) => (
                  <YouTubeTrackCard
                    key={track.id}
                    track={track}
                    tracks={rockAlternativeTracks}
                    index={index}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 4: Nhạc Không Lời & Thư Giãn */}
          {acousticSoundtrackTracks.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Nhạc Phim & Không Lời Thư Giãn" to="/youtube?q=Soundtrack" />
              <div className="ui-grid">
                {acousticSoundtrackTracks.map((track, index) => (
                  <YouTubeTrackCard
                    key={track.id}
                    track={track}
                    tracks={acousticSoundtrackTracks}
                    index={index}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 5: Nhạc Việt - CHỈ HIỂN THỊ KHI CÓ DỮ LIỆU */}
          {vietnameseTracks.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Nhạc Việt" to="/youtube?region=VN" />
              <div className="ui-grid">
                {vietnameseTracks.slice(0, 4).map((track, index) => (
                  <YouTubeTrackCard
                    key={track.id}
                    track={track}
                    tracks={vietnameseTracks}
                    index={index}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 6: Album Nổi Bật */}
          {validAlbums.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Album & Bản Phát Hành" to="/collection/albums" />
              <div className="ui-grid">
                {validAlbums.map(album => (
                  <ContentCard
                    key={album.id}
                    to={`/album/${album.id}`}
                    title={album.title}
                    subtitle={album.artist || 'Sonara Music'}
                    image={album.coverUrl}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Section 7: Nghệ Sĩ Được Yêu Thích */}
          {validArtists.length > 0 && (
            <section className="space-y-4">
              <SectionHeading title="Nghệ Sĩ Được Yêu Thích" to="/collection/artists" />
              <div className="ui-grid">
                {validArtists.map(a => (
                  <ContentCard
                    key={a.id}
                    to={`/artist/${a.id}`}
                    title={a.name}
                    subtitle="Nghệ sĩ xác thực"
                    image={a.avatarUrl}
                    round
                  />
                ))}
              </div>
            </section>
          )}
        </div>
      )}
    </div>
  );
}
