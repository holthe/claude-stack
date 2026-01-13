# Repository Discovery Report

**Analysis Date:** 2026-01-12
**Repositories Analyzed:** 4

---

## 1. Two-Socks (Gin Bar App)

**Path:** `/home/augustin/git/two-socks`
**App ID:** `dk.affinitylabs.twosocks`
**Purpose:** Mobile-first gin bar app for menu discovery, home bar inventory, and social gin passport

### Tech Stack
| Category | Technology | Version |
|----------|------------|---------|
| Frontend | React | 19.2.0 |
| Language | TypeScript | 5.9.3 |
| Build | Vite | 7.2.4 |
| Styling | Tailwind CSS | 4.1.18 |
| State | Zustand | 5.0.9 |
| Backend | Supabase | 2.78.0 |
| Mobile | Capacitor | 8.0.0 |
| Virtualization | @tanstack/react-virtual | 3.13.13 |

### Directory Structure
```
src/
├── components/
│   ├── admin/        # AdminView CRUD forms
│   ├── home-bar/     # Inventory & drinks
│   ├── menu/         # Main menu view
│   ├── social/       # Gin passport & badges
│   └── ui/           # BottomSheet, SearchInput, TabBar
├── hooks/            # useMenuData
├── lib/              # supabase.ts
├── stores/           # menuStore (Zustand)
├── types/            # Domain models
├── App.tsx           # Tab router
└── index.css         # Global styles + animations
```

### Key Patterns
- **State Management:** Zustand store for navigation state
- **Data Fetching:** Custom hook with parallel Supabase queries
- **UI:** Tab-based navigation with 4 views (Menu, Hjemmebar, Pas, Admin)
- **Mobile:** Bottom sheet (portrait) / side panel (landscape) responsive design
- **Database:** PostgreSQL views for denormalized data (`recipes_with_details`)

### Database Schema
- `sections`, `gins`, `tonics`, `garnishes`, `recipes`, `recipe_garnishes`, `tasting_menus`
- Optimized indexes for common queries
- Price stored in Danish Ore (cents)

### Outstanding Work
- TODO: Admin delete with Supabase (line 290)
- TODO: Admin save with Supabase (line 334)
- No auth implementation
- No real-time sync
- No offline mode
- No tests

### Recent Activity
- Single initial commit (2026-01-07)
- Project recently started

---

## 2. Maggie-v3 (Family Chores App)

**Path:** `/home/augustin/git/family-chores/maggie-v3`
**App ID:** `com.affinitylabs.maggie`
**Purpose:** Family organization app with dual modes (companion app + wall-mounted display)

### Tech Stack
| Category | Technology | Version |
|----------|------------|---------|
| Frontend | React | 18.3.1 |
| Language | TypeScript | 5.6.2 |
| Build | Vite | 6.0.5 |
| Styling | Tailwind CSS | 3.4.19 |
| State | React Context | - |
| Backend | Supabase | 2.78.0 |
| Mobile | Capacitor | 8.0.0 |
| Router | React Router DOM | 6.30.2 |
| i18n | react-i18next | 16.5.2 |
| Animation | Framer Motion | 12.24.12 |
| Calendar | react-big-calendar | 1.19.4 |
| DnD | @dnd-kit | 6.3.1+ |

### Directory Structure
```
src/
├── components/
│   ├── layout/          # AppLayout, DisplayLayout, ProtectedRoute
│   ├── ui/              # 17 shadcn/ui components
│   ├── calendar/        # Calendar views, Google sync
│   ├── chores/          # Chore management
│   ├── display/         # Display-mode UI
│   ├── gallery/         # Photo gallery
│   ├── weather/         # Weather widget
│   ├── notifications/   # Notification components
│   ├── messages/        # Messaging
│   ├── settings/        # Device manager
│   ├── offline/         # Offline handling
│   └── achievements/    # Stats & badges
├── pages/               # 15+ page components
│   ├── display/         # Display-mode pages
│   └── device/          # Device pairing flow
├── context/             # Auth, Device, Date, Offline contexts
├── hooks/               # 9 custom hooks
├── lib/                 # 16 utility modules
├── types/               # TypeScript interfaces
└── locales/             # en, da translations
```

### Key Patterns
- **Dual Mode Architecture:** Companion app + Display mode for wall tablets
- **State Management:** React Context (Auth, Device, Date, Offline)
- **Device Pairing:** 6-character codes, anonymous sessions, session recovery
- **Realtime:** Supabase subscriptions for sync
- **i18n:** English + Danish (partial)
- **Offline:** LocalStorage caching with sync queue

### Database Schema (17 migrations)
- `families`, `family_members`, `chores`, `chore_assignments`
- `gallery_photos`, `calendar_events`, `calendar_reminders`
- `family_devices`, `device_pairing_codes`
- `family_messages`, `member_stats`, `achievements`
- `push_tokens`, `push_notification_preferences`

### Edge Functions (8)
- Google Calendar sync (create, update, delete, sync)
- Push notifications (send-push)
- Weather API
- Reset period stats

### Outstanding Work (from ROADMAP.md)
- iOS push notification setup
- Complete string extraction (~35 files)
- Robust photo caching
- Full offline support
- Calendar design review

### Recent Activity
- Active development (Jan 6-12)
- Focus on device session management, display mode, push notifications

---

## 3. Quiet-Kicks (Pregnancy Kick Counter)

**Path:** `/home/augustin/git/quiet-kicks`
**App ID:** `com.affinitylabs.quietkicks`
**Purpose:** Pregnancy kick counting with real-time partner synchronization

### Tech Stack
| Category | Technology | Version |
|----------|------------|---------|
| Frontend | React | 18.2.0 |
| Language | JavaScript (JSX) | - |
| Build | Vite | 5.0.0 |
| Styling | CSS Variables | - |
| State | React Hooks + localStorage | - |
| Backend | Supabase | 2.39.0 |
| Mobile | Capacitor | 5.7.8 |
| i18n | react-i18next | 16.5.0 |
| Animation | Framer Motion | 11.0.0 |

### Directory Structure
```
src/
├── components/          # 21 React components (JSX)
│   ├── KickCounter.jsx
│   ├── History.jsx
│   ├── PartnerDashboard.jsx
│   ├── Settings.jsx
│   ├── InsightsPanel.jsx
│   ├── HeatmapView.jsx
│   └── [modals, cards, UI]
├── context/             # ThemeContext (neutral/girl/boy)
├── hooks/               # 5 custom hooks
│   ├── useDataSync.js   # Core sync logic
│   ├── useLocalStorage.js
│   ├── useKickReminder.js
│   ├── useNotifications.js
│   └── usePushNotifications.js
├── i18n/                # i18next config + locales
├── lib/                 # supabase.js (626 lines)
├── utils/               # patterns, heatmap, time, gestation, share
├── App.jsx              # Main component (897 lines)
└── index.css            # Global styles (no Tailwind)
```

### Key Patterns
- **Offline-First:** LocalStorage queue with retry logic
- **Partner Sync:** Supabase Realtime for kick updates
- **Theme System:** 3 themes (neutral, girl, boy) with gradients
- **Kick Formats:** Supports both timestamp strings and {time, baby} objects
- **Twins Support:** Per-baby kick tracking
- **Analytics:** Heatmap, patterns, insights generation

### Database Schema (5 migrations)
- `couples`, `users`, `sessions`, `kicks`
- Twins support (baby1_name, baby2_name, kick.baby)
- Push tokens (fcm_token)

### Edge Functions
- `send-push` - Firebase Cloud Messaging

### Outstanding Work (from todo file)
- iOS layout issues (text sizing, button rendering)
- Partner dashboard needs bottom navigation
- Reminder banner UX improvement

### Notes
- **No TypeScript** - JavaScript only
- **Capacitor 5** - Older version (others use 6+)
- **No Tailwind** - Custom CSS with variables
- **No tests**

### Recent Activity
- Active development with frequent commits
- Focus on push notifications, twins support, authentication

---

## 4. Wedding (Wedding App)

**Path:** `/home/augustin/git/wedding`
**App ID:** `dk.affinitylabs.wedding`
**Purpose:** Multi-platform wedding app for Krista & Peter

### Tech Stack
| Category | Technology | Version |
|----------|------------|---------|
| Frontend | React | 19.2.0 |
| Language | TypeScript | 5.9.3 |
| Build | Vite | 7.2.4 |
| Styling | Tailwind CSS | 3.4.19 |
| State | React Hooks + localStorage | - |
| Backend | Supabase | 2.78.0 |
| Mobile | Capacitor | 8.0.0 |
| Router | (Custom state-based) | - |
| i18n | react-i18next | 16.5.0 |
| Animation | Framer Motion | 12.23.26 |
| UI | shadcn/ui (New York) | - |

### Directory Structure
```
src/
├── components/
│   ├── cards/           # Photo, guest, gift cards
│   ├── day/             # Schedule & venue
│   ├── guestbook/       # Guest messages
│   ├── layout/          # Shell, Topbar, BottomNav, Veil
│   ├── memory-lane/     # Story albums with swipe
│   ├── music/           # Song requests
│   ├── social/          # Photos, guestbook, music
│   ├── toastmaster/     # Special role controls
│   └── ui/              # 14 shadcn components
├── pages/               # 15 page components
├── hooks/               # useAuth, useInvite, useRole, useRSVP
├── lib/                 # Utilities & setup
├── config/              # App configuration
├── locales/             # da.json, en.json
└── types/               # TypeScript types

admin/                   # Separate admin dashboard
├── src/
│   ├── pages/           # 8 admin pages
│   │   ├── DashboardPage.tsx
│   │   ├── GuestsPage.tsx
│   │   ├── TablesPage.tsx (drag-drop seating)
│   │   ├── RSVPsPage.tsx (CSV export)
│   │   └── ContentPage.tsx
│   └── components/
```

### Key Patterns
- **Custom Navigation:** State-based (no React Router), swipeable pages
- **Role System:** 8 roles with granular permissions (bride, groom, best_man, maid_of_honor, toastmaster, dj, photographer, guest)
- **Multi-tenant:** wedding_id FK on all tables
- **Admin Dashboard:** Separate Vite app with drag-drop seating
- **Wedding Theme:** Custom colors (sage, navy, blush, ivory)
- **Swipe Gestures:** Framer Motion with velocity detection

### Database Schema (5 migrations)
- `weddings`, `guests`, `invites`, `guests_invites`
- `seating_tables`, `rsvps`, `guest_profiles`
- `memory_lane_*`, `schedule_events`, `quiz_questions`
- `guestbook_entries`, `song_requests`, `photos`
- Multi-tenant with RLS policies

### Outstanding Work
- useRSVP: Supabase sync (currently localStorage only)
- useInvite: Uses mock data (DEMO, SINGLE1, etc.)

### Recent Activity
- 3 main commits (Dec 23-25)
- Memory Lane swipe, navigation restructure, initial setup

---

## Cross-Repository Summary

### Version Matrix

| Dependency | two-socks | maggie-v3 | quiet-kicks | wedding |
|------------|-----------|-----------|-------------|---------|
| React | 19.2.0 | 18.3.1 | 18.2.0 | 19.2.0 |
| TypeScript | 5.9.3 | 5.6.2 | (none) | 5.9.3 |
| Vite | 7.2.4 | 6.0.5 | 5.0.0 | 7.2.4 |
| Tailwind | 4.1.18 | 3.4.19 | (none) | 3.4.19 |
| Capacitor | 8.0.0 | 8.0.0 | 5.7.8 | 8.0.0 |
| Supabase JS | 2.78.0 | 2.78.0 | 2.39.0 | 2.78.0 |
| Framer Motion | (none) | 12.24.12 | 11.0.0 | 12.23.26 |
| i18next | (none) | 25.7.4 | 25.7.3 | 25.7.3 |
| react-i18next | (none) | 16.5.2 | 16.5.0 | 16.5.0 |

### Feature Matrix

| Feature | two-socks | maggie-v3 | quiet-kicks | wedding |
|---------|-----------|-----------|-------------|---------|
| TypeScript | Yes | Yes | No | Yes |
| Tailwind | Yes (v4) | Yes (v3) | No | Yes (v3) |
| shadcn/ui | No | Yes (17) | No | Yes (14) |
| React Router | No | Yes | No | No (custom) |
| i18n | No | Yes (EN/DA) | Yes (EN/DA) | Yes (DA/EN) |
| Zustand | Yes | No | No | No |
| Context API | No | Yes (4) | Yes (1) | No |
| Offline Support | No | Partial | Yes | No |
| Push Notifications | No | Yes | Yes | No |
| Realtime | No | Yes | Yes | Planned |
| Tests | No | No | No | No |

### Codebase Size

| Repository | TS/TSX Files | Lines (approx) | Components |
|------------|--------------|----------------|------------|
| two-socks | ~15 | ~5,000 | ~10 |
| maggie-v3 | ~104 | ~27,000 | ~50+ |
| quiet-kicks | ~35 (JSX) | ~8,000 | ~21 |
| wedding | ~97 | ~15,000 | ~43 |
