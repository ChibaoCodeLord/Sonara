import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ChevronLeft,
  ChevronRight,
  Search,
  Mic,
  Crown,
  Bell,
  Menu
} from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { useAppStore } from '../../store/useAppStore';
import { AccountMenu } from './AccountMenu';
import { useCatalogEntities } from '../../hooks/useCatalogEntities';
import { ThemeToggle } from '../ui/ThemeControl';

export function Topbar({ isNavOpen, onOpenNav }) {
  const { tracks: songsData, artists: artistsData } = useCatalogEntities();
  const navigate = useNavigate();
  const toggleHumModal = usePlayerStore((s) => s.toggleHumModal);
  const openDialog = useAppStore(s => s.openDialog);
  const notifications = useAppStore(s => s.notifications);
  const [searchTerm, setSearchTerm] = useState('');

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    if (searchTerm.trim()) {
      navigate(`/search?q=${encodeURIComponent(searchTerm.trim())}`);
    } else {
      navigate('/search');
    }
  };

  return (
    <header className="h-16 gap-3 px-3 sm:px-6 xl:px-8 bg-sonara-base/80 backdrop-blur-md border-b border-sonara-border/50 flex items-center justify-between shrink-0 z-10">
      {/* Left: Navigation Buttons & Search Input */}
      <div className="flex min-w-0 items-center gap-3 flex-1 max-w-xl">
        <button onClick={onOpenNav} aria-label="Mở menu" aria-expanded={isNavOpen} aria-controls="main-navigation" className="p-2 shrink-0 lg:hidden"><Menu className="w-5 h-5" /></button>
        <div className="hidden md:flex items-center gap-1.5 shrink-0">
          <button
            onClick={() => navigate(-1)}
            className="w-8 h-8 rounded-full bg-sonara-field/80 hover:bg-sonara-elevated text-sonara-secondary hover:text-sonara-text flex items-center justify-center border border-sonara-overlay/5 transition-colors"
            title="Quay lại"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button
            onClick={() => navigate(1)}
            className="w-8 h-8 rounded-full bg-sonara-field/80 hover:bg-sonara-elevated text-sonara-secondary hover:text-sonara-text flex items-center justify-center border border-sonara-overlay/5 transition-colors"
            title="Đi tiếp"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>

        {/* Global Search Input */}
        <form onSubmit={handleSearchSubmit} className="relative flex-1 min-w-0" role="search">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-sonara-muted pointer-events-none" />
          <input
            type="text"
            list="global-search-suggestions"
            aria-label="Tìm bài hát, nghệ sĩ, giai điệu"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Tìm bài hát, nghệ sĩ, giai điệu..."
            className="w-full h-10 pl-10 pr-3 sm:pr-10 rounded-full bg-sonara-field/90 border border-sonara-border focus:border-rose-500/70 focus:outline-none focus:ring-1 focus:ring-rose-500/40 text-xs sm:text-sm text-sonara-text placeholder:text-sonara-subtext transition-all"
          />
          <datalist id="global-search-suggestions">{songsData.map(song => <option key={song.id} value={song.title}>{song.artist}</option>)}{artistsData.map(artist => <option key={artist.id} value={artist.name}>Nghệ sĩ</option>)}</datalist>
          <button
            type="button"
            onClick={() => toggleHumModal(true)}
            className="hidden sm:block absolute right-2.5 top-1/2 -translate-y-1/2 p-1.5 rounded-full text-sonara-muted hover:text-sonara-link hover:bg-sonara-overlay/5 transition-colors"
            title="Nhận diện bằng AI Hum"
          >
            <Mic className="w-4 h-4" />
          </button>
        </form>
      </div>

      {/* Right: VIP Badge, Notifications, User Profile */}
      <div className="flex items-center gap-2 shrink-0">
        <ThemeToggle />
        <button
          onClick={() => navigate('/premium')}
          className="hidden xl:flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-gradient-to-r from-amber-500/20 to-rose-500/20 text-sonara-warning border border-amber-500/30 hover:border-amber-400/50 transition-all shadow-sm"
        >
          <Crown className="w-3.5 h-3.5 text-sonara-warning" />
          <span>Gói VIP Lossless</span>
        </button>

        <button
          onClick={() => openDialog('notifications')}
          className="hidden sm:inline-flex p-2 text-sonara-muted hover:text-sonara-text rounded-full hover:bg-sonara-overlay/5 transition-colors relative"
          title="Thông báo"
        >
          <Bell className="w-4 h-4" />
          {notifications.some(item => !item.read) && <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-rose-500" />}
        </button>

        <AccountMenu />
      </div>
    </header>
  );
}
