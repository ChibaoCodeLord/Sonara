import React, { Suspense, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { BottomPlayer } from './BottomPlayer';
import { LyricsDrawer } from '../player/LyricsDrawer';
import { QueueDrawer } from '../player/QueueDrawer';
import { FullscreenPlayer } from '../player/FullscreenPlayer';
import { HumModal } from '../hum/HumModal';
import { Toast } from '../ui/Toast';
import { useAudioEngine } from '../../hooks/useAudioEngine';
import { usePlayerStore } from '../../store/usePlayerStore';
import { AppDialogs } from '../ui/AppDialogs';
import { LoadingState, NetworkState, ScreenErrorBoundary } from '../ui/Screen';
import { useAppStore } from '../../store/useAppStore';
import { useMediaImportSync } from '../../hooks/useMediaImportSync';
import { AudioPreparation } from '../player/AudioPreparation';
import { useTestLibrary } from '../../hooks/useTestLibrary';

export function MainLayout() {
  // Mount Global Audio Engine
  const { seek } = useAudioEngine();
  useMediaImportSync();
  useTestLibrary();
  const isHumModalOpen = usePlayerStore(s => s.isHumModalOpen);
  const [isNavOpen, setIsNavOpen] = useState(false);
  const mainRef = useRef(null);
  const { pathname } = useLocation();
  const session = useAppStore(s => s.session);
  useLayoutEffect(() => { mainRef.current?.scrollTo(0, 0); }, [pathname]);
  useEffect(() => {
    const desktop = window.matchMedia('(min-width: 1024px)');
    const closeNav = event => { if (event.matches) setIsNavOpen(false); };
    desktop.addEventListener('change', closeNav);
    return () => desktop.removeEventListener('change', closeNav);
  }, []);

  return (
    <div className="app-shell bg-sonara-base text-sonara-text">
      {/* 1. Upper Section: Sidebar (Left) + Scrollable Viewport (Right) */}
      <div className="flex flex-1 min-h-0 overflow-hidden">
        {/* Left Sticky Navigation Sidebar */}
        <Sidebar isOpen={isNavOpen} onClose={() => setIsNavOpen(false)} />

        {/* Main Content Area */}
        <div className="flex flex-col flex-1 min-w-0 h-full overflow-hidden relative">
          {/* Dynamic Top Header */}
          <Topbar isNavOpen={isNavOpen} onOpenNav={() => setIsNavOpen(true)} />
          <NetworkState />

          {/* Scrollable Page Viewport with guaranteed min-h-0 */}
          <main id="main-content" ref={mainRef} tabIndex={-1} className="page-viewport flex-1 min-h-0 overflow-y-auto p-4 sm:p-6 xl:p-8">
            <ScreenErrorBoundary key={pathname}><Suspense fallback={<LoadingState />}><Outlet key={pathname} /></Suspense></ScreenErrorBoundary>
            {!session && <div className="ui-guest-banner max-w-7xl mx-auto mt-6"><div><p className="font-bold text-sm">Một không gian âm nhạc của riêng bạn</p><p className="ui-muted mt-1">Tạo hồ sơ trải nghiệm để quản lý playlist trên trình duyệt này.</p></div><Link className="ui-button" to="/signup">Đăng ký trải nghiệm</Link></div>}
            <footer className="ui-footer-links max-w-7xl mx-auto"><Link to="/help">Trợ giúp</Link><Link to="/legal/privacy">Quyền riêng tư</Link><Link to="/legal/terms">Điều khoản trải nghiệm</Link><span>© 2026 Sonara</span></footer>
          </main>
        </div>
      </div>

      {/* 2. Persistent Full-Width Bottom Audio Player Bar */}
      <BottomPlayer onSeek={seek} />
      <AudioPreparation />

      {/* Modals & Overlays */}
      <LyricsDrawer />
      <QueueDrawer />
      <FullscreenPlayer onSeek={seek} />
      {isHumModalOpen && <HumModal />}
      <Toast />
      <AppDialogs />
    </div>
  );
}
