# Change Plan

**Analysis Date:** 2026-01-12
**Status:** All agents are NEW (no existing agents)

---

## 7.1 Updates to Existing Agents

**None** - No existing agents found.

---

## 7.2 New Agents to Create

### Tier 1: Core Shared Agents

#### react-expert.md — ✨ NEW

**Tier:** 1
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Core React expertise for all 4 repositories. Encapsulates React 18/19 patterns, hooks, state management, and component architecture.

**Knowledge Areas:**
- React 18/19 features (concurrent rendering, automatic batching)
- Functional components with hooks
- Custom hook patterns (useMenuData, useDataSync, useAuth)
- Context API (AuthContext, DeviceContext patterns)
- Zustand state management
- Framer Motion animations
- Performance optimization (useMemo, useCallback, React.lazy)
- Component composition

**Rationale:**
All repositories use React as the core framework. Centralizing React knowledge ensures consistent patterns and best practices.

**Priority:** Essential

---

#### supabase-expert.md — ✨ NEW

**Tier:** 1
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Deep Supabase expertise for authentication, database design, RLS, realtime, and edge functions.

**Knowledge Areas:**
- Client initialization patterns
- Auth flows (email, magic link, anonymous, OAuth)
- RLS policy design for multi-tenant apps
- Migration patterns
- Realtime subscriptions
- Edge Functions (Deno/TypeScript)
- RPC function patterns
- Query optimization

**Rationale:**
Supabase is the backend for all 4 repos. Database design and security patterns need specialized knowledge.

**Priority:** Essential

---

#### capacitor-expert.md — ✨ NEW

**Tier:** 1
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Native mobile expertise for Capacitor configuration, plugins, and platform-specific code.

**Knowledge Areas:**
- Capacitor 5/6/8 differences
- Plugin configuration
- Status bar and navigation bar
- Push notifications (local + FCM)
- Deep linking
- Safe area handling
- Camera, filesystem, haptics
- iOS/Android build processes

**Rationale:**
All 4 repos deploy to iOS/Android via Capacitor. Native features require specialized knowledge.

**Priority:** Essential

---

### Tier 2: Specialized Shared Agents

#### tailwind-ui.md — ✨ NEW

**Tier:** 2
**Model:** haiku
**Scope:** Shared

**Purpose:**
Fast styling agent for Tailwind CSS and shadcn/ui components.

**Knowledge Areas:**
- Tailwind CSS v3/v4
- shadcn/ui patterns
- CVA variants
- cn() utility
- Radix primitives
- Dark mode
- Animations

**Rationale:**
3/4 repos use Tailwind, 2/4 use shadcn/ui. Haiku is sufficient for styling tasks.

**Priority:** Important

---

#### testing-expert.md — ✨ NEW

**Tier:** 2
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Enable test-driven development where none exists today.

**Knowledge Areas:**
- Vitest configuration
- React Testing Library
- Component testing
- Hook testing
- Supabase mocking
- Capacitor mocking
- E2E with Playwright
- CI/CD integration

**Rationale:**
Critical gap - zero test coverage across all repos.

**Priority:** Critical

---

#### security-expert.md — ✨ NEW

**Tier:** 2
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Security review and implementation guidance.

**Knowledge Areas:**
- Auth best practices
- RLS policy design
- Input validation
- XSS prevention
- OWASP mobile top 10
- Secure storage
- API key management

**Rationale:**
Security gaps identified, especially two-socks with no auth.

**Priority:** Important

---

#### i18n-expert.md — ✨ NEW

**Tier:** 2
**Model:** haiku
**Scope:** Shared

**Purpose:**
Fast internationalization support.

**Knowledge Areas:**
- i18next configuration
- react-i18next hooks
- Translation structure
- Danish (da) specifics
- Date/time/currency formatting

**Rationale:**
3/4 repos use i18next. Haiku sufficient for translation tasks.

**Priority:** Important

---

#### offline-expert.md — ✨ NEW

**Tier:** 2
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Offline-first architecture and sync patterns.

**Knowledge Areas:**
- Sync queue patterns (quiet-kicks reference)
- LocalStorage strategies
- IndexedDB
- Service workers
- Conflict resolution
- Retry logic

**Rationale:**
Mobile apps need offline support. quiet-kicks has good patterns to replicate.

**Priority:** Important

---

#### accessibility-expert.md — ✨ NEW

**Tier:** 2
**Model:** sonnet
**Scope:** Shared

**Purpose:**
Accessibility compliance and best practices.

**Knowledge Areas:**
- WCAG 2.1
- ARIA attributes
- Keyboard navigation
- Focus management
- Screen reader support
- Color contrast

**Rationale:**
A11y gaps across all repos, important for app store compliance.

**Priority:** Important

---

### Tier 3: Utility Agents

#### code-reviewer.md — ✨ NEW

**Tier:** 3
**Model:** haiku
**Scope:** Shared

**Purpose:**
Quick code review for quality and consistency.

**Knowledge Areas:**
- React best practices
- TypeScript patterns
- Code organization
- Performance red flags

**Rationale:**
Fast feedback on code quality.

**Priority:** Nice-to-have

---

#### type-checker.md — ✨ NEW

**Tier:** 3
**Model:** haiku
**Scope:** Shared

**Purpose:**
TypeScript type fixes and improvements.

**Knowledge Areas:**
- TypeScript strict mode
- Generic patterns
- Type inference
- Migration from JS

**Rationale:**
Quick fixes for type errors.

**Priority:** Nice-to-have

---

#### lint-fixer.md — ✨ NEW

**Tier:** 3
**Model:** haiku
**Scope:** Shared

**Purpose:**
ESLint configuration and fixes.

**Knowledge Areas:**
- ESLint flat config
- TypeScript ESLint
- React Hooks rules
- Auto-fix patterns

**Rationale:**
Quick lint fixes.

**Priority:** Nice-to-have

---

### Tier 4: Project-Specific Agents

#### two-socks-context.md — ✨ NEW

**Tier:** 4
**Model:** sonnet
**Scope:** two-socks

**Purpose:**
Deep knowledge of the Two Socks gin bar app.

**Knowledge Areas:**
- Gin bar domain (recipes, gins, tonics, garnishes)
- Menu navigation patterns
- Home bar inventory
- Gin passport gamification
- Zustand store
- Database schema
- Danish øre pricing

**Rationale:**
Domain-specific knowledge for gin bar features.

**Priority:** Essential

---

#### maggie-context.md — ✨ NEW

**Tier:** 4
**Model:** sonnet
**Scope:** maggie-v3

**Purpose:**
Deep knowledge of the Maggie family chores app.

**Knowledge Areas:**
- Chore management domain
- Dual-mode architecture (companion + display)
- Device pairing and session recovery
- Google Calendar integration
- Push notifications
- Points and achievements
- Pictogram mode
- Context API structure
- 17 database migrations
- 8 edge functions

**Rationale:**
Most complex repo with unique dual-mode architecture.

**Priority:** Essential

---

#### quiet-kicks-context.md — ✨ NEW

**Tier:** 4
**Model:** sonnet
**Scope:** quiet-kicks

**Purpose:**
Deep knowledge of the Quiet Kicks pregnancy app.

**Knowledge Areas:**
- Pregnancy tracking domain
- Kick counting modes
- Gestational age calculation
- Partner sync via realtime
- Twins support
- Offline sync queue (reference implementation)
- Theme system
- JavaScript codebase
- Capacitor 5

**Rationale:**
Healthcare domain with partner sync complexity.

**Priority:** Essential

---

#### wedding-context.md — ✨ NEW

**Tier:** 4
**Model:** sonnet
**Scope:** wedding

**Purpose:**
Deep knowledge of the Krista & Peter wedding app.

**Knowledge Areas:**
- Wedding event domain
- 8-role permission system
- Invite code system
- RSVP workflow
- Memory Lane swipe UI
- Song requests
- Guestbook
- Custom navigation (no React Router)
- Admin dashboard
- Multi-tenant design

**Rationale:**
Event domain with complex role-based permissions.

**Priority:** Essential

---

## 7.3 Agents to Merge

**None** - No existing agents.

---

## 7.4 Agents to Deprecate

**None** - No existing agents.

---

## 7.5 Model Changes

**None** - All agents are new.

---

## 7.6 Summary Table

| Agent | Status | Tier | Model | Priority | Location |
|-------|--------|------|-------|----------|----------|
| react-expert | ✨ NEW | 1 | sonnet | Essential | Shared |
| supabase-expert | ✨ NEW | 1 | sonnet | Essential | Shared |
| capacitor-expert | ✨ NEW | 1 | sonnet | Essential | Shared |
| tailwind-ui | ✨ NEW | 2 | haiku | Important | Shared |
| testing-expert | ✨ NEW | 2 | sonnet | Critical | Shared |
| security-expert | ✨ NEW | 2 | sonnet | Important | Shared |
| i18n-expert | ✨ NEW | 2 | haiku | Important | Shared |
| offline-expert | ✨ NEW | 2 | sonnet | Important | Shared |
| accessibility-expert | ✨ NEW | 2 | sonnet | Important | Shared |
| code-reviewer | ✨ NEW | 3 | haiku | Nice-to-have | Shared |
| type-checker | ✨ NEW | 3 | haiku | Nice-to-have | Shared |
| lint-fixer | ✨ NEW | 3 | haiku | Nice-to-have | Shared |
| two-socks-context | ✨ NEW | 4 | sonnet | Essential | two-socks |
| maggie-context | ✨ NEW | 4 | sonnet | Essential | maggie-v3 |
| quiet-kicks-context | ✨ NEW | 4 | sonnet | Essential | quiet-kicks |
| wedding-context | ✨ NEW | 4 | sonnet | Essential | wedding |

**Totals:**
- New agents: 16
- Updated: 0
- Deprecated: 0
- Merged: 0

---

## Execution Order

1. **Create directory structure**
2. **Create Tier 1 agents** (react, supabase, capacitor) - Essential
3. **Create Tier 4 agents** (project-specific) - Essential
4. **Create Tier 2 agents** (testing, security, etc.) - Important
5. **Create Tier 3 agents** (code-reviewer, etc.) - Nice-to-have
6. **Create symlink** ~/.claude/agents → ~/git/claude-stack/agents
7. **Update project CLAUDE.md files**
8. **Verify all agents**
