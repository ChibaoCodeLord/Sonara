/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        sonara: {
          success: 'rgb(var(--text-success) / <alpha-value>)',
          warning: 'rgb(var(--text-warning) / <alpha-value>)',
          text: 'rgb(var(--text-primary) / <alpha-value>)',
          secondary: 'rgb(var(--text-secondary) / <alpha-value>)',
          link: 'rgb(var(--text-link) / <alpha-value>)',
          field: 'rgb(var(--bg-field) / <alpha-value>)',
          overlay: 'rgb(var(--overlay) / <alpha-value>)',
          track: 'rgb(var(--track) / <alpha-value>)',
          trackHover: 'rgb(var(--track-hover) / <alpha-value>)',
          base: 'rgb(var(--bg-base) / <alpha-value>)',
          surface: 'rgb(var(--bg-surface) / <alpha-value>)',
          elevated: 'rgb(var(--bg-elevated) / <alpha-value>)',
          card: 'rgb(var(--bg-card) / <alpha-value>)',
          cardHover: 'rgb(var(--bg-hover) / <alpha-value>)',
          border: 'rgb(var(--border) / <alpha-value>)',
          borderLight: 'rgb(var(--border-strong) / <alpha-value>)',
          ruby: '#BE123C',
          crimson: '#9A1B2F',
          primary: '#E11D48',
          coral: '#FF4B4B',
          muted: 'rgb(var(--text-muted) / <alpha-value>)',
          subtext: 'rgb(var(--text-subtle) / <alpha-value>)',
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'ripple': 'ripple 2s cubic-bezier(0, 0.2, 0.8, 1) infinite',
        'equalizer': 'equalizer 1.2s ease-in-out infinite alternate',
      },
      keyframes: {
        ripple: {
          '0%': { transform: 'scale(0.8)', opacity: '0.9' },
          '100%': { transform: 'scale(2.2)', opacity: '0' },
        },
        equalizer: {
          '0%': { height: '20%' },
          '100%': { height: '100%' },
        }
      }
    },
  },
  plugins: [],
}
