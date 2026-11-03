import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { browserStorage } from '../utils/browserStorage.js';
import { addListening } from '../utils/listeningActivity.js';
import { usePlayerStore } from './usePlayerStore.js';
import { emptyLibrary, libraryFields, libraryIdentity, snapshotLibrary } from '../utils/localLibrary.js';
import { normalizeEmail, testLibraryEmail, testLibraryVersion } from '../utils/testLibrary.js';

const defaultProfile = { name: 'Người nghe', bio: '', avatar: '/images/catalog-placeholder.svg' };
const union = (left, right) => [...new Set([...left, ...right])];
const appendMissing = (left, right, key = 'id') => [...left, ...right.filter(item => !left.some(existing => existing[key] === item[key]))];

function changeSession(set, get, session, name) {
  const state = get(), previous = libraryIdentity(state.session), next = libraryIdentity(session);
  if (previous === next) {
    set({ session, dialog: null, profile: { ...state.profile, ...(name ? { name } : {}) } });
    return;
  }
  const accountLibraries = { ...state.accountLibraries, [previous]: snapshotLibrary(state, usePlayerStore.getState()) };
  const incoming = { ...emptyLibrary(), ...(Object.hasOwn(accountLibraries, next) ? accountLibraries[next] : {}) };
  const workspace = Object.fromEntries(libraryFields.map(key => [key, incoming[key]]));
  // Curated collections are shared catalog data; owned playlists belong to one local account.
  workspace.playlists = appendMissing(incoming.playlists, state.playlists.filter(item => !item.owned));
  workspace.profile = { ...incoming.profile, ...(name ? { name } : {}) };
  usePlayerStore.setState({ likedSongIds: incoming.likedSongIds, followedArtistIds: incoming.followedArtistIds,
    isPlaying: false, currentSong: null, queue: [], queueIndex: 0, currentTime: 0, duration: 0 });
  set({ ...workspace, accountLibraries, session, dialog: null });
}

export const useAppStore = create(persist((set, get) => ({
  session: null,
  accountLibraries: {}, libraryTestSeed: null,
  profile: defaultProfile,
  playlists: [],
  savedAlbumIds: [], savedPlaylistIds: [], followedShowIds: [], savedEpisodeIds: [], followedUserIds: [],
  folders: [], history: [], episodeProgress: {},
  listeningActivity: {}, importedTracks: [], importJobs: [], pendingImportIds: [],
  audioVersions: {},
  cacheAudio: (videoId, track) => set(state => ({ audioVersions: { ...state.audioVersions, [videoId]: track } })),
  recordListening: (start, end) => set(state => ({ listeningActivity: addListening(state.listeningActivity, start, end) })),
  saveImportedTrack: track => set(state => ({ importedTracks: [track, ...state.importedTracks.filter(item => item.id !== track.id)], pendingImportIds: state.pendingImportIds.filter(id => id !== track.mediaJobId) })),
  rememberImport: id => set(state => ({ importJobs: [id, ...state.importJobs.filter(item => item !== id)].slice(0, 30), pendingImportIds: [...new Set([...state.pendingImportIds, id])] })),
  finishImport: id => set(state => ({ pendingImportIds: state.pendingImportIds.filter(value => value !== id) })),
  settings: { language: 'vi', autoplay: true, explicit: true, publicProfile: true, emailNotifications: false },
  notifications: [],
  demoPlan: 'free',
  setDemoPlan: plan => set({ demoPlan: ['free','individual','duo'].includes(plan) ? plan : 'free' }),
  dialog: null,
  openDialog: (type, payload = {}) => set({ dialog: { type, ...payload } }),
  closeDialog: () => set({ dialog: null }),
  signInDemo: (name, email) => changeSession(set, get, { id: 'me', email: normalizeEmail(email), demo: true }, name),
  signOut: () => changeSession(set, get, null),
  seedTestLibrary: fixture => {
    const state = get();
    if (normalizeEmail(state.session?.email) !== testLibraryEmail || fixture?.marker?.version !== testLibraryVersion || state.libraryTestSeed?.version === testLibraryVersion) return false;
    const player = usePlayerStore.getState();
    usePlayerStore.setState({ likedSongIds: union(player.likedSongIds, fixture.likedSongIds), followedArtistIds: union(player.followedArtistIds, fixture.followedArtistIds) });
    set({ playlists: appendMissing(state.playlists, fixture.playlists), folders: appendMissing(state.folders, fixture.folders),
      savedAlbumIds: union(state.savedAlbumIds, fixture.savedAlbumIds),
      history: appendMissing(state.history, fixture.history, 'songId').slice(0,100), libraryTestSeed: fixture.marker });
    return true;
  },
  updateProfile: values => set(state => ({ profile: { ...state.profile, ...values } })),
  updateSettings: values => set(state => ({ settings: { ...state.settings, ...values } })),
  createPlaylist: values => {
    const id = `playlist_${globalThis.crypto.randomUUID()}`;
    set(state => ({ playlists: [{ ...values, id, title: values.title.trim(), description: values.description || '', coverUrl: values.coverUrl || '/images/catalog-placeholder.svg', songIds: values.songIds || [], owned: true, isPublic: values.isPublic ?? false, owner: state.profile.name, tag: 'CỦA BẠN' }, ...state.playlists] }));
    return id;
  },
  updatePlaylist: (id, values) => set(state => ({ playlists: state.playlists.map(item => item.id === id && item.owned ? { ...item, ...values } : item) })),
  deletePlaylist: id => set(state => ({ playlists: state.playlists.filter(item => item.id !== id || !item.owned), savedPlaylistIds: state.savedPlaylistIds.filter(item => item !== id) })),
  addTrack: (id, songId) => {
    const playlist = get().playlists.find(item => item.id === id && item.owned);
    if (!playlist || playlist.songIds.includes(songId)) return false;
    get().updatePlaylist(id, { songIds: [...playlist.songIds, songId] }); return true;
  },
  removeTrack: (id, songId) => {
    const playlist = get().playlists.find(item => item.id === id && item.owned);
    if (playlist) get().updatePlaylist(id, { songIds: playlist.songIds.filter(item => item !== songId) });
  },
  moveTrack: (id, index, direction) => {
    const playlist = get().playlists.find(item => item.id === id && item.owned);
    if (!playlist || index + direction < 0 || index + direction >= playlist.songIds.length) return;
    const ids = [...playlist.songIds]; [ids[index], ids[index + direction]] = [ids[index + direction], ids[index]];
    get().updatePlaylist(id, { songIds: ids });
  },
  toggleSaved: (key, id) => {
    if (!['savedAlbumIds', 'savedPlaylistIds', 'followedShowIds', 'savedEpisodeIds', 'followedUserIds'].includes(key)) return;
    set(state => ({ [key]: state[key].includes(id) ? state[key].filter(item => item !== id) : [...state[key], id] }));
  },
  createFolder: title => set(state => ({ folders: [...state.folders, { id: globalThis.crypto.randomUUID(), title }] })),
  markRead: id => set(state => ({ notifications: state.notifications.map(item => !id || item.id === id ? { ...item, read: true } : item) })),
  recordListen: songId => set(state => ({ history: [{ songId, at: Date.now() }, ...state.history.filter(item => item.songId !== songId)].slice(0, 100) })),
  clearHistory: () => set({ history: [] }),
  setEpisodeProgress: (id, seconds) => set(state => ({ episodeProgress: { ...state.episodeProgress, [id]: seconds } }))
}), {
  name: 'sonara-workspace-v1',
  version: 2,
  migrate: state => ({ ...state, playlists: (state.playlists || []).filter(p => p.owned).map(p => ({ ...p, songIds: [] })),
    importedTracks: [], importJobs: [], pendingImportIds: [], audioVersions: {}, history: [], listeningActivity: {},
    savedAlbumIds: [], savedPlaylistIds: [], followedShowIds: [], savedEpisodeIds: [], followedUserIds: [],
    notifications: [], profile: state.session ? state.profile : defaultProfile }),
  storage: createJSONStorage(() => browserStorage),
  merge: (persisted, current) => ({ ...current, ...persisted }),
  partialize: ({ dialog: _dialog, ...state }) => Object.fromEntries(Object.entries(state).filter(([, value]) => typeof value !== 'function'))
}));
