import React from 'react';
import { NavLink } from 'react-router-dom';
import { Home, Search, Library, Plus, Heart, X } from 'lucide-react';
import { useAppStore } from '../../store/useAppStore';
import { useOverlayFocus } from '../../hooks/useOverlayFocus';

export function Sidebar({ isOpen, onClose }) {
  const panelRef = useOverlayFocus(isOpen, onClose);
  const app = useAppStore();

  const navLinks = [
    { to: '/', label: 'Trang chủ', icon: Home },
    { to: '/search', label: 'Tìm kiếm', icon: Search },
    { to: '/library', label: 'Thư viện', icon: Library },
  ];

  return (
    <>
    {isOpen && <button className="nav-backdrop lg:hidden" aria-label="Đóng điều hướng" onClick={onClose} />}
    <aside ref={panelRef} id="main-navigation" aria-label="Điều hướng chính" className={`sidebar bg-sonara-surface border-r border-sonara-border/80 select-none ${isOpen ? 'sidebar-open' : ''}`}>
      <button onClick={onClose} aria-label="Đóng menu" className="absolute right-2 top-2 p-2 lg:hidden"><X className="w-4 h-4" /></button>
      <div className="flex flex-col flex-1 min-h-0">
      {/* 1. Top Section (Fixed, shrink-0): Brand Logo & Primary Navigation */}
      <div className="sidebar-primary flex flex-col px-4 pt-4 pb-2 shrink-0">
        {/* Brand Logo */}
        <div className="sidebar-brand flex items-center gap-3 px-2 py-2 mb-3">
          <div className="relative w-9 h-9 rounded-xl bg-gradient-to-br from-rose-700 via-rose-600 to-red-500 flex items-center justify-center shadow-lg shadow-rose-900/40">
            {/* Soundwave Bars in Logo */}
            <div className="flex items-end gap-[2px] h-4">
              <span className="w-[2.5px] h-2.5 bg-white rounded-full" />
              <span className="w-[2.5px] h-4 bg-white rounded-full" />
              <span className="w-[2.5px] h-1.5 bg-white rounded-full" />
              <span className="w-[2.5px] h-3 bg-white rounded-full" />
            </div>
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="text-lg font-black tracking-tight text-sonara-text font-sans">
                Sonara
              </span>
              <span className="px-1.5 py-0.2 rounded text-[9px] font-extrabold uppercase bg-rose-500/20 text-sonara-link border border-rose-500/30">
                PRO
              </span>
            </div>
            <p className="text-[10px] text-sonara-muted font-medium leading-none">Hi-Res Lossless & AI</p>
          </div>
        </div>

        {/* Primary Navigation Links */}
        <nav aria-label="Các mục chính" className="space-y-1 mb-3">
          {navLinks.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.to}
                to={item.to}
                onClick={onClose}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-3 py-3 rounded-xl text-sm font-semibold transition-colors ${
                    isActive
                      ? 'bg-sonara-overlay/10 text-sonara-text'
                      : 'text-sonara-muted hover:text-sonara-text hover:bg-sonara-overlay/5'
                  }`
                }
              >
                <Icon className="w-5 h-5" aria-hidden="true" />
                <span>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>

      </div>

      {/* 2. Middle Section: Scrollable Playlists (flex-1 min-h-0) */}
      <div className="flex-1 min-h-0 flex flex-col px-4 py-3 border-t border-sonara-overlay/5">
        {/* Playlists Header */}
        <div className="flex items-center justify-between px-2 mb-2 text-[11px] font-bold text-sonara-muted uppercase tracking-wider shrink-0">
          <span>Playlist của bạn</span>
          <button
            onClick={() => { onClose(); app.openDialog(app.session ? 'playlist-editor' : 'signin'); }}
            className="p-2 hover:text-sonara-text rounded-full hover:bg-sonara-overlay/5 transition-colors"
            title="Tạo playlist mới"
            aria-label="Tạo playlist mới"
          >
            <Plus className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Scrollable Playlist Items */}
        <div className="flex-1 min-h-0 overflow-y-auto space-y-1 pr-1">
          <NavLink
            to="/playlist/playlist_liked_songs"
            onClick={onClose}
            className={({ isActive }) =>
              `flex items-center gap-2.5 px-2.5 py-1.5 rounded-xl text-xs font-medium transition-colors ${
                isActive
                  ? 'bg-sonara-overlay/10 text-sonara-link font-bold'
                  : 'text-sonara-muted hover:text-sonara-text hover:bg-sonara-overlay/5'
              }`
            }
          >
            <div className="w-5 h-5 rounded-md bg-gradient-to-br from-rose-600 to-red-400 flex items-center justify-center text-white shrink-0">
              <Heart className="w-3 h-3 fill-current" />
            </div>
            <span className="truncate">Bài hát yêu thích</span>
          </NavLink>

          {app.playlists.filter(pl => pl.id !== 'playlist_liked_songs' && (pl.owned || app.savedPlaylistIds.includes(pl.id))).map((pl) => (
            <NavLink
              key={pl.id}
              to={`/playlist/${pl.id}`}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-2 px-2.5 py-1.5 rounded-xl text-xs font-medium transition-colors truncate ${
                  isActive
                    ? 'bg-sonara-overlay/10 text-sonara-link font-bold'
                    : 'text-sonara-muted hover:text-sonara-text hover:bg-sonara-overlay/5'
                }`
              }
            >
              <span className="w-1.5 h-1.5 rounded-full bg-sonara-trackHover shrink-0" />
              <span className="truncate">{pl.title}</span>
            </NavLink>
          ))}
        </div>
      </div>
      </div>

    </aside>
    </>
  );
}
