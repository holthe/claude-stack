# Agent Architecture Design

**Analysis Date:** 2026-01-12
**Stack:** React + Supabase + Capacitor + shadcn/ui + Tailwind

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIER 1: CORE SHARED AGENTS                    │
│              (Essential, used in nearly every session)           │
├─────────────────────────────────────────────────────────────────┤
│  react-expert   │  supabase-expert  │  capacitor-expert         │
│  (sonnet)       │  (sonnet)         │  (sonnet)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                 TIER 2: SPECIALIZED SHARED AGENTS                │
│              (Important, used frequently for specific tasks)     │
├─────────────────────────────────────────────────────────────────┤
│  tailwind-ui    │  testing-expert  │  security-expert           │
│  (haiku)        │  (sonnet)        │  (sonnet)                  │
├─────────────────────────────────────────────────────────────────┤
│  i18n-expert    │  offline-expert  │  accessibility-expert      │
│  (haiku)        │  (sonnet)        │  (sonnet)                  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                   TIER 3: UTILITY AGENTS                         │
│              (Fast, focused, high-volume tasks)                  │
├─────────────────────────────────────────────────────────────────┤
│  code-reviewer  │  type-checker    │  lint-fixer                │
│  (haiku)        │  (haiku)         │  (haiku)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                TIER 4: PROJECT-SPECIFIC AGENTS                   │
│              (Deep domain knowledge for each project)            │
├─────────────────────────────────────────────────────────────────┤
│ two-socks-context │ maggie-context │ quiet-kicks-context │ wedding-context │
│ (sonnet)          │ (sonnet)       │ (sonnet)            │ (sonnet)        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tier 1: Core Shared Agents

### react-expert
- **Tier:** 1
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** React is the foundation of all 4 repos. This agent encapsulates React 18/19 patterns, hooks, context, state management, and component architecture used across the stack.

**Key Knowledge:**
- React 18/19 features and patterns
- Functional components with hooks
- Custom hook patterns (useMenuData, useDataSync, useAuth patterns from repos)
- Context API patterns (AuthContext, DeviceContext, ThemeContext)
- Zustand state management (two-socks pattern)
- Props drilling vs context decisions
- Performance patterns (useMemo, useCallback, React.lazy)
- Framer Motion animation patterns
- Component composition patterns

**Repos Affected:** All 4
**Priority:** Essential

---

### supabase-expert
- **Tier:** 1
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** Supabase is the backend for all 4 repos. This agent knows authentication, database design, RLS policies, realtime subscriptions, and edge functions.

**Key Knowledge:**
- Supabase client initialization patterns
- Authentication flows (email, magic link, anonymous, OAuth)
- Row Level Security (RLS) policy design
- Database schema design for multi-tenant apps
- Migration patterns and versioning
- Realtime subscription patterns
- Edge Function development (Deno/TypeScript)
- RPC function patterns
- Storage bucket management
- Query optimization and indexes

**Repos Affected:** All 4
**Priority:** Essential

---

### capacitor-expert
- **Tier:** 1
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** All 4 repos are Capacitor mobile apps. This agent handles native features, plugins, platform-specific code, and deployment.

**Key Knowledge:**
- Capacitor 5, 6, and 8 differences
- Plugin configuration and usage
- Status bar management
- Push notifications (local and FCM)
- Deep linking configuration
- Safe area handling
- Platform detection
- Camera and filesystem access
- App lifecycle events
- iOS and Android build processes

**Repos Affected:** All 4
**Priority:** Essential

---

## Tier 2: Specialized Shared Agents

### tailwind-ui
- **Tier:** 2
- **Model:** haiku
- **Tools:** Read, Write, Edit, Glob, Grep
- **Scope:** Shared
- **Rationale:** 3/4 repos use Tailwind CSS, 2/4 use shadcn/ui. Fast agent for styling tasks.

**Key Knowledge:**
- Tailwind CSS v3 and v4 syntax
- shadcn/ui component patterns
- CVA (class-variance-authority) variants
- cn() utility with clsx + tailwind-merge
- Radix UI primitives
- Custom theme configuration
- Responsive design patterns
- Dark mode implementation
- Animation utilities (tailwindcss-animate)
- Safe area CSS patterns

**Repos Affected:** two-socks, maggie-v3, wedding
**Priority:** Important

---

### testing-expert
- **Tier:** 2
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** Critical gap - no tests exist in any repo. This agent enables test-driven development.

**Key Knowledge:**
- Vitest configuration for Vite projects
- React Testing Library patterns
- Component testing strategies
- Hook testing with renderHook
- Mocking Supabase client
- Mocking Capacitor plugins
- Integration test patterns
- E2E testing with Playwright
- Test coverage configuration
- CI/CD test integration

**Repos Affected:** All 4
**Priority:** Critical

---

### security-expert
- **Tier:** 2
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Glob, Grep
- **Scope:** Shared
- **Rationale:** Security review needed across all repos, especially two-socks (no auth).

**Key Knowledge:**
- Authentication best practices
- Supabase RLS policy design
- Input validation patterns
- XSS prevention in React
- OWASP mobile top 10
- Secure storage patterns
- API key management
- Environment variable handling
- Auth token management
- Invite code security

**Repos Affected:** All 4
**Priority:** Important

---

### i18n-expert
- **Tier:** 2
- **Model:** haiku
- **Tools:** Read, Write, Edit, Glob, Grep
- **Scope:** Shared
- **Rationale:** 3/4 repos use i18next. Fast agent for translation tasks.

**Key Knowledge:**
- i18next configuration
- react-i18next hooks (useTranslation)
- Language detection setup
- Translation file structure
- Interpolation patterns
- Pluralization rules
- Danish (da) specific considerations
- Date/time/currency formatting for Denmark
- RTL considerations (future)
- String extraction patterns

**Repos Affected:** maggie-v3, quiet-kicks, wedding (two-socks needs setup)
**Priority:** Important

---

### offline-expert
- **Tier:** 2
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** Mobile apps need offline support. quiet-kicks has good patterns; others need work.

**Key Knowledge:**
- Offline-first architecture
- LocalStorage sync queue patterns
- IndexedDB for large data
- Service worker configuration
- Background sync
- Conflict resolution strategies
- Retry logic patterns
- Online/offline detection
- Cache invalidation
- Data persistence patterns

**Repos Affected:** All 4 (especially two-socks, wedding)
**Priority:** Important

---

### accessibility-expert
- **Tier:** 2
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Glob, Grep
- **Scope:** Shared
- **Rationale:** A11y gaps identified across all repos.

**Key Knowledge:**
- WCAG 2.1 guidelines
- ARIA attributes and roles
- Keyboard navigation
- Focus management
- Screen reader compatibility
- Color contrast requirements
- Touch target sizing
- Radix UI accessibility features
- Mobile accessibility patterns
- Testing with screen readers

**Repos Affected:** All 4
**Priority:** Important

---

## Tier 3: Utility Agents

### code-reviewer
- **Tier:** 3
- **Model:** haiku
- **Tools:** Read, Glob, Grep
- **Scope:** Shared
- **Rationale:** Quick code review for PRs and commits.

**Key Knowledge:**
- React best practices
- TypeScript patterns
- Code organization
- Performance red flags
- Security concerns
- Naming conventions
- Comment quality
- Test coverage gaps

**Repos Affected:** All 4
**Priority:** Nice-to-have

---

### type-checker
- **Tier:** 3
- **Model:** haiku
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Shared
- **Rationale:** Quick TypeScript type fixes and improvements.

**Key Knowledge:**
- TypeScript strict mode
- Generic patterns
- Type inference
- Interface vs type
- Utility types
- Type narrowing
- Declaration files
- Migration from JavaScript

**Repos Affected:** two-socks, maggie-v3, wedding (quiet-kicks for migration)
**Priority:** Nice-to-have

---

### lint-fixer
- **Tier:** 3
- **Model:** haiku
- **Tools:** Read, Write, Edit, Bash, Glob
- **Scope:** Shared
- **Rationale:** Quick ESLint fixes and configuration.

**Key Knowledge:**
- ESLint flat config
- TypeScript ESLint rules
- React Hooks rules
- Auto-fixable rules
- Prettier integration
- Custom rule configuration

**Repos Affected:** All 4
**Priority:** Nice-to-have

---

## Tier 4: Project-Specific Agents

### two-socks-context
- **Tier:** 4
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Project-specific (two-socks)
- **Rationale:** Deep knowledge of gin bar domain and specific implementation.

**Key Knowledge:**
- Gin bar domain (gins, tonics, garnishes, recipes)
- Danish hospitality context
- Menu structure and navigation
- Home bar inventory tracking
- Gin passport gamification
- Badge/achievement system
- Zustand store patterns used
- useMenuData hook specifics
- Database schema (sections, recipes, etc.)
- Price handling in øre

**Repos Affected:** two-socks only
**Priority:** Essential

---

### maggie-context
- **Tier:** 4
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Project-specific (maggie-v3)
- **Rationale:** Most complex repo with dual-mode architecture.

**Key Knowledge:**
- Family organization domain
- Chore assignment and tracking
- Points and achievement system
- Dual-mode architecture (companion + display)
- Device pairing flow
- Session recovery patterns
- Google Calendar integration
- Push notification setup
- Weather widget integration
- Pictogram mode for pre-readers
- Context API structure (Auth, Device, Date, Offline)
- Database schema (17 migrations)
- Edge Functions (8 functions)

**Repos Affected:** maggie-v3 only
**Priority:** Essential

---

### quiet-kicks-context
- **Tier:** 4
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Project-specific (quiet-kicks)
- **Rationale:** Healthcare domain with partner sync complexity.

**Key Knowledge:**
- Pregnancy tracking domain
- Kick counting modes (standard, count-to-10)
- Gestational age calculation
- Partner synchronization
- Twins support (baby1/baby2)
- Real-time presence
- Heatmap visualization
- Pattern analysis
- Offline sync queue (reference implementation)
- Theme system (neutral/girl/boy)
- Push notification patterns
- JavaScript codebase (no TypeScript)
- Capacitor 5 specifics

**Repos Affected:** quiet-kicks only
**Priority:** Essential

---

### wedding-context
- **Tier:** 4
- **Model:** sonnet
- **Tools:** Read, Write, Edit, Bash, Glob, Grep
- **Scope:** Project-specific (wedding)
- **Rationale:** Event domain with complex role system.

**Key Knowledge:**
- Wedding event domain
- Guest and invite management
- 8-role permission system
- RSVP workflow
- Memory Lane feature (swipeable albums)
- Song request queue
- Guestbook entries
- Photo sharing
- Seating arrangement
- Custom navigation (no React Router)
- Swipe gesture implementation
- Admin dashboard architecture
- Multi-tenant by wedding_id
- Invite code system

**Repos Affected:** wedding only
**Priority:** Essential

---

## Agent Count Summary

| Tier | Count | Models |
|------|-------|--------|
| Tier 1: Core | 3 | All sonnet |
| Tier 2: Specialized | 6 | 2 haiku, 4 sonnet |
| Tier 3: Utility | 3 | All haiku |
| Tier 4: Project | 4 | All sonnet |
| **Total** | **16** | 7 haiku, 9 sonnet |

---

## Installation Locations

### Shared Agents (13)
Location: `~/.claude/agents/` (symlinked from `~/git/claude-stack/agents/`)

```
~/.claude/agents/
├── react-expert.md
├── supabase-expert.md
├── capacitor-expert.md
├── tailwind-ui.md
├── testing-expert.md
├── security-expert.md
├── i18n-expert.md
├── offline-expert.md
├── accessibility-expert.md
├── code-reviewer.md
├── type-checker.md
└── lint-fixer.md
```

### Project-Specific Agents (4)
Location: `[project]/.claude/agents/`

```
~/git/two-socks/.claude/agents/
└── two-socks-context.md

~/git/family-chores/maggie-v3/.claude/agents/
└── maggie-context.md

~/git/quiet-kicks/.claude/agents/
└── quiet-kicks-context.md

~/git/wedding/.claude/agents/
└── wedding-context.md
```
