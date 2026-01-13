# Shared Patterns Analysis

**Analysis Date:** 2026-01-12
**Repositories:** two-socks, maggie-v3, quiet-kicks, wedding

---

## 1. Common Dependencies

### Core Framework
All projects use:
- **React** (18.x or 19.x)
- **Vite** (5.x - 7.x) as build tool
- **Supabase** for backend (PostgreSQL + Auth + Realtime)
- **Capacitor** for mobile (iOS/Android)

### Shared Packages (3+ repos)

| Package | two-socks | maggie-v3 | quiet-kicks | wedding |
|---------|-----------|-----------|-------------|---------|
| @supabase/supabase-js | 2.78.0 | 2.78.0 | 2.39.0 | 2.78.0 |
| @capacitor/core | 8.0.0 | 8.0.0 | 5.7.8 | 8.0.0 |
| @capacitor/status-bar | 8.0.0 | 8.0.0 | 5.0.8 | 8.0.0 |
| framer-motion | - | 12.24.12 | 11.0.0 | 12.23.26 |
| i18next | - | 25.7.4 | 25.7.3 | 25.7.3 |
| react-i18next | - | 16.5.2 | 16.5.0 | 16.5.0 |
| date-fns | - | 4.1.0 | 3.3.0 | - |
| lucide-react | - | 0.562.0 | - | 0.562.0 |

### UI Libraries

| Library | Repos Using | Notes |
|---------|-------------|-------|
| Tailwind CSS | 3 (not quiet-kicks) | v3.x or v4.x |
| shadcn/ui (Radix) | 2 (maggie, wedding) | 14-17 components |
| Framer Motion | 3 (not two-socks) | Animations |
| class-variance-authority | 2 (maggie, wedding) | Component variants |
| clsx | 2 (maggie, wedding) | Class composition |
| tailwind-merge | 2 (maggie, wedding) | Class merging |

---

## 2. TypeScript Patterns

### Configuration
Three repos use TypeScript with similar configs:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "strict": true,
    "paths": { "@/*": ["./src/*"] }
  }
}
```

### Path Alias
All TypeScript repos use `@/` alias:
```typescript
import { Button } from '@/components/ui/button'
import { supabase } from '@/lib/supabase'
```

### Type Definitions
Common pattern - centralized types file:
- `src/types/index.ts` (two-socks, maggie-v3)
- `src/lib/types.ts` (wedding)
- `src/types/*.ts` (wedding)

---

## 3. React Patterns

### Component Structure
All repos use functional components with hooks:
```typescript
export function ComponentName({ prop1, prop2 }: Props) {
  const [state, setState] = useState()
  // ...
  return <div>...</div>
}
```

### Hook Patterns

**Custom Hooks Naming:**
- `useAuth` (maggie, wedding)
- `useMenuData` (two-socks)
- `useDataSync` (quiet-kicks)
- `useLocalStorage` / `usePersistedState` (quiet-kicks, maggie)
- `useOnlineStatus` (maggie, quiet-kicks)
- `usePushNotifications` (maggie, quiet-kicks)

**Common Hook Pattern:**
```typescript
export function useCustomHook() {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchData().then(setData).catch(setError).finally(() => setLoading(false))
  }, [])

  return { data, loading, error }
}
```

### State Management Approaches

| Approach | Repos | Use Case |
|----------|-------|----------|
| Zustand | two-socks | Navigation state |
| React Context | maggie-v3 | Auth, Device, Date, Offline |
| React Context | quiet-kicks | Theme only |
| localStorage + hooks | all | Persistence |
| Props drilling | all | Component communication |

### Context Pattern (maggie-v3, quiet-kicks)
```typescript
const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  // ...
  return (
    <AuthContext.Provider value={{ user, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

---

## 4. Supabase Patterns

### Client Initialization
All repos follow the same pattern:
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### Query Patterns
```typescript
// Fetch with filters
const { data, error } = await supabase
  .from('table')
  .select('*')
  .eq('family_id', familyId)
  .order('created_at', { ascending: false })

// Error handling
if (error) throw error
return data || []
```

### Realtime Subscriptions (maggie, quiet-kicks)
```typescript
const channel = supabase
  .channel('table-changes')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'kicks' },
    (payload) => onNewKick(payload.new)
  )
  .subscribe()

// Cleanup
return () => supabase.removeChannel(channel)
```

### RLS Pattern
All repos use Row Level Security with `family_id` or `couple_id` or `wedding_id`:
```sql
CREATE POLICY "Users can view own family data"
ON table FOR SELECT
USING (family_id = auth.jwt() ->> 'family_id');
```

### RPC Functions
Used for operations that bypass RLS:
```typescript
const { data } = await supabase.rpc('create_couple')
const { data } = await supabase.rpc('pair_device_with_code', { code })
```

---

## 5. Capacitor Patterns

### Status Bar Management
All repos configure status bar:
```typescript
// capacitor.config.ts
plugins: {
  StatusBar: {
    style: 'DARK',  // or 'LIGHT'
    backgroundColor: '#ffffff'
  }
}
```

### Common Plugins Used

| Plugin | two-socks | maggie-v3 | quiet-kicks | wedding |
|--------|-----------|-----------|-------------|---------|
| @capacitor/status-bar | Yes | Yes | Yes | Yes |
| @capacitor/camera | No | Yes | No | Yes |
| @capacitor/filesystem | No | Yes | Yes | Yes |
| @capacitor/push-notifications | No | Yes | Yes | No |
| @capacitor/local-notifications | No | Yes | Yes | No |
| @capacitor/app | No | Yes | Yes | No |
| @capacitor/share | No | Yes | Yes | No |
| @capacitor/preferences | No | Yes | No | No |
| @capacitor/haptics | No | No | Yes | No |

### Platform Detection
```typescript
import { Capacitor } from '@capacitor/core'

const isNative = Capacitor.isNativePlatform()
const platform = Capacitor.getPlatform() // 'ios' | 'android' | 'web'
```

### Deep Linking (maggie, quiet-kicks)
```typescript
import { App } from '@capacitor/app'

App.addListener('appUrlOpen', ({ url }) => {
  // Handle deep link
  if (url.includes('auth-callback')) {
    handleAuthCallback(url)
  }
})
```

---

## 6. shadcn/ui Patterns (maggie, wedding)

### Component Installation
Both use similar shadcn components:
- Button, Card, Dialog, Input, Label, Tabs
- Avatar, Badge, Separator
- Sheet (mobile bottom sheets)
- Popover, Switch, DropdownMenu

### CVA Variants Pattern
```typescript
import { cva, type VariantProps } from 'class-variance-authority'

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground',
        outline: 'border border-input bg-background',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 px-3',
        lg: 'h-11 px-8',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
)
```

### cn() Utility
```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

---

## 7. i18n Patterns (maggie, quiet-kicks, wedding)

### Configuration
```typescript
// lib/i18n.ts
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: { en: { translation }, da: { translation } },
    fallbackLng: 'en',
    interpolation: { escapeValue: false }
  })
```

### Translation Structure
```json
{
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "loading": "Loading..."
  },
  "nav": {
    "home": "Home",
    "settings": "Settings"
  },
  "page": {
    "title": "Page Title"
  }
}
```

### Usage Pattern
```typescript
const { t, i18n } = useTranslation()

// Simple
t('common.save')

// With interpolation
t('messages.greeting', { name: 'Peter' })

// Language change
i18n.changeLanguage('da')
```

### Supported Languages
- English (en) - All repos
- Danish (da) - All repos with i18n

---

## 8. Folder Structure Patterns

### Common Structure
```
src/
├── components/
│   ├── ui/              # Reusable UI primitives
│   ├── layout/          # Shell, Nav, Topbar
│   └── [feature]/       # Feature-specific components
├── pages/               # Route/page components
├── hooks/               # Custom React hooks
├── lib/                 # Utilities, API clients
├── types/               # TypeScript definitions
├── context/             # React Context providers (if used)
├── locales/             # i18n translation files
├── App.tsx              # Root component
├── main.tsx             # Entry point
└── index.css            # Global styles
```

### File Naming Conventions
- Components: `PascalCase.tsx` (Button.tsx, UserCard.tsx)
- Hooks: `camelCase.ts` with `use` prefix (useAuth.ts)
- Utilities: `camelCase.ts` (supabase.ts, utils.ts)
- Types: `camelCase.ts` or `index.ts` in types/

---

## 9. Build & Development Patterns

### Vite Configuration
```typescript
// vite.config.ts
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') }
  },
  server: {
    host: true  // Network access for mobile testing
  }
})
```

### Package.json Scripts
```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "cap:sync": "npm run build && npx cap sync",
    "cap:ios": "npm run build && npx cap sync ios && npx cap open ios",
    "cap:android": "npm run build && npx cap sync android && npx cap open android"
  }
}
```

### Environment Variables
All use Vite's `VITE_` prefix:
```
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

---

## 10. Styling Patterns

### Tailwind (3 repos)
- Utility-first approach
- Custom color themes via `tailwind.config.js`
- CSS variables for theming
- `tailwindcss-animate` for animations

### Custom CSS (quiet-kicks)
- CSS variables for colors
- Glassmorphism effects
- Theme system via Context

### Safe Area Handling
```css
/* All repos handle notch/home indicator */
padding-top: env(safe-area-inset-top);
padding-bottom: env(safe-area-inset-bottom);
```

### Responsive Patterns
```typescript
// Mobile-first with breakpoints
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
className="p-4 md:p-6 lg:p-8"
```

---

## 11. Error Handling Patterns

### Supabase Error Pattern
```typescript
const { data, error } = await supabase.from('table').select()
if (error) {
  console.error('Error:', error)
  throw error  // or return null/empty
}
return data
```

### Try-Catch Pattern
```typescript
try {
  const result = await asyncOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  // Handle gracefully
  return fallbackValue
}
```

### No Error Boundaries
None of the repos implement React Error Boundaries.

---

## 12. Testing Patterns

### Current State
**No automated tests in any repository.**

- No Jest/Vitest configuration
- No React Testing Library
- No E2E tests (Cypress/Playwright)
- Manual testing checklists only (quiet-kicks ROADMAP)

### Testing Gap
This is a significant gap across all projects that should be addressed with specialized testing agents.

---

## 13. Git & Workflow Patterns

### Branch Strategy
All repos use `master` as main branch.

### Commit Message Patterns
- Feature-focused: "Add [feature name]"
- Fix-focused: "Fix [issue description]"
- Multi-item: "Add X, Y, and Z improvements"

### No CI/CD
No `.github/workflows/` found in any repo.

---

## 14. Documentation Patterns

### CLAUDE.md
Present in: maggie-v3, wedding
Purpose: AI agent context for the project

### README.md
Present in: all repos
Content: Setup instructions, features, tech stack

### ROADMAP.md
Present in: maggie-v3, quiet-kicks
Purpose: Feature tracking and priorities

### Feature Prompts (wedding)
Multiple `*_PROMPT.md` files documenting feature specifications.

---

## Summary: Key Shared Patterns

1. **React + Vite + Supabase + Capacitor** is the universal stack
2. **TypeScript** used in 3/4 repos with `@/` path alias
3. **Tailwind CSS** for styling in 3/4 repos
4. **shadcn/ui** for UI primitives in 2/4 repos
5. **i18next** for internationalization in 3/4 repos (EN + DA)
6. **Framer Motion** for animations in 3/4 repos
7. **Custom hooks** for data fetching and state persistence
8. **localStorage** for client-side caching
9. **Context API** preferred over state libraries
10. **No testing** - major gap across all repos
