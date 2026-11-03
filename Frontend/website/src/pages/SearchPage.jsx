import React, { useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import {
  Search,
  X,
  Mic,
  Clock,
  Sparkles,
  Music,
  Headphones,
  Flame,
  Radio
} from 'lucide-react';
import { usePlayerStore } from '../store/usePlayerStore';
import { useCatalogEntities } from '../hooks/useCatalogEntities';
import { TrackRow } from '../components/ui/TrackRow';
import { Link } from 'react-router-dom';
import { useAppStore } from '../store/useAppStore';
import { podcastsData, publicUsers } from '../data/catalog';
import { CatalogState } from '../components/ui/CatalogState';
import { ContentCard } from '../components/ui/Screen';
import { CategoryCard } from '../components/ui/CategoryCard';

const normalize = value => value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase();

export function SearchPage() {
  const [searchParams] = useSearchParams();
  const initialQuery = searchParams.get('q') || '';
  return <SearchPageContent key={initialQuery} initialQuery={initialQuery} />;
}

function SearchPageContent({ initialQuery }) {
  const { tracks: songsData, artists: artistsData, albums: albumsData } = useCatalogEntities();
  const [, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  const playSong = usePlayerStore((s) => s.playSong);
  const toggleHumModal = usePlayerStore((s) => s.toggleHumModal);
  const playlists = useAppStore(s => s.playlists);

  // Keep keystrokes synchronous; commit the URL on Enter or a suggested search.
  const [query, setDraftQuery] = useState(initialQuery);
  const setQuery = value => {
    setDraftQuery(value);
    setSearchParams(value ? { q: value } : {}, { replace: true });
  };
  const [activeFilter, setActiveFilter] = useState('all');

  const [recentSearches, setRecentSearches] = useState([]);

  const handleSearchChange = (e) => {
    const val = e.target.value;
    setDraftQuery(val);
  };

  const clearRecent = (item) => {
    setRecentSearches(recentSearches.filter(s => s !== item));
  };

  // Filter songs based on query
  const filteredSongs = songsData.filter(song =>
    normalize(`${song.title} ${song.artist} ${song.genre || ''}`).includes(normalize(query.trim()))
  );

  const filteredArtists = artistsData.filter(artist =>
    normalize(artist.name).includes(normalize(query.trim()))
  );
  const matches = text => normalize(text).includes(normalize(query.trim()));
  const filteredAlbums = albumsData.filter(item => matches(`${item.title} ${item.artist}`));
  const filteredPlaylists = playlists.filter(item => matches(`${item.title} ${item.description || ''}`));
  const filteredPodcasts = podcastsData.filter(item => matches(`${item.title} ${item.author}`));
  const filteredProfiles = publicUsers.filter(item => matches(item.name));
  const visible = type => activeFilter === 'all' || activeFilter === type;
  const hasResults = (visible('songs') && filteredSongs.length) || (visible('artists') && filteredArtists.length) || (visible('albums') && filteredAlbums.length) || (visible('playlists') && filteredPlaylists.length) || (visible('podcasts') && filteredPodcasts.length) || (visible('profiles') && filteredProfiles.length);
  const labels = { all:'Tất cả', songs:'Bài hát', artists:'Nghệ sĩ', albums:'Album', playlists:'Playlist', podcasts:'Podcast', profiles:'Hồ sơ' };

  const browseCategories = [
    { title: 'Tâm trạng & Cảm xúc', query: 'Ballad', image: '/images/genres/mood.webp', color: '#783447', icon: Sparkles },
    { title: 'Thư giãn & Indie', query: 'Indie', image: '/images/genres/relax.webp', color: '#414c75', icon: Headphones },
    { title: 'Tập luyện', query: 'Rap', image: '/images/genres/workout.webp', color: '#994624', icon: Flame },
    { title: 'Quán Cafe Cuối Tuần', query: 'Acoustic', image: '/images/genres/cafe.webp', color: '#65503c', icon: Music },
    { title: 'V-Pop Mới Nhất', query: 'V-Pop', image: '/images/genres/vpop.webp', color: '#932251', icon: Radio },
    { title: 'Indie Việt & Mộc', query: 'Indie', image: '/images/genres/acoustic.webp', color: '#33564b', icon: Sparkles }
  ];

  return (
    <div className="space-y-8 max-w-7xl mx-auto pb-16 animate-in fade-in duration-300">
      <CatalogState />
      {/* 1. Large Search Input Header */}
      <div className="space-y-4">
        <h1 className="text-3xl font-black text-sonara-text">Tìm kiếm</h1>
        <nav className="ui-actions" aria-label="Khám phá nội dung"><Link className="ui-text-link" to="/youtube">Kho nhạc</Link><Link className="ui-text-link" to="/browse">Khám phá thể loại & tâm trạng</Link><Link className="ui-text-link" to="/podcasts">Khám phá podcast</Link><Link className="ui-text-link" to="/charts">Bảng xếp hạng</Link></nav>

        <div className="relative max-w-2xl">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-sonara-muted" />
          <input
            type="text"
            aria-label="Từ khóa tìm kiếm"
            value={query}
            onChange={handleSearchChange}
            onKeyDown={e => { if (e.key === 'Enter') setQuery(query); }}
            placeholder="Bạn muốn nghe bài hát, nghệ sĩ hoặc giai điệu nào?"
            className="w-full h-14 pl-12 pr-24 rounded-2xl bg-sonara-card border border-sonara-border focus:border-rose-500 focus:outline-none focus:ring-2 focus:ring-rose-500/30 text-sm sm:text-base text-sonara-text placeholder:text-sonara-subtext shadow-xl transition-all"
          />

          <div className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1.5">
            {query && (
              <button
                aria-label="Xóa từ khóa"
                onClick={() => {
                  setQuery('');
                }}
                className="p-1.5 text-sonara-muted hover:text-sonara-text rounded-lg hover:bg-sonara-overlay/5"
              >
                <X className="w-4 h-4" />
              </button>
            )}

            <button
              onClick={() => toggleHumModal(true)}
              className="p-2 text-sonara-link hover:text-white rounded-xl bg-rose-500/10 hover:bg-rose-600 transition-colors"
              title="Nhận diện bằng AI Hum"
            >
              <Mic className="w-4 h-4 fill-current" />
            </button>
          </div>
        </div>
      </div>

      {/* 2. When query is empty: Recent Searches & Browse Categories */}
      {!query.trim() ? (
        <div className="space-y-8">
          {/* Recent Searches */}
          {recentSearches.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-bold text-sonara-secondary flex items-center gap-2">
                  <Clock className="w-4 h-4 text-sonara-muted" />
                  Tìm kiếm gần đây
                </h3>
                <button
                  onClick={() => setRecentSearches([])}
                  className="text-xs text-sonara-link hover:underline"
                >
                  Xóa tất cả
                </button>
              </div>

              <div className="flex flex-wrap gap-2">
                {recentSearches.map((term) => (
                  <div
                    key={term}
                    className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-sonara-card hover:bg-sonara-cardHover border border-sonara-border text-xs text-sonara-secondary hover:text-sonara-text cursor-pointer transition-colors"
                  >
                    <button onClick={() => setQuery(term)}>{term}</button>
                    <button
                      aria-label={`Xóa tìm kiếm ${term}`}
                      onClick={(e) => {
                        e.stopPropagation();
                        clearRecent(term);
                      }}
                      className="text-sonara-subtext hover:text-sonara-text"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Browse Categories */}
          <div>
            <h2 className="text-xl font-bold text-sonara-text mb-4">
              Khám phá tất cả chủ đề
            </h2>
            <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-6 gap-4">
              {browseCategories.map(cat => <CategoryCard key={cat.title} title={cat.title} image={cat.image} color={cat.color} icon={cat.icon} onClick={() => setQuery(cat.query)} />)}
            </div>
          </div>
        </div>
      ) : (
        /* 3. When query is present: Instant Results View */
        <div className="space-y-6">
          {/* Filter tabs */}
          <div className="flex flex-wrap items-center gap-2">
            {Object.keys(labels).map((f) => (
              <button
                key={f}
                aria-pressed={activeFilter === f}
                onClick={() => setActiveFilter(f)}
                className={`px-4 py-1.5 rounded-full text-xs font-bold capitalize transition-all border ${
                  activeFilter === f
                    ? 'bg-rose-600 text-white border-rose-500'
                    : 'bg-sonara-overlay/5 text-sonara-muted border-sonara-overlay/10 hover:text-sonara-text'
                }`}
              >
                {labels[f]}
              </button>
            ))}
          </div>

          {/* Results List */}
          {visible('songs') && filteredSongs.length > 0 && (
            <section aria-label="Kết quả bài hát" className="space-y-2">
              <h3 className="text-sm font-bold text-sonara-muted">
                Tìm thấy {filteredSongs.length} bài hát phù hợp
              </h3>
              <div className="p-3 rounded-3xl bg-sonara-card/60 border border-sonara-border/60 divide-y divide-sonara-border/30">
                {filteredSongs.map((song, idx) => (
                  <TrackRow
                    key={song.id}
                    song={song}
                    index={idx}
                    onPlay={() => playSong(song)}
                  />
                ))}
              </div>
            </section>
          )}
          {visible('artists') && filteredArtists.length > 0 && (
            <section aria-label="Kết quả nghệ sĩ" className="space-y-3">
              <h2 className="text-sm font-bold text-sonara-muted">Tìm thấy {filteredArtists.length} nghệ sĩ phù hợp</h2>
              <div className="grid sm:grid-cols-2 xl:grid-cols-3 gap-3">
                {filteredArtists.map(artist => <button key={artist.id} onClick={() => navigate(`/artist/${artist.id}`)} className="flex items-center gap-3 p-4 rounded-2xl bg-sonara-card text-left hover:bg-sonara-cardHover">
                  <img src={artist.avatarUrl} alt="" className="w-12 h-12 rounded-full object-cover" />
                  <span className="font-bold text-sm">{artist.name}</span>
                </button>)}
              </div>
            </section>
          )}
          {visible('albums') && filteredAlbums.length > 0 && <section aria-label="Kết quả album"><h2 className="text-sm font-bold text-sonara-muted mb-4">Album</h2><div className="ui-grid">{filteredAlbums.map(item => <ContentCard key={item.id} to={`/album/${item.id}`} title={item.title} subtitle={item.artist} image={item.coverUrl} />)}</div></section>}
          {visible('playlists') && filteredPlaylists.length > 0 && <section aria-label="Kết quả playlist"><h2 className="text-sm font-bold text-sonara-muted mb-4">Playlist</h2><div className="ui-grid">{filteredPlaylists.map(item => <ContentCard key={item.id} to={`/playlist/${item.id}`} title={item.title} subtitle={item.owner} image={item.coverUrl} />)}</div></section>}
          {visible('podcasts') && filteredPodcasts.length > 0 && <section aria-label="Kết quả podcast"><h2 className="text-sm font-bold text-sonara-muted mb-4">Podcast</h2><div className="ui-grid">{filteredPodcasts.map(item => <ContentCard key={item.id} to={`/show/${item.id}`} title={item.title} subtitle={item.author} image={item.coverUrl} />)}</div></section>}
          {visible('profiles') && filteredProfiles.length > 0 && <section aria-label="Kết quả hồ sơ"><h2 className="text-sm font-bold text-sonara-muted mb-4">Hồ sơ</h2><div className="ui-actions">{filteredProfiles.map(item => <Link className="ui-button ui-button-secondary" key={item.id} to={`/user/${item.id}`}>{item.name}</Link>)}</div></section>}
          {!hasResults && (
            <div role="status" className="py-20 text-center space-y-4 break-words">
              <p className="text-sonara-muted">
                Không tìm thấy kết quả khớp với từ khóa "{query}"
              </p>
              <button
                onClick={() => toggleHumModal(true)}
                className="px-6 py-3 rounded-full bg-rose-600 hover:bg-rose-500 text-white font-bold text-xs inline-flex items-center gap-2 shadow-lg"
              >
                <Mic className="w-4 h-4 fill-current" />
                Thử tìm bằng cách huýt sáo / ngân nga giai điệu
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
