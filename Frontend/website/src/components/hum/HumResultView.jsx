import React from 'react';
import { Link } from 'react-router-dom';
import { usePlayerStore } from '../../store/usePlayerStore';
import { EmptyState } from '../ui/Screen';

export function HumResultView({ onReRecord }) {
  const close = usePlayerStore(s => s.toggleHumModal);
  return <EmptyState title="Chưa có kết quả nhận diện" description="Dịch vụ tìm bài bằng giai điệu chưa được kết nối. Bạn có thể tìm theo tên trong catalog."><Link className="ui-button" to="/search" onClick={() => close(false)}>Tìm trong catalog</Link><button className="ui-button ui-button-secondary" onClick={onReRecord}>Thu âm lại</button></EmptyState>;
}
