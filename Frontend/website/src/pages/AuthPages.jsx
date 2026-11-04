import React, { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { AudioLines, ArrowLeft, ArrowRight, CheckCircle2, Eye, EyeOff, Headphones } from 'lucide-react';
import { useAppStore } from '../store/useAppStore';
import { ThemeToggle } from '../components/ui/ThemeControl';
import { Notice } from '../components/ui/Screen';

export function AuthPage({ mode = 'login' }) {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const signIn = useAppStore(s => s.signInDemo);
  const title = { login: 'Chào mừng bạn trở lại.', signup: 'Âm nhạc bắt đầu từ bạn.', forgot: 'Tìm lại tài khoản.', reset: 'Một khởi đầu mới.' }[mode];
  const submit = e => {
    e.preventDefault(); setError('');
    if (mode === 'forgot' || mode === 'reset') { setSubmitted(true); setPassword(''); return; }
    if (mode === 'signup' && !name.trim()) { setError('Hãy nhập tên hiển thị của bạn.'); return; }
    if (password.length < 8) { setError('Mật khẩu cần có ít nhất 8 ký tự để thử luồng giao diện.'); return; }
    // This is a local UI session, not verification of these credentials.
    signIn(name.trim() || email.split('@')[0], email); setPassword('');
    const next = params.get('next');
    navigate(next?.startsWith('/') && !next.startsWith('//') ? next : '/', { replace: true });
  };
  return <div className="ui-auth text-sonara-text"><div className="auth-theme-control"><ThemeToggle /></div>
    <aside className="ui-auth-art"><Link to="/" className="ui-brand"><span><AudioLines /></span>Sonara</Link><div><p className="ui-eyebrow">MỘT KHÔNG GIAN DÀNH CHO BẠN</p><h2>Để âm nhạc<br />nói thay cảm xúc.</h2><p className="mt-6">Khám phá những giai điệu mới, lưu lại những bài hát yêu thích và tìm lại một ký ức chỉ bằng tiếng ngân nga.</p></div><p className="flex gap-3 items-center"><Headphones size={18} />Lắng nghe theo cách của bạn.</p></aside>
    <section className="ui-auth-body"><div><Link to="/" className="ui-text-link mb-10"><ArrowLeft size={16} />Về khám phá</Link><Link to="/" className="ui-brand mb-8 lg:hidden"><span><AudioLines /></span>Sonara</Link><p className="ui-eyebrow">{mode === 'signup' ? 'TẠO KHÔNG GIAN CỦA BẠN' : 'SONARA ACCOUNT'}</p><h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight mb-5">{title}</h1>
      <Notice>Bản trải nghiệm giao diện. Không dùng mật khẩu thật; thông tin đăng nhập không được gửi đến máy chủ.</Notice>
      {submitted ? <div role="status" className="ui-panel mt-6 space-y-5"><CheckCircle2 className="text-sonara-success" size={32} /><h2>{mode === 'forgot' ? 'Đã xem trước bước khôi phục' : 'Đã hoàn tất bước đặt lại mẫu'}</h2><p className="ui-muted">Chưa có email được gửi và mật khẩu chưa được thay đổi trên hệ thống. Bạn có thể tiếp tục kiểm tra giao diện đặt lại mật khẩu.</p>{mode === 'forgot' && <Link className="ui-button" to="/reset-password">Xem bước đặt mật khẩu</Link>}<Link className="ui-text-link" to="/login">Về đăng nhập</Link></div> : <form className="ui-form mt-6" onSubmit={submit}>
        {mode === 'signup' && <label className="ui-label">Bạn muốn được gọi là gì?<input autoComplete="nickname" className="ui-field" required maxLength={60} value={name} onChange={e => setName(e.target.value)} placeholder="Tên hiển thị" /></label>}
        {mode !== 'reset' && <label className="ui-label">Địa chỉ email<input type="email" autoComplete="email" required className="ui-field" value={email} onChange={e => setEmail(e.target.value)} placeholder="ban@example.com" /></label>}
        {mode !== 'forgot' && <label className="ui-label">{mode === 'reset' ? 'Mật khẩu mới (mẫu)' : 'Mật khẩu (mẫu)'}<div className="relative"><input type={showPassword ? 'text' : 'password'} autoComplete={mode === 'login' ? 'current-password' : 'new-password'} required minLength={8} className="ui-field pr-12" value={password} onChange={e => setPassword(e.target.value)} placeholder="Ít nhất 8 ký tự" /><button type="button" className="absolute right-3 top-3 text-sonara-muted" aria-label={showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'} onClick={() => setShowPassword(!showPassword)}>{showPassword ? <EyeOff size={19} /> : <Eye size={19} />}</button></div></label>}
        {mode === 'login' && <Link to="/forgot-password" className="ui-text-link self-end">Quên mật khẩu?</Link>}
        {mode === 'signup' && <label className="flex gap-3 text-xs text-sonara-muted leading-relaxed"><input type="checkbox" required className="accent-rose-600 shrink-0 mt-1" />Tôi hiểu đây là hồ sơ trải nghiệm được lưu trên trình duyệt này.</label>}
        {error && <p role="alert" className="ui-error">{error}</p>}<button className="ui-button w-full">{mode === 'login' ? 'Đăng nhập trải nghiệm' : mode === 'signup' ? 'Tạo tài khoản trải nghiệm' : mode === 'forgot' ? 'Xem trước khôi phục' : 'Hoàn tất bước mẫu'}<ArrowRight size={16} /></button>
      </form>}
      <div className="mt-7 text-sm text-sonara-muted">{mode === 'login' ? <>Bạn chưa có tài khoản? <Link className="ui-text-link" to="/signup">Đăng ký</Link></> : <Link className="ui-text-link" to="/login">Đã có tài khoản? Đăng nhập</Link>}</div><div className="ui-footer-links"><Link to="/help">Trợ giúp</Link><Link to="/legal/privacy">Quyền riêng tư</Link><Link to="/">Tiếp tục với tư cách khách</Link></div>
    </div></section>
  </div>;
}

export function WelcomePage() {
  const signOut = useAppStore(s => s.signOut);
  return <div className="ui-auth text-sonara-text"><div className="auth-theme-control"><ThemeToggle /></div><aside className="ui-auth-art"><Link to="/" className="ui-brand"><span><AudioLines /></span>Sonara</Link><h2>Mọi khoảnh khắc.<br />Một giai điệu.</h2><p>Không nhớ tên bài hát? Hãy để tiếng ngân nga dẫn lối.</p></aside><section className="ui-auth-body"><div><p className="ui-eyebrow">CHÀO MỪNG ĐẾN VỚI SONARA</p><h1 className="text-4xl font-extrabold tracking-tight">Tìm thấy âm nhạc.<br /><span className="text-sonara-link">Tìm thấy chính bạn.</span></h1><p className="ui-description mb-8">Khám phá tuyển tập, tạo playlist và tìm bài hát từ một giai điệu trong trí nhớ.</p><div className="ui-form"><Link to="/signup" className="ui-button">Bắt đầu trải nghiệm</Link><Link to="/login" className="ui-button ui-button-secondary">Tôi đã có tài khoản</Link><Link to="/" onClick={signOut} className="ui-text-link justify-center">Tiếp tục với tư cách khách <ArrowRight size={16} /></Link></div><p className="ui-muted mt-8">Bản trải nghiệm Sonara · Nội dung và tài khoản mẫu</p></div></section></div>;
}
