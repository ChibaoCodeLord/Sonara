import React from 'react';
import { PageHeading } from '../components/ui/Screen';
import { ListeningCalendar } from '../components/ui/ListeningCalendar';
export function ActivityPage() {
  return <div className="ui-page"><PageHeading eyebrow="MỖI NGÀY MỘT GIAI ĐIỆU" title="Chuỗi nghe nhạc" description="Một ô nhỏ cho mỗi ngày bạn dành thời gian cho âm nhạc." /><ListeningCalendar /></div>;
}
