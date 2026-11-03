import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Music2, RefreshCw, WifiOff } from 'lucide-react';
import { isTemporaryStorage } from '../../utils/browserStorage';

export function PageHeading({ eyebrow, title, description, children }) {
  return <div className="ui-page-heading"><div className="min-w-0">{eyebrow && <p className="ui-eyebrow">{eyebrow}</p>}<h1>{title}</h1>{description && <p className="ui-description">{description}</p>}</div>{children && <div className="ui-actions">{children}</div>}</div>;
}
export function SectionHeading({ title, to, children }) {
  return <div className="ui-section-heading"><h2>{title}</h2>{to ? <Link className="ui-text-link" to={to}>Xem tất cả <ArrowRight size={15} /></Link> : children}</div>;
}
export function Notice({ children }) { return <p className="ui-notice">{children}</p>; }
export function EmptyState({ title = 'Chưa có nội dung', description, children, icon: Icon = Music2 }) {
  return <div className="ui-empty" role="status"><span className="ui-empty-icon"><Icon size={28} /></span><h2>{title}</h2>{description && <p>{description}</p>}<div className="ui-actions justify-center">{children}</div></div>;
}
export function NotFound({ title = 'Không tìm thấy nội dung' }) { return <div className="ui-page"><EmptyState title={title} description="Nội dung có thể đã được xóa hoặc liên kết không còn đúng."><Link className="ui-button" to="/"><ArrowLeft size={16} />Về khám phá</Link></EmptyState></div>; }
export function ContentCard({ to, title, subtitle, image, round = false, badge }) {
  return <Link className="ui-content-card" to={to}><div className={`ui-card-art ${round ? 'rounded-full' : ''}`}><img src={image || '/images/catalog-placeholder.svg'} alt="" loading="lazy" />{badge && <span>{badge}</span>}</div><h3>{title}</h3><p>{subtitle}</p><span className="ui-card-arrow" aria-hidden="true"><ArrowRight size={18} /></span></Link>;
}
export function LoadingState() { return <div aria-label="Đang tải nội dung" role="status" className="ui-grid">{[1,2,3,4].map(item => <div key={item} className="ui-panel animate-pulse space-y-4"><div className="aspect-square rounded-xl bg-sonara-overlay/10" /><div className="h-4 w-3/4 bg-sonara-overlay/10 rounded" /><div className="h-3 w-1/2 bg-sonara-overlay/5 rounded" /></div>)}</div>; }
export function NetworkState() {
  const [offline, setOffline] = React.useState(() => !navigator.onLine);
  const [temporary, setTemporary] = React.useState(isTemporaryStorage);
  React.useEffect(() => { const sync = () => setOffline(!navigator.onLine); window.addEventListener('online', sync); window.addEventListener('offline', sync); return () => { window.removeEventListener('online', sync); window.removeEventListener('offline', sync); }; }, []);
  React.useEffect(() => { const sync = () => setTemporary(true); window.addEventListener('sonara-storage-fallback',sync); return () => window.removeEventListener('sonara-storage-fallback',sync); },[]);
  return offline || temporary ? <div role="alert" className="ui-offline"><WifiOff size={16} /><span>{offline ? 'Bạn đang ngoại tuyến. Nội dung đã lưu trên trình duyệt vẫn có thể xem.' : 'Trình duyệt không lưu được dữ liệu. Các thay đổi hiện chỉ giữ trong phiên này.'}</span>{offline && <button onClick={() => setOffline(!navigator.onLine)} aria-label="Kiểm tra lại kết nối"><RefreshCw size={16} /></button>}</div> : null;
}
export class ScreenErrorBoundary extends React.Component {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  render() { return this.state.failed ? <EmptyState title="Không thể hiển thị nội dung" description="Hãy thử tải lại trang để tiếp tục."><button className="ui-button" onClick={() => window.location.reload()}>Tải lại</button></EmptyState> : this.props.children; }
}
