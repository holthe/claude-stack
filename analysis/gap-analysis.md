# Gap Analysis — Missing Expertise

**Analysis Date:** 2026-01-12
**Repositories:** two-socks, maggie-v3, quiet-kicks, wedding

---

## 1. Testing Gaps (Critical)

### Current State
**No automated tests exist in any repository.**

| Repository | Unit Tests | Integration Tests | E2E Tests | Test Framework |
|------------|------------|-------------------|-----------|----------------|
| two-socks | None | None | None | None |
| maggie-v3 | None | None | None | None |
| quiet-kicks | None | None | None | None |
| wedding | None | None | None | None |

### Impact
- No regression protection
- Manual testing only
- Risky deployments
- Difficult refactoring

### Proposed Agent
**testing-expert** - Specialized agent for test writing with knowledge of:
- Vitest configuration for Vite projects
- React Testing Library patterns
- Component testing strategies
- Supabase mocking approaches
- Capacitor plugin testing
- E2E with Playwright

**Severity:** Critical
**Repos Affected:** All

---

## 2. TypeScript Coverage Gap

### Current State
| Repository | TypeScript | Strict Mode | Type Coverage |
|------------|------------|-------------|---------------|
| two-socks | Yes | Unknown | Good |
| maggie-v3 | Yes | Yes | Good |
| quiet-kicks | **No** | N/A | None |
| wedding | Yes | Unknown | Good |

### Impact
- quiet-kicks has no type safety
- Potential runtime errors
- Harder to refactor
- IDE support limited

### Proposed Agent
**typescript-expert** - Agent for TypeScript patterns, migrations, and strict typing

**Severity:** Important (for quiet-kicks migration)
**Repos Affected:** quiet-kicks primarily

---

## 3. Accessibility Gaps

### Current State
| Repository | ARIA Labels | Keyboard Nav | Screen Reader | Color Contrast |
|------------|-------------|--------------|---------------|----------------|
| two-socks | Missing | Unknown | Unknown | OK (dark teal) |
| maggie-v3 | Via Radix | Yes (Radix) | Unknown | OK |
| quiet-kicks | Missing | Unknown | Unknown | OK (warm palette) |
| wedding | Via Radix | Yes (Radix) | Unknown | OK |

### Impact
- May not meet WCAG guidelines
- Excludes users with disabilities
- App store rejection risk (especially iOS)

### Proposed Agent
**accessibility-expert** - Agent for a11y auditing and fixes:
- ARIA attribute patterns
- Keyboard navigation
- Focus management
- Color contrast checking
- Screen reader testing approaches

**Severity:** Important
**Repos Affected:** All (especially two-socks, quiet-kicks)

---

## 4. Offline/Caching Gaps

### Current State
| Repository | Offline Mode | Service Worker | IndexedDB | LocalStorage |
|------------|--------------|----------------|-----------|--------------|
| two-socks | None | None | None | None |
| maggie-v3 | Partial | None | None | Yes |
| quiet-kicks | Yes | None | None | Yes (queue) |
| wedding | None | None | None | Yes |

### Impact
- Poor UX on slow/no network
- Data loss risk
- Not truly mobile-ready

### Proposed Agent
**offline-expert** - Agent for offline-first patterns:
- Service worker configuration
- IndexedDB for large data
- Sync queue patterns
- Conflict resolution
- Background sync

**Severity:** Important
**Repos Affected:** All (especially two-socks, wedding)

---

## 5. Performance Gaps

### Current State
| Repository | Code Splitting | Lazy Loading | Bundle Analysis | Virtualization |
|------------|----------------|--------------|-----------------|----------------|
| two-socks | None | None | None | Available (unused) |
| maggie-v3 | None | Some | None | None |
| quiet-kicks | None | None | None | None |
| wedding | Manual chunks | None | None | None |

### Impact
- Larger initial bundle
- Slower load times
- Poor performance on low-end devices

### Proposed Agent
**performance-expert** - Agent for optimization:
- Bundle size analysis
- Code splitting strategies
- React.lazy() patterns
- Image optimization
- Memory management on mobile
- React performance patterns (useMemo, useCallback)

**Severity:** Nice-to-have
**Repos Affected:** All

---

## 6. Security Gaps

### Current State
| Repository | Auth | RLS | Input Validation | API Key Management |
|------------|------|-----|------------------|-------------------|
| two-socks | None | Unknown | Unknown | Hardcoded URL |
| maggie-v3 | Full | Yes | Basic | Env vars |
| quiet-kicks | Email/Magic | Yes | Basic | Env vars |
| wedding | Invite codes | Yes | Basic | Env vars |

### Areas of Concern
- two-socks has no authentication
- No comprehensive input validation
- Admin operations need audit
- RLS policies need review

### Proposed Agent
**security-expert** - Agent for security review:
- Authentication patterns
- RLS policy design
- Input validation
- XSS prevention
- OWASP top 10 for mobile

**Severity:** Important
**Repos Affected:** All (especially two-socks)

---

## 7. Internationalization Gaps

### Current State
| Repository | i18n Setup | Languages | Coverage | RTL |
|------------|------------|-----------|----------|-----|
| two-socks | None | 1 (DA hardcoded) | 0% | No |
| maggie-v3 | Yes | 2 (EN/DA) | ~65% | No |
| quiet-kicks | Yes | 2 (EN/DA) | ~95% | No |
| wedding | Yes | 2 (DA/EN) | ~90% | No |

### Impact
- two-socks cannot support multiple languages
- maggie-v3 has ~35 files with hardcoded strings
- No RTL support if needed

### Proposed Agent
No dedicated agent needed - covered by core stack knowledge

**Severity:** Nice-to-have
**Repos Affected:** two-socks (needs setup), maggie-v3 (needs completion)

---

## 8. CI/CD Gaps

### Current State
**No CI/CD pipelines in any repository.**

| Repository | GitHub Actions | Automated Tests | Auto Deploy | Version Tags |
|------------|----------------|-----------------|-------------|--------------|
| two-socks | None | None | None | None |
| maggie-v3 | None | None | None | None |
| quiet-kicks | None | None | None | None |
| wedding | None | None | None | None |

### Impact
- Manual deployments
- No automated quality gates
- No build verification
- Risk of broken deployments

### Proposed Agent
**devops-expert** - Agent for CI/CD setup:
- GitHub Actions workflows
- Build verification
- Test automation
- Deployment pipelines
- Environment management

**Severity:** Important
**Repos Affected:** All

---

## 9. Documentation Gaps

### Current State
| Repository | README | CLAUDE.md | API Docs | Component Docs | Architecture Docs |
|------------|--------|-----------|----------|----------------|-------------------|
| two-socks | None | None | None | None | None |
| maggie-v3 | Yes | Yes | None | None | None |
| quiet-kicks | Yes | None | None | None | None |
| wedding | Yes | Yes | None | None | None |

### Impact
- Harder onboarding
- Knowledge silos
- Inconsistent implementations

### Proposed Agent
No dedicated agent - documentation should be generated as part of development

**Severity:** Nice-to-have
**Repos Affected:** two-socks primarily

---

## 10. Complex File Analysis

### Files > 300 Lines Without Specialized Coverage

| Repository | File | Lines | Complexity |
|------------|------|-------|------------|
| two-socks | Menu.tsx | 2500+ | High (navigation states, search) |
| maggie-v3 | Home.tsx | 2000+ | High (dashboard, caching) |
| maggie-v3 | Settings.tsx | 1700+ | Medium (forms, preferences) |
| maggie-v3 | DeviceContext.tsx | 500+ | High (session recovery) |
| quiet-kicks | App.jsx | 897 | High (central state) |
| quiet-kicks | supabase.js | 626 | Medium (API layer) |
| wedding | App.tsx | 500+ | Medium (routing, gestures) |

### Proposed Agent
Large file complexity should be addressed through refactoring guidance in the core React agent.

---

## 11. Platform-Specific Gaps

### iOS-Specific
| Issue | Repos Affected |
|-------|----------------|
| Push notification setup incomplete | maggie-v3 |
| Layout issues in settings | quiet-kicks |
| Deep linking configuration | quiet-kicks, maggie-v3 |

### Android-Specific
| Issue | Repos Affected |
|-------|----------------|
| Navigation bar theming | maggie-v3 |
| Back button handling | maggie-v3, quiet-kicks |

### Proposed Agent
**capacitor-expert** - Agent for Capacitor and native platform issues

**Severity:** Important
**Repos Affected:** All mobile apps

---

## 12. Data Layer Complexity

### Areas Needing Expertise

| Area | Repos | Complexity |
|------|-------|------------|
| RLS policy design | All | High |
| Migration patterns | maggie-v3 (17), wedding (5), quiet-kicks (5), two-socks (2) | Medium |
| Edge Functions | maggie-v3 (8), quiet-kicks (1) | Medium |
| Realtime sync | maggie-v3, quiet-kicks | High |
| Offline sync queue | quiet-kicks, maggie-v3 | High |

### Proposed Agent
**supabase-expert** - Deep Supabase knowledge:
- RLS policy patterns
- Migration best practices
- Edge Function patterns
- Realtime subscription optimization
- Auth flow patterns

**Severity:** Essential
**Repos Affected:** All

---

## Gap Priority Summary

| Gap | Severity | Proposed Agent |
|-----|----------|----------------|
| No automated tests | Critical | testing-expert |
| No CI/CD | Important | devops-expert |
| Security review needed | Important | security-expert |
| Accessibility gaps | Important | accessibility-expert |
| Offline support gaps | Important | offline-expert |
| TypeScript in quiet-kicks | Important | typescript-expert |
| Performance optimization | Nice-to-have | performance-expert |
| Capacitor/native issues | Important | capacitor-expert |
| Supabase complexity | Essential | supabase-expert |

---

## Recommended New Agents (Priority Order)

1. **supabase-expert** (Essential) - Core data layer expertise
2. **testing-expert** (Critical) - Test coverage is zero
3. **capacitor-expert** (Important) - All apps are mobile
4. **security-expert** (Important) - Auth and validation gaps
5. **accessibility-expert** (Important) - Compliance requirements
6. **devops-expert** (Important) - No automation exists
7. **offline-expert** (Important) - Mobile apps need this
8. **performance-expert** (Nice-to-have) - Optimization
9. **typescript-expert** (Nice-to-have) - For quiet-kicks migration
