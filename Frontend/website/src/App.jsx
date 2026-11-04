import React, { lazy, Suspense } from 'react';
import { createBrowserRouter,RouterProvider, Routes, Route } from 'react-router-dom';
import { MainLayout } from './components/layout/MainLayout';
import { HomePage } from './pages/HomePage';
import { ChartsPage } from './pages/ChartsPage';
import { LibraryPage } from './pages/LibraryPage';
import { SearchPage } from './pages/SearchPage';
import { PlaylistDetailPage } from './pages/PlaylistDetailPage';
import { ArtistDetailPage } from './pages/ArtistDetailPage';
import { ProfilePage } from './pages/ProfilePage';
import { LoadingState, NotFound } from './components/ui/Screen';
import { ThemeSync } from './components/ui/ThemeControl';

const loadScreen = (loader, name) => lazy(() => loader().then(module => ({ default: module[name] })));
const discovery = () => import('./pages/DiscoveryPages');
const account = () => import('./pages/AccountPages');
const podcasts = () => import('./pages/PodcastPages');
const auth = () => import('./pages/AuthPages');
const AlbumPage = loadScreen(discovery, 'AlbumPage'), TrackDetailPage = loadScreen(discovery, 'TrackDetailPage');
const BrowsePage = loadScreen(discovery, 'BrowsePage'), CategoryPage = loadScreen(discovery, 'CategoryPage');
const CollectionPage = loadScreen(discovery, 'CollectionPage'), HistoryPage = loadScreen(discovery, 'HistoryPage');
const NotificationsPage = loadScreen(discovery, 'NotificationsPage'), PublicProfilePage = loadScreen(discovery, 'PublicProfilePage');
const SettingsPage = loadScreen(account, 'SettingsPage'), PremiumPage = loadScreen(account, 'PremiumPage');
const CheckoutPage = loadScreen(account, 'CheckoutPage'), CheckoutResultPage = loadScreen(account, 'CheckoutResultPage');
const HelpPage = loadScreen(account, 'HelpPage'), LegalPage = loadScreen(account, 'LegalPage');
const PodcastsPage = loadScreen(podcasts, 'PodcastsPage'), ShowPage = loadScreen(podcasts, 'ShowPage'), EpisodePage = loadScreen(podcasts, 'EpisodePage');
const AuthPage = loadScreen(auth, 'AuthPage'), WelcomePage = loadScreen(auth, 'WelcomePage');
const ActivityPage = loadScreen(() => import('./pages/ActivityPage'), 'ActivityPage');
const ImportPage = loadScreen(() => import('./pages/ImportPage'), 'ImportPage');
const YouTubeCatalogPage = loadScreen(() => import('./pages/YouTubeCatalogPage'), 'YouTubeCatalogPage');
const AdminApp=lazy(()=>import('./admin/AdminApp'));

function AppRoutes() {
  return (
    <>
      <ThemeSync />
      <Suspense fallback={<div className="bg-sonara-base text-sonara-text min-h-screen p-8"><LoadingState /></div>}>
      <Routes>
        <Route path="admin/*" element={<AdminApp/>}/>
        <Route path="welcome" element={<WelcomePage />} />
        <Route path="login" element={<AuthPage key="login" mode="login" />} />
        <Route path="signup" element={<AuthPage key="signup" mode="signup" />} />
        <Route path="forgot-password" element={<AuthPage key="forgot" mode="forgot" />} />
        <Route path="reset-password" element={<AuthPage key="reset" mode="reset" />} />
        <Route path="/" element={<MainLayout />}>
          <Route index element={<HomePage />} />
          <Route path="charts" element={<ChartsPage />} />
          <Route path="library" element={<LibraryPage />} />
          <Route path="search" element={<SearchPage />} />
          <Route path="playlist/:id" element={<PlaylistDetailPage />} />
          <Route path="artist/:id" element={<ArtistDetailPage />} />
          <Route path="profile" element={<ProfilePage />} />
          <Route path="activity" element={<ActivityPage />} />
          <Route path="import" element={<ImportPage />} />
          <Route path="youtube" element={<YouTubeCatalogPage />} />
          <Route path="album/:id" element={<AlbumPage />} />
          <Route path="track/:id" element={<TrackDetailPage />} />
          <Route path="browse" element={<BrowsePage />} />
          <Route path="category/:id" element={<CategoryPage />} />
          <Route path="collection/:id" element={<CollectionPage />} />
          <Route path="history" element={<HistoryPage />} />
          <Route path="notifications" element={<NotificationsPage />} />
          <Route path="user/:id" element={<PublicProfilePage />} />
          <Route path="settings" element={<SettingsPage />} />
          <Route path="premium" element={<PremiumPage />} />
          <Route path="checkout" element={<CheckoutPage />} />
          <Route path="checkout/result" element={<CheckoutResultPage />} />
          <Route path="podcasts" element={<PodcastsPage />} />
          <Route path="show/:id" element={<ShowPage />} />
          <Route path="episode/:id" element={<EpisodePage />} />
          <Route path="help" element={<HelpPage />} />
          <Route path="legal/:type" element={<LegalPage />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
      </Suspense>
    </>
  );
}
const router=createBrowserRouter([{path:'*',element:<AppRoutes/>}]);
export function App(){return <RouterProvider router={router}/>;}

export default App;
