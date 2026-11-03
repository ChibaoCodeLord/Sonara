import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { User, Settings, Crown, LogOut, ExternalLink, HelpCircle } from 'lucide-react';
import { useAppStore } from '../../store/useAppStore';
import { useOverlayFocus } from '../../hooks/useOverlayFocus';
import { usePlayerStore } from '../../store/usePlayerStore';

export function AccountMenu() {
  const [open, setOpen] = useState(false);
  const app = useAppStore();
  const ref = useOverlayFocus(open, () => setOpen(false));
  if (!app.session) return <Link to="/login" className="ui-button py-2 px-3 min-h-9 text-xs">Đăng nhập</Link>;
  return <div className="relative shrink-0"><button aria-label="Mở menu tài khoản" aria-expanded={open} className="flex items-center gap-2" onClick={() => { if (!open && usePlayerStore.getState().currentSong?.provider === 'youtube') usePlayerStore.getState().pause(); setOpen(!open); }}><img src={app.profile.avatar} alt="" className="w-8 h-8 rounded-full object-cover border border-rose-500/50" /><span className="hidden xl:inline text-xs font-bold max-w-24 truncate">{app.profile.name}</span></button>{open && <><button className="fixed inset-0 z-40 cursor-default" aria-label="Đóng menu tài khoản" onClick={() => setOpen(false)} /><div ref={ref} className="ui-popover" role="dialog" aria-label="Tài khoản của bạn" tabIndex={-1}><p className="ui-muted px-3 py-2 border-b border-sonara-overlay/10 mb-2">{app.profile.name} · Trải nghiệm</p>{[{to:'/profile',text:'Hồ sơ của tôi',icon:User},{to:'/user/me',text:'Hồ sơ công khai',icon:ExternalLink},{to:'/settings',text:'Cài đặt tài khoản',icon:Settings},{to:'/premium',text:'Khám phá Premium',icon:Crown},{to:'/help',text:'Trợ giúp',icon:HelpCircle}].map(item => <Link key={item.to} to={item.to} className="ui-menu-item" onClick={() => setOpen(false)}><item.icon />{item.text}</Link>)}<button className="ui-menu-item border-t border-sonara-overlay/10 mt-2" onClick={() => { setOpen(false); app.openDialog('logout'); }}><LogOut />Đăng xuất</button></div></>}</div>;
}
