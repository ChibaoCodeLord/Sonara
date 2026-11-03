import { useEffect, useRef } from 'react';

// Keep keyboard navigation inside the active overlay and return focus on close.
export function useOverlayFocus(isOpen, onClose) {
  const ref = useRef(null);
  const closeRef = useRef(onClose);
  useEffect(() => { closeRef.current = onClose; }, [onClose]);

  useEffect(() => {
    if (!isOpen || !ref.current) return;
    const panel = ref.current;
    panel.dataset.overlayActive = 'true';
    const previous = document.activeElement;
    const focusable = () => [...panel.querySelectorAll(
      'button, a[href], input, textarea, select, [tabindex="0"]'
    )].filter(el => !el.disabled && el.getClientRects().length);
    (focusable()[0] || panel).focus();

    function handleKey(event) {
      const overlays = [...document.querySelectorAll('[data-overlay-active="true"]')];
      if (overlays.at(-1) !== panel) return;
      if (event.key === 'Escape') {
        event.preventDefault();
        closeRef.current();
      }
      if (event.key === 'Tab') {
        const items = focusable();
        const first = items[0], last = items.at(-1);
        if (!first) { event.preventDefault(); return; }
        if (event.shiftKey && (document.activeElement === first || !panel.contains(document.activeElement))) {
          event.preventDefault(); last.focus();
        } else if (!event.shiftKey && (document.activeElement === last || !panel.contains(document.activeElement))) {
          event.preventDefault(); first.focus();
        }
      }
    }
    document.addEventListener('keydown', handleKey);
    // The focused control can disappear when recording changes to results.
    const observer = new MutationObserver(() => {
      if ([...document.querySelectorAll('[data-overlay-active="true"]')].at(-1) !== panel) return;
      if (!panel.contains(document.activeElement)) (focusable()[0] || panel).focus({ preventScroll: true });
    });
    observer.observe(panel, { childList: true, subtree: true });
    return () => {
      delete panel.dataset.overlayActive;
      observer.disconnect();
      document.removeEventListener('keydown', handleKey);
      if (previous?.isConnected) previous.focus({ preventScroll: true });
    };
  }, [isOpen]);
  return ref;
}
