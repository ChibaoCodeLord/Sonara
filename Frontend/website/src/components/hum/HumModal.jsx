import React, { useState, useEffect, useRef } from 'react';
import {
  X,
  Mic,
  Radio,
  Sparkles,
  Loader2 } from 'lucide-react';
import { usePlayerStore } from '../../store/usePlayerStore';
import { useMicrophoneVisualizer } from '../../hooks/useMicrophoneVisualizer';
import { VisualizerCanvas } from './VisualizerCanvas';
import { HumResultView } from './HumResultView';
import { guidanceHints } from '../../data/mockHumData';
import { formatTime } from '../../utils/formatters';
import { useOverlayFocus } from '../../hooks/useOverlayFocus';
import { Link } from 'react-router-dom';

export function HumModal() {
  const isHumModalOpen = usePlayerStore((s) => s.isHumModalOpen);
  const toggleHumModal = usePlayerStore((s) => s.toggleHumModal);

  // View state: 'recording' | 'analyzing' | 'result'
  const [viewState, setViewState] = useState('intro');
  const [recordingSeconds, setRecordingSeconds] = useState(0);
  const [searchMode, setSearchMode] = useState('hum'); // 'hum' | 'ambient'
  const [hintIndex, setHintIndex] = useState(0);

  const timerRef = useRef(null);
  const hintTimerRef = useRef(null);
  const panelRef = useOverlayFocus(isHumModalOpen, () => toggleHumModal(false));

  // Hook for Web Audio API visualizer
  const { frequencies, isLiveMic, micError, hasSignal, clearMicError } = useMicrophoneVisualizer(
    isHumModalOpen && viewState === 'recording',
    19
  );
  const signalRef = useRef(false);
  useEffect(() => { signalRef.current = hasSignal; }, [hasSignal]);

  // Handle 15s recording timer
  useEffect(() => {
    if (isHumModalOpen && viewState === 'recording' && isLiveMic) {
      let elapsed = 0;
      timerRef.current = setInterval(() => {
        elapsed += 1;
        setRecordingSeconds(elapsed);
        if (elapsed >= 15) setViewState(signalRef.current ? 'analyzing' : 'no-sound');
      }, 1000);

      // Rotate tips every 3.8s
      hintTimerRef.current = setInterval(() => {
        setHintIndex((prev) => (prev + 1) % guidanceHints.length);
      }, 3800);
    } else {
      clearInterval(timerRef.current);
      clearInterval(hintTimerRef.current);
    }

    return () => {
      clearInterval(timerRef.current);
      clearInterval(hintTimerRef.current);
    };
  }, [isHumModalOpen, viewState, isLiveMic]);

  // Cancel analysis when closing or restarting a recording.
  useEffect(() => {
    if (viewState !== 'analyzing') return;
    const timeout = setTimeout(() => setViewState('result'), 600);
    return () => clearTimeout(timeout);
  }, [viewState]);

  const handleStopAndAnalyze = () => {
    setViewState(signalRef.current ? 'analyzing' : 'no-sound');
  };

  const handleReRecord = () => {
    clearMicError();
    setViewState('intro');
    setRecordingSeconds(0);
  };

  if (!isHumModalOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] bg-black/85 backdrop-blur-xl flex items-center justify-center p-3 sm:p-6 animate-in fade-in duration-200">
      <div ref={panelRef} role="dialog" aria-modal="true" aria-labelledby="hum-title" tabIndex={-1} className="relative w-full max-w-xl max-h-full rounded-3xl bg-sonara-surface border border-sonara-border/80 shadow-2xl overflow-y-auto p-4 sm:p-6">
        {/* Top Header */}
        <div className="flex items-center justify-between pb-4 border-b border-sonara-border/50 shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-rose-700 to-red-500 text-white flex items-center justify-center shadow-md">
              <Mic className="w-5 h-5 fill-current" />
            </div>
            <div>
              <h2 id="hum-title" className="text-lg font-bold text-sonara-text">
                Tìm bằng giai điệu
              </h2>
              <div className="flex flex-wrap items-center gap-2 mt-0.5">
                <span className="flex items-center gap-1.5 text-xs text-sonara-link font-medium">
                  <span className="w-2 h-2 rounded-full bg-rose-500 animate-ping" />
                  {viewState !== 'recording' ? 'Bản thử nghiệm' : micError ? 'Chưa có micro' : isLiveMic ? 'Micro trực tiếp' : 'Đang chờ quyền micro'}
                </span>
                <span className="text-[11px] text-sonara-muted bg-sonara-overlay/5 px-2 py-0.2 rounded-full">
                  Chưa kết nối nhận diện
                </span>
              </div>
            </div>
          </div>

          <button
            aria-label="Đóng tìm kiếm giai điệu"
            onClick={() => toggleHumModal(false)}
            className="p-2 text-sonara-muted hover:text-sonara-text rounded-full hover:bg-sonara-overlay/5 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {viewState === 'intro' && <div className="ui-form py-7"><div className="ui-empty-icon mx-auto"><Mic size={30} /></div><h3 className="text-xl font-bold text-center">Một giai điệu là đủ để bắt đầu</h3><p className="ui-muted text-center">Cho phép micro rồi ngân nga khoảng 10–15 giây ở nơi yên tĩnh. Âm thanh chỉ dùng cho hình ảnh sóng âm trên máy; dịch vụ nhận diện chưa được kết nối.</p><button className="ui-button" onClick={() => { clearMicError(); setRecordingSeconds(0); setViewState('recording'); }}>Cho phép micro & bắt đầu</button><button className="ui-button ui-button-secondary" onClick={() => setViewState('result')}>Trạng thái nhận diện</button></div>}
        {viewState === 'recording' && micError && <div role="alert" className="ui-form py-7"><h3 className="text-xl font-bold">{micError === 'denied' ? 'Quyền micro chưa được cho phép' : micError === 'missing' ? 'Chưa tìm thấy micro' : 'Không thể mở micro'}</h3><p className="ui-muted">Kiểm tra micro, mở quyền truy cập của trang trong trình duyệt và thử lại. Bạn có thể tìm bài theo tên trong catalog.</p><button className="ui-button" onClick={handleReRecord}>Thử lại</button><button className="ui-button ui-button-secondary" onClick={() => setViewState('result')}>Trạng thái nhận diện</button></div>}
        {viewState === 'no-sound' && <div className="ui-form py-7" role="status"><h3 className="text-xl font-bold">Chưa nghe rõ giai điệu</h3><p className="ui-muted">Hãy kiểm tra micro, đưa thiết bị lại gần và thử ngân nga rõ hơn.</p><button className="ui-button" onClick={handleReRecord}>Thu lại giai điệu</button></div>}
        {viewState === 'no-match' && <div className="ui-form py-7" role="status"><h3 className="text-xl font-bold">Chưa tìm được bài phù hợp</h3><p className="ui-muted">Thử một đoạn điệp khúc khác hoặc tìm bằng tên nghệ sĩ, lời bài hát.</p><button className="ui-button" onClick={handleReRecord}>Thử một giai điệu khác</button><Link className="ui-button ui-button-secondary" to="/search" onClick={() => toggleHumModal(false)}>Chuyển sang tìm kiếm</Link></div>}
        {viewState === 'recording' && !micError && (
          <div className="flex flex-col items-center justify-center py-6 space-y-6">
            {/* Center Pulsing Ripple Mic Visualizer */}
            <div className="relative flex items-center justify-center my-4">
              {/* Ripple Rings */}
              <div className="absolute w-44 h-44 rounded-full border-2 border-rose-500/20 animate-ping duration-1000" />
              <div className="absolute w-36 h-36 rounded-full border border-rose-500/30 animate-pulse duration-700" />
              <div className="absolute w-28 h-28 rounded-full bg-rose-600/20 blur-md" />

              {/* Big Glowing Microphone Button */}
              <div className="relative z-10 w-24 h-24 rounded-full bg-gradient-to-br from-rose-600 via-rose-500 to-red-500 text-white flex items-center justify-center shadow-2xl shadow-rose-900/60 ring-4 ring-rose-500/30">
                <Mic className="w-10 h-10 fill-current animate-pulse" />
              </div>
            </div>

            {/* 19-Bar Soundwave Visualizer Canvas */}
            <div className="w-full flex justify-center">
              <VisualizerCanvas frequencies={frequencies} isRecording={true} />
            </div>

            {/* 15s Timer & Progress Bar */}
            <div className="w-full max-w-xs text-center space-y-2">
              <div className="flex items-center justify-center gap-1 text-2xl font-black text-sonara-text font-mono">
                <span className="text-sonara-link">{formatTime(recordingSeconds)}</span>
                <span className="text-sonara-subtext">/</span>
                <span className="text-sonara-muted">00:15</span>
              </div>

              <div className="w-full h-1.5 bg-sonara-elevated rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-rose-600 to-red-400 rounded-full transition-all duration-300"
                  style={{ width: `${(recordingSeconds / 15) * 100}%` }}
                />
              </div>
            </div>

            {/* Rotating Hint Card */}
            <div className="w-full p-4 rounded-2xl bg-sonara-overlay/5 border border-sonara-overlay/5 flex items-center gap-3 min-h-[72px]">
              <div className="p-2 rounded-xl bg-rose-500/10 text-sonara-link shrink-0">
                <Sparkles className="w-5 h-5" />
              </div>
              <div className="min-w-0">
                <h4 className="text-xs font-bold text-sonara-text mb-0.5">
                  Đang lắng nghe giai điệu...
                </h4>
                <p className="text-xs text-sonara-secondary transition-opacity duration-300">
                  {guidanceHints[hintIndex]}
                </p>
              </div>
            </div>

            {/* Mode Switcher Tabs */}
            <div className="flex items-center p-1 rounded-2xl bg-sonara-field border border-sonara-border w-full max-w-xs">
              <button
                onClick={() => setSearchMode('hum')}
                className={`flex-1 py-2 rounded-xl text-xs font-bold transition-all ${
                  searchMode === 'hum'
                    ? 'bg-rose-600 text-white shadow-md'
                    : 'text-sonara-muted hover:text-sonara-text'
                }`}
              >
                Hát / Hum
              </button>
              <button
                onClick={() => setSearchMode('ambient')}
                className={`flex-1 py-2 rounded-xl text-xs font-bold transition-all ${
                  searchMode === 'ambient'
                    ? 'bg-rose-600 text-white shadow-md'
                    : 'text-sonara-muted hover:text-sonara-text'
                }`}
              >
                Nghe quanh đây
              </button>
            </div>

            {/* Action Buttons */}
            <div className="w-full space-y-2.5 pt-2">
              <button
                onClick={handleStopAndAnalyze}
                disabled={!isLiveMic}
                className="w-full py-3.5 rounded-2xl bg-rose-600 hover:bg-rose-500 text-white font-bold text-sm shadow-xl shadow-rose-950/50 hover:shadow-rose-700/40 transition-all flex items-center justify-center gap-2"
              >
                <Radio className="w-4 h-4 animate-pulse" />
                Dừng & Phân tích ngay
              </button>

              <button
                onClick={() => toggleHumModal(false)}
                className="w-full py-3 rounded-2xl bg-transparent hover:bg-sonara-overlay/5 text-sonara-muted hover:text-sonara-text font-semibold text-xs transition-colors"
              >
                Hủy bỏ
              </button>
            </div>
          </div>
        )}

        {/* Analyzing View */}
        {viewState === 'analyzing' && (
          <div className="flex flex-col items-center justify-center py-20 space-y-5">
            <div className="relative w-20 h-20 rounded-full bg-rose-500/10 flex items-center justify-center border border-rose-500/30">
              <Loader2 className="w-10 h-10 text-sonara-link animate-spin" />
            </div>
            <div className="text-center space-y-1">
              <h3 className="text-lg font-bold text-sonara-text">
                Đang phân tích phổ tần số âm học...
              </h3>
              <p className="text-xs text-sonara-muted">
                Dịch vụ nhận diện chưa được kết nối
              </p>
            </div>
          </div>
        )}

        {/* Result View */}
        {viewState === 'result' && (
          <HumResultView onReRecord={handleReRecord} onNoMatch={() => setViewState('no-match')} />
        )}
      </div>
    </div>
  );
}
