import React from 'react';

export function Badge({ children, variant = 'default', className = '' }) {
  const variantStyles = {
    default: 'bg-sonara-overlay/10 text-sonara-secondary border-sonara-overlay/10',
    lossless: 'bg-rose-500/10 text-sonara-link border-rose-800/50 font-semibold',
    ai: 'bg-gradient-to-r from-rose-900/80 to-red-800/80 text-rose-100 border-rose-700/60 font-semibold shadow-sm',
    match: 'bg-emerald-500/10 text-sonara-success border-emerald-800/40 font-semibold',
    top1: 'bg-rose-600 text-white font-bold shadow-md shadow-rose-900/50',
    hot: 'bg-amber-500/10 text-sonara-warning border-amber-800/40 font-semibold'
  };

  return (
    <span
      className={`inline-flex shrink-0 whitespace-nowrap items-center px-2 py-0.5 rounded-full text-[11px] tracking-wide uppercase border ${variantStyles[variant] || variantStyles.default} ${className}`}
    >
      {children}
    </span>
  );
}
