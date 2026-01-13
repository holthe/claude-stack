# Project-Specific Intelligence

**Analysis Date:** 2026-01-12

---

## 1. Two-Socks (Gin Bar App)

### Project Identity
- **Name:** Two Socks
- **App ID:** dk.affinitylabs.twosocks
- **Purpose:** Digital menu and social experience for a Danish gin bar
- **Target Users:** Bar patrons, gin enthusiasts, home mixologists
- **Business Domain:** Hospitality / Beverage service
- **Market:** Danish (Copenhagen area)

### Data Model

**Core Entities:**
```
sections          → Menu categories (e.g., "Signature Cocktails", "Classics")
gins              → Spirit inventory with botanicals, tasting notes, origin
tonics           → Mixer options with brand info
garnishes         → Ingredients by category (citrus/herbs/spices/fruit/other)
recipes           → Drinks with pricing (øre), preparation notes
recipe_garnishes  → Many-to-many recipe↔garnish
tasting_menus     → Curated flight experiences
```

**Key Relationships:**
- Recipe → Section (category)
- Recipe → Gin (base spirit)
- Recipe → Tonic (mixer)
- Recipe ↔ Garnishes (many-to-many)

**Pricing:** Stored in Danish øre (cents) - divide by 100 for DKK display

### Unique Integrations
- None currently (standalone app)
- Potential: POS integration, inventory management

### Domain Language
| Danish Term | English | Usage |
|-------------|---------|-------|
| Hjemmebar | Home Bar | Home inventory feature |
| Pas | Passport | Gin passport / achievements |
| Garniture | Garnish | Drink decoration |
| Øre | Cents | Price unit (100 øre = 1 DKK) |

### User Journeys
1. **Browse Menu** → View sections → Select drink → See details/ingredients
2. **Track Home Bar** → Mark owned gins/tonics → See possible drinks → Shopping list
3. **Gin Passport** → Check in drinks tried → Earn badges → Share progress

### Technical Debt
- Admin CRUD not connected to Supabase (console.log only)
- No authentication
- No offline support
- No real-time updates
- Inventory/passport not persisted to backend

### Roadmap Items (from code TODOs)
- Implement Supabase delete (AdminView:290)
- Implement Supabase save (AdminView:334)

---

## 2. Maggie-v3 (Family Chores App)

### Project Identity
- **Name:** Maggie
- **App ID:** com.affinitylabs.maggie
- **Purpose:** Family organization with chore management, calendar, and wall display mode
- **Target Users:** Families with children (especially pre-readers)
- **Business Domain:** Family productivity / Smart home
- **Market:** Danish families (bilingual EN/DA)

### Data Model

**Core Entities:**
```
families          → Family units
family_members    → Individual members (parents, children, managed profiles)
chores            → Task definitions with points, icons
chore_assignments → Scheduled chore instances
calendar_events   → Family calendar with Google sync
gallery_photos    → Shared family photos
family_messages   → In-family messaging
family_devices    → Wall displays and paired devices
member_stats      → Points, streaks, achievements
```

**Key Relationships:**
- Family → Members (one-to-many)
- Family → Devices (one-to-many)
- Member → Chore Assignments (one-to-many)
- Calendar Events ↔ Google Calendar (sync)

### Unique Integrations
- **Google Calendar:** Bi-directional sync via Edge Functions
- **Firebase FCM:** Push notifications
- **OpenWeatherMap:** Weather widget on display
- **Device Pairing:** 6-character codes for wall tablets

### Domain Language
| Term | Meaning |
|------|---------|
| Companion App | Mobile app for parents |
| Display Mode | Wall tablet interface for whole family |
| Managed Profile | Child account without email |
| Pictogram Mode | Icon-only UI for pre-readers |
| Device Pairing | Linking wall tablet to family |

### User Journeys
1. **Parent Setup** → Create family → Invite partner → Add children
2. **Daily Chores** → View assignments → Complete tasks → Earn points
3. **Wall Display** → View family schedule → See photos → Check chores
4. **Calendar Sync** → Connect Google Calendar → View unified schedule

### Technical Debt
- ~35 files with hardcoded English strings (i18n incomplete)
- iOS push notifications not fully configured
- Photo caching needs service worker/IndexedDB
- Calendar design needs review

### Roadmap Items (from ROADMAP.md)
- iOS push notification setup
- Notification preference toggles
- Upload handling optimization
- Language selector in display settings
- Full offline support

---

## 3. Quiet-Kicks (Pregnancy Kick Counter)

### Project Identity
- **Name:** Quiet Kicks
- **App ID:** com.affinitylabs.quietkicks
- **Purpose:** Pregnancy kick counting with partner synchronization
- **Target Users:** Expectant mothers (3rd trimester) and partners
- **Business Domain:** Healthcare / Pregnancy wellness
- **Market:** International (EN/DA bilingual)

### Data Model

**Core Entities:**
```
couples           → Paired accounts (mother + partner)
users             → User profiles with role, due date, baby names
sessions          → Kick counting sessions (standard or count-to-10)
kicks             → Individual kick events with timestamps
                    Supports twins: baby1/baby2 attribution
```

**Key Relationships:**
- Couple → Users (one-to-two)
- User → Sessions (one-to-many)
- Session → Kicks (one-to-many)
- Partner sees mother's kicks in real-time

### Unique Integrations
- **Supabase Realtime:** Live partner sync
- **Firebase FCM:** Partner notifications
- **Capacitor Haptics:** Vibration feedback on kick

### Domain Language
| Term | Meaning |
|------|---------|
| Kick Session | Timed counting period |
| Count to 10 | Mode: count 10 kicks, measure time |
| Standard Mode | Free counting mode |
| Partner Dashboard | Real-time view for partner |
| Gestational Age | Weeks+days of pregnancy |
| Due Date | Expected delivery date |

### User Journeys
1. **Mother Counting** → Start session → Tap for kicks → End + add notes
2. **Partner Watching** → View live kicks → See session history → Get notified
3. **Review Insights** → View patterns → Check heatmap → See trends
4. **Share Progress** → Generate weekly milestone card → Share to social

### Technical Debt
- No TypeScript (JavaScript only)
- iOS layout issues (text sizing, button rendering)
- Partner dashboard needs bottom navigation
- Reminder banner UX needs improvement
- Capacitor 5 (should upgrade to 6+)

### Roadmap Items (from ROADMAP.md)
**Tier 1 (Core):**
- Post-session partner invite prompt
- QR code for pairing

**Tier 2 (Engagement):**
- Educational content (Why count, When to call doctor)
- Onboarding carousel

**Tier 3 (Expansion):**
- Additional languages (ES, DE, FR, SV, NO)

**Tier 4 (Future):**
- Apple Watch companion app

---

## 4. Wedding (Wedding App)

### Project Identity
- **Name:** Krista & Peter Wedding App
- **App ID:** dk.affinitylabs.wedding
- **Purpose:** Wedding guest experience and event management
- **Target Users:** Wedding guests, couple (admin), wedding party
- **Business Domain:** Events / Weddings
- **Market:** Danish wedding (single event)
- **Date:** 2027-05-15

### Data Model

**Core Entities:**
```
weddings          → Wedding configuration (colors, dates, features)
guests            → Guest profiles with roles
invites           → 8-character invite codes
guests_invites    → M:M linking guests to invites
seating_tables    → Table assignments
rsvps             → Attendance responses + dietary notes
guest_profiles    → Extended guest info (fun facts, photos)
memory_lane_*     → Story albums and moments
schedule_events   → Timeline (day/evening events)
guestbook_entries → Guest messages
song_requests     → Music queue with upvotes
photos            → Guest photos with likes
```

**Key Relationships:**
- Wedding → Guests (one-to-many)
- Invite → Guests (many-to-many via guests_invites)
- Guest → RSVP (one-to-one)
- Guest → Table (many-to-one)

### Unique Integrations
- **Memory Lane:** Swipeable story albums with couple history
- **Song Requests:** Music queue with upvoting
- **Guestbook:** Digital guest messages
- **Photo Sharing:** Guest photo uploads with likes

### Domain Language
| Term | Meaning |
|------|---------|
| Memory Lane | Couple's story in swipeable album format |
| Toastmaster | Special role with notification powers |
| Invite Code | 8-character guest access code |
| Wedding Party | Bride/groom/best man/maid of honor |
| RSVP | Attendance confirmation + dietary info |

### Role System
| Role | Permissions |
|------|-------------|
| bride/groom | Full admin access |
| best_man/maid_of_honor | View messages, view RSVPs |
| toastmaster | Send notifications, view RSVPs, toastmaster controls |
| dj | Manage music, mark songs played |
| photographer | View-only |
| guest | Basic features only |

### User Journeys
1. **Guest Access** → Enter invite code → Select name → View app
2. **RSVP Flow** → Confirm attendance → Add dietary notes → Submit
3. **Day of Event** → View schedule → Find seat → Request songs
4. **Social Features** → Write guestbook → Upload photos → Vote on songs

### Technical Debt
- useInvite uses mock data (not connected to Supabase)
- useRSVP saves to localStorage only (needs Supabase sync)
- No React Router (custom state-based navigation)

### Roadmap Items
- Connect invite validation to Supabase
- Implement RSVP sync to database
- Add admin dashboard for couple
- Realtime photo/guestbook updates

---

## Cross-Project Domain Comparison

| Aspect | two-socks | maggie-v3 | quiet-kicks | wedding |
|--------|-----------|-----------|-------------|---------|
| **Industry** | Hospitality | Family/Home | Healthcare | Events |
| **Users** | Public | Family | Couples | Guests |
| **Data Sensitivity** | Low | Medium | High | Medium |
| **Offline Need** | Low | High | High | Medium |
| **Real-time Need** | Low | High | High | Medium |
| **Multi-tenant** | No | Yes (families) | Yes (couples) | Yes (weddings) |
| **Roles** | None | 3 (parent/child/device) | 2 (mother/partner) | 8 roles |
| **i18n** | DA only | EN/DA | EN/DA | DA/EN |
| **Auth** | None | Full | Email/Magic | Invite codes |
