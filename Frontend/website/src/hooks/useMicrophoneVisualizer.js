import { useState, useEffect, useRef } from 'react';

export function useMicrophoneVisualizer(isRecording, barsCount = 19) {
  const [frequencies, setFrequencies] = useState(() => Array(barsCount).fill(15));
  const [isLiveMic, setIsLiveMic] = useState(false);
  const [micError, setMicError] = useState(null);
  const [hasSignal, setHasSignal] = useState(false);
  const animFrameRef = useRef(null);
  const audioContextRef = useRef(null);
  const analyserRef = useRef(null);
  const mediaStreamRef = useRef(null);

  useEffect(() => {
    if (!isRecording) {
      // Clean up audio streams
      if (animFrameRef.current) cancelAnimationFrame(animFrameRef.current);
      if (mediaStreamRef.current) {
        mediaStreamRef.current.getTracks().forEach(track => track.stop());
        mediaStreamRef.current = null;
      }
      if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
        audioContextRef.current.close().catch(() => {});
        audioContextRef.current = null;
      }
      return;
    }

    let isMounted = true;

    async function setupMic() {
      try {
        if (!navigator.mediaDevices?.getUserMedia) {
          throw new Error('Web Audio getUserMedia not supported');
        }

        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        if (!isMounted) {
          stream.getTracks().forEach(t => t.stop());
          return;
        }

        mediaStreamRef.current = stream;
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        const audioCtx = new AudioContext();
        audioContextRef.current = audioCtx;

        const analyser = audioCtx.createAnalyser();
        analyser.fftSize = 64;
        analyserRef.current = analyser;

        const source = audioCtx.createMediaStreamSource(stream);
        source.connect(analyser);

        const dataArray = new Uint8Array(analyser.frequencyBinCount);
        setIsLiveMic(true);
        setMicError(null);
        setHasSignal(false);

        const updateFreq = () => {
          if (!isMounted) return;
          analyser.getByteFrequencyData(dataArray);
          if (dataArray.some(value => value > 12)) setHasSignal(true);

          // Sample 19 bars across the frequency spectrum
          const bars = [];
          const step = Math.max(1, Math.floor(dataArray.length / barsCount));
          for (let i = 0; i < barsCount; i++) {
            const rawVal = dataArray[i * step] || 0;
            // Scale between 12% and 100% height
            const normalized = Math.min(100, Math.max(12, Math.round((rawVal / 255) * 100)));
            bars.push(normalized);
          }
          setFrequencies(bars);
          animFrameRef.current = requestAnimationFrame(updateFreq);
        };

        animFrameRef.current = requestAnimationFrame(updateFreq);
      } catch (error) {
        if (!isMounted) return;
        mediaStreamRef.current?.getTracks().forEach(track => track.stop());
        setIsLiveMic(false);
        setMicError(error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError' ? 'denied' : error.name === 'NotFoundError' ? 'missing' : 'unavailable');
      }
    }

    setupMic();

    return () => {
      isMounted = false;
      setIsLiveMic(false);
      if (animFrameRef.current) cancelAnimationFrame(animFrameRef.current);
      if (mediaStreamRef.current) {
        mediaStreamRef.current.getTracks().forEach(t => t.stop());
      }
      if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
        audioContextRef.current.close().catch(() => {});
      }
    };
  }, [isRecording, barsCount]);

  return { frequencies: isRecording ? frequencies : Array(barsCount).fill(12), isLiveMic: isRecording && isLiveMic, micError, hasSignal, clearMicError: () => setMicError(null) };
}
