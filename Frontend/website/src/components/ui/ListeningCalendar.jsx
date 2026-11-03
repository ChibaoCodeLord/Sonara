import React, { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Flame, Trophy, CalendarDays, Headphones } from 'lucide-react';
import { useAppStore } from '../../store/useAppStore';
import { activityLevel, activityStats, calendarDays, DAILY_GOAL_SECONDS, localDay } from '../../utils/listeningActivity';

const duration = seconds => seconds < 60 ? `${Math.floor(seconds)} giây` : `${Math.floor(seconds / 60)} phút ${Math.floor(seconds % 60)} giây`;
export function ListeningCalendar() {
  const activity = useAppStore(s => s.listeningActivity);
  const [today, setToday] = useState(localDay), [year, setYear] = useState(() => new Date().getFullYear());
  const [selected, setSelected] = useState(localDay);
  useEffect(() => {
    const timer = setInterval(() => setToday(localDay()), 30000);
    const refresh = () => setToday(localDay()); window.addEventListener('focus', refresh);
    return () => { clearInterval(timer); window.removeEventListener('focus', refresh); };
  }, []);
  const currentYear = Number(today.slice(0, 4));
  const years = [...new Set([currentYear, currentYear - 1, ...Object.keys(activity).map(key => Number(key.slice(0, 4)))])].filter(value => value <= currentYear).sort((a, b) => b - a);
  const days = useMemo(() => calendarDays(year, today), [year, today]);
  const stats = activityStats(activity, today);
  const activeDays = days.filter(day => day.inYear && !day.future && activity[day.key] >= DAILY_GOAL_SECONDS);
  const totalSeconds = days.filter(day => day.inYear && !day.future).reduce((sum, day) => sum + (activity[day.key] || 0), 0);
  const todayRemaining = Math.max(0, Math.ceil(DAILY_GOAL_SECONDS - stats.todaySeconds));
  const description = day => `${day.split('-').reverse().join('/')} · ${duration(activity[day] || 0)} · ${activity[day] >= DAILY_GOAL_SECONDS ? 'Đã giữ chuỗi' : 'Chưa đạt 30 giây'}`;
  const focusDay = (event, index) => {
    const delta = { ArrowLeft: -7, ArrowRight: 7, ArrowUp: -1, ArrowDown: 1 }[event.key];
    if (!delta) return;
    const next = days[index + delta];
    if (next?.inYear && !next.future) { event.preventDefault(); setSelected(next.key); event.currentTarget.parentElement.querySelector(`[data-day="${next.key}"]`)?.focus(); }
  };
  return <section className="listening-section" aria-label="Hoạt động nghe nhạc">
    <div className="listening-stats">{[{ icon: Flame, value: stats.current, label: 'Chuỗi hiện tại', unit: 'ngày' }, { icon: Trophy, value: stats.longest, label: 'Chuỗi dài nhất', unit: 'ngày' }, { icon: CalendarDays, value: activeDays.length, label: `Ngày hoạt động · ${year}`, unit: 'ngày' }, { icon: Headphones, value: totalSeconds < 60 ? Math.floor(totalSeconds) : Math.floor(totalSeconds / 60), label: `Thời gian nghe · ${year}`, unit: totalSeconds < 60 ? 'giây' : 'phút' }].map(item => <div className="ui-panel listening-stat" key={item.label}><item.icon size={20} aria-hidden="true" /><p className="ui-muted">{item.label}</p><strong>{item.value}<span>{item.unit}</span></strong></div>)}</div>
    <div className="ui-panel listening-calendar"><div className="ui-section-heading"><div><h2>Nhịp nghe mỗi ngày</h2><p className="ui-muted mt-2">{activeDays.length} ngày giữ chuỗi trong năm {year}</p></div><label className="ui-label">Năm<select className="ui-field" aria-label="Năm hoạt động" value={year} onChange={e => { const value = Number(e.target.value); setYear(value); setSelected(value === currentYear ? today : `${value}-12-31`); }}>{years.map(value => <option key={value}>{value}</option>)}</select></label></div>
      <div className="listening-scroll" role="region" aria-label={`Lịch nghe nhạc năm ${year}, cuộn ngang để xem các tháng`} tabIndex={0}><div className="listening-grid" style={{ gridTemplateColumns: `32px repeat(${days.length / 7}, 12px)` }}>
        {days.filter((_, index) => index % 7 === 0).map((day, index) => { const next = days.slice(index * 7, index * 7 + 7).find(item => item.inYear && item.key.endsWith('-01')); return next && <span className="listening-month" style={{ gridColumn: index + 2, gridRow: 1 }} key={day.key}>T{Number(next.key.slice(5, 7))}</span>; })}
        {['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map((label, index) => <span className="listening-weekday" style={{ gridColumn: 1, gridRow: index + 2 }} key={label}>{index % 2 === 1 ? label : ''}</span>)}
        {days.map((day, index) => day.inYear && !day.future ? <button key={day.key} data-day={day.key} className={`listening-cell listening-level-${activityLevel(activity[day.key] || 0)}`} style={{ gridColumn: Math.floor(index / 7) + 2, gridRow: index % 7 + 2 }} tabIndex={selected === day.key ? 0 : -1} aria-label={description(day.key)} aria-pressed={selected === day.key} title={description(day.key)} onFocus={() => setSelected(day.key)} onClick={() => setSelected(day.key)} onKeyDown={event => focusDay(event, index)}>{activity[day.key] >= DAILY_GOAL_SECONDS ? <span aria-hidden="true">·</span> : null}</button> : <span key={day.key} className="listening-cell listening-future" style={{ gridColumn: Math.floor(index / 7) + 2, gridRow: index % 7 + 2 }} />)}
      </div></div>
      <div className="listening-legend"><span>Thời gian nghe / ngày</span><div>{['<30 giây', '30 giây+', '2 phút+', '10 phút+', '30 phút+'].map((label, index) => <span key={label}><i className={`listening-cell listening-level-${index}`} aria-hidden="true" />{label}</span>)}</div></div>
      <p className="listening-detail" aria-live="polite">{description(selected)}</p>
      <details className="listening-table"><summary>Xem dữ liệu theo ngày ({activeDays.length} ngày giữ chuỗi)</summary>{activeDays.length ? <table><caption className="sr-only">Các ngày nghe đủ 30 giây trong năm {year}</caption><thead><tr><th>Ngày</th><th>Thời gian nghe</th></tr></thead><tbody>{activeDays.slice().reverse().map(day => <tr key={day.key}><td>{day.key.split('-').reverse().join('/')}</td><td>{duration(activity[day.key])}</td></tr>)}</tbody></table> : <p className="ui-muted mt-3">Chưa có ngày đạt mục tiêu trong năm này.</p>}</details>
    </div>
    <div className="listening-goal ui-panel"><Flame size={24} className="text-sonara-link shrink-0" aria-hidden="true" /><div className="flex-1 min-w-0"><h3>{todayRemaining ? `Thêm ${todayRemaining} giây nghe nhạc để giữ chuỗi hôm nay` : 'Bạn đã giữ chuỗi hôm nay!'}</h3><p className="ui-muted mt-2">Nghe đủ 30 giây mỗi ngày. Chỉ tính lúc âm thanh đang phát, không tính tua bài hoặc thời gian tạm dừng.</p><progress max={30} value={Math.min(30, stats.todaySeconds)} aria-label="Tiến độ nghe hôm nay" /></div><Link className="ui-button ui-button-secondary" to="/browse">Nghe nhạc</Link></div>
    <p className="ui-muted">Dữ liệu được lưu trên trình duyệt này, theo ngày và múi giờ của thiết bị. Chuỗi hôm qua được giữ trong lúc bạn hoàn thành mục tiêu hôm nay. Xóa lịch sử bài hát không xóa hoạt động nghe.</p>
  </section>;
}
