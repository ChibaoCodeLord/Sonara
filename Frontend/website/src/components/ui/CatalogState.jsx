import React from 'react';
import { useRemoteCatalogStore } from '../../store/useRemoteCatalogStore';
import { EmptyState, LoadingState } from './Screen';

export function CatalogState() {
  const status = useRemoteCatalogStore(s => s.status), load = useRemoteCatalogStore(s => s.load);
  if (['idle','loading'].includes(status)) return <LoadingState />;
  if (status === 'error') return <EmptyState title="Chưa tải được catalog" description="Kiểm tra kết nối máy chủ rồi thử lại."><button className="ui-button" onClick={() => load(true)}>Thử lại</button></EmptyState>;
  return null;
}
