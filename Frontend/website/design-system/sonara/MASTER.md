# Sonara Web — UI system

Skill applied: `ui-ux-pro-max`. The local `music streaming dark immersive --design-system` search returned Dark Mode (OLED), high readability, restrained glow, visible focus, keyboard support and reduced motion. The React stack search returned semantic controls and local form state. These are appropriate for this browser music product.

The skill's generic indigo/green palette and display font pairing are not adopted: Sonara already has a ruby identity, and its Vietnamese interface uses Plus Jakarta Sans / Inter. Existing brand colors and fonts are retained.

## Tokens and primitives

- Base `#0A0C10`, surface `#12151D`, card `#151922`, hover `#1E2330`.
- Primary `#E11D48`, emphasis `#FB7185`, supporting text `#A6B0C0`, border `#384152`.
- Headings: 28–58px using responsive clamp; body 14px; supporting text 12px.
- Spacing: 8 / 12 / 16 / 20 / 24 / 28 / 32px. Panels 20–24px radius. Primary actions use pills.
- Shared components: `PageHeading`, `SectionHeading`, `ContentCard`, `EmptyState`, `Notice`, `Modal`, `ImageField`.
- Primitive classes override Tailwind preflight; explicit combined selectors allow intended spacing and sizing utilities to customize these primitives.

## Interaction rules

- Buttons for actions, links for navigation. Icon controls have accessible labels.
- Modal titles use `aria-labelledby`; Tab stays inside the top overlay, Escape closes it, closing restores focus.
- Form fields have visible labels, native validation and additional whitespace checks.
- Loading has skeletons; empty states offer a next step; errors offer recovery. Microphone permission failure never produces a fake live waveform.
- Preserve user edits on the local browser. If storage is unavailable, retain session state and show a temporary-storage notice.
- Podcast playback, login, billing and device discovery must clearly identify their demo status. Do not collect real payment credentials or persist passwords.

## Responsive behavior

- Keep existing desktop app shell and persistent player. Sidebar becomes a drawer below 1024px.
- New pages have a maximum content width of 1280px. Two-column content collapses below 900px.
- Auth uses a dedicated layout with its own scroll container. Decorative panel hides below 900px.
- Cards use two columns on small screens; forms, plan cards and detailed content use one column when needed.
- Maintain focus indication and `prefers-reduced-motion` support from the global stylesheet.

## Light and dark appearance

The appearance selector supports light, dark and system preferences. Colors are semantic RGB tokens in `src/index.css`; Tailwind's Sonara colors reference those tokens so opacity modifiers remain supported. Light uses base `#F5F6FA`, white surfaces, primary text `#182033`, supporting text `#505E74`, and ruby links `#AB1237`. Dark retains the existing base and ruby identity. Artwork/brand panels explicitly use an inverse palette.

Persist the preference separately at `sonara-theme`; system is the default. Apply it in the HTML head before React loads, synchronize system and browser-tab changes, and retain a working session fallback if storage is blocked. Keep the icon toggle in the topbar/auth screens and the three native radio choices under Settings → Appearance.

The theme UI check covers persistence, keyboard radio selection, system changes, cross-tab sync, blocked storage, foreground/background token contrast, fullscreen lyrics, dialogs, and 48 route/theme/viewport combinations. Catalog API responses in that test are fixtures; it does not claim live source playback validation.
