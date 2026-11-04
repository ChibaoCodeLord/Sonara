import React, { useEffect } from 'react';
import { Moon, Sun, Monitor } from 'lucide-react';
import { useThemeStore, watchTheme } from '../../store/useThemeStore';

export function ThemeSync() { useEffect(watchTheme, []); return null; }

export function ThemeToggle() {
  const resolved = useThemeStore(state => state.resolved), toggle = useThemeStore(state => state.toggle);
  const label = resolved === 'dark' ? 'Chuyển sang giao diện sáng' : 'Chuyển sang giao diện tối';
  const Icon = resolved === 'dark' ? Sun : Moon;
  return <button type="button" className="ui-icon-button theme-toggle" aria-label={label} title={label} onClick={toggle}><Icon size={18} aria-hidden="true" /></button>;
}

export function ThemePicker() {
  const preference = useThemeStore(state => state.preference), set = useThemeStore(state => state.setPreference);
  return <fieldset className="theme-picker"><legend className="text-sm font-bold">Giao diện</legend><p className="ui-muted mt-2 mb-4">Chọn sắc độ phù hợp với không gian nghe nhạc của bạn.</p><div className="theme-options">{[{ id: 'light', name: 'Sáng', Icon: Sun }, { id: 'dark', name: 'Tối', Icon: Moon }, { id: 'system', name: 'Theo hệ thống', Icon: Monitor }].map(({ id, name, Icon }) => <label className="theme-option" key={id}><input type="radio" name="theme" value={id} checked={preference === id} onChange={() => set(id)} /><span><Icon size={20} aria-hidden="true" />{name}</span></label>)}</div></fieldset>;
}
