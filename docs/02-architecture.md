# 02: Architecture

The app follows the **official Flutter architecture guide** (docs.flutter.dev/app-architecture), laid out like the Artistry360 streaming app. The UI is organised **by screen**; the data layer is organised **by type**, because one repository serves many screens. `test/architecture_test.dart` enforces the rules on this page.

## What changed from Artistry360, and why

| Artistry360 | DomEase | Why |
| --- | --- | --- |
| Riverpod with code generation (`@riverpod`, `.g.dart`) | Plain Riverpod 3 providers and Notifiers | No `build_runner` step to forget, no generated files in review, faster builds. Riverpod 3's `Notifier` API is short enough by hand. |
| `json_serializable` API model classes plus `toEntity()` | One small mapper file per area in `data/model/` (`recipe_json.dart`) | Same separation (JSON never reaches a screen) with half the code and nothing generated. |
| Demo repositories read-only | Demo repositories write to the phone (`PrefsStore`) | The development build is a fully working app: tick tasks, add items, finish onboarding, try Premium, and it survives a restart. |
| Demo JSON exported from the website's seed | `assets/demo/` is the same seed the admin dashboard uses | One API contract (docs/04-api-contract.md) for the app, the admin and the future server. |
| Widget files could reach the composition root | Widgets may not import `data/` or `config/dependencies.dart` | Screens only ever see view models, which the test checks. |

Kept as they were: flavors with one entry point each, `_local` and `_remote` repositories chosen only in `config/dependencies.dart`, domain `Failure`s instead of HTTP errors, and the code size test.

## Folders

```text
lib/
├── main.dart                  production (what the stores ship)
├── main_staging.dart          the staging API
├── main_development.dart      demo data on the phone, no server
├── app.dart                   the root widget (MaterialApp.router), day and evening themes
├── config/
│   ├── environment.dart       flavors: API address, demo data on or off
│   └── dependencies.dart      which repository and service each flavor gets
├── routing/
│   ├── router.dart            go_router: splash, Welcome, account, Setup, the four tabs, Premium
│   └── routes.dart            every path as a constant
├── utils/                     money.dart (UGX 46,500), dates.dart
├── domain/
│   ├── models/                Household, Recipe, MealPlan, Zone, ShoppingItem, Currency, House Help… pure Dart
│   └── use_cases/             scale_recipe, plan_week, build_shopping_list, convert_currency, score_candidate
├── data/
│   ├── model/                 JSON mappers: the API's exact shape in and out
│   ├── services/              api/ (dio), prefs_store (the phone), demo_assets (assets/demo)
│   └── repositories/          household/ meals/ zones/ shopping/ content/ house_help/
│       └── meals/
│           ├── meal_repository.dart          abstract: what screens can ask for
│           ├── meal_repository_remote.dart   the API
│           └── meal_repository_local.dart    demo data, saved on the phone
└── ui/
    ├── core/
    │   ├── themes/            tokens (colours, spacing, radii, motion), typography, theme
    │   ├── ui/                shared widgets: logo, app shell, premium lock, ad slot, status pill…
    │   └── view_models/       the household (and its plan), content from the admin
    └── <screen>/              splash, welcome, auth, setup, onboarding, you, profile, settings, answers, help, legal, about, today, meals, clean, shop, convert, house_help, premium, household
        ├── view_models/       <screen>_viewmodel.dart
        └── widgets/           <screen>_screen.dart and its parts

assets/
├── demo/                      the seed: recipes, prices, zone templates, nudges, settings, currencies, House Help
├── fonts/                     Outfit, Inter, IBM Plex Mono, Lustria + OFL.txt
└── icon/                      app icon sources

test/                          architecture, code size, domain use cases, an app smoke test
testing/                       fakes shared by tests (memory storage, demo scope), never shipped
```

## How data flows

```text
widget ──watch──▶ view model (Riverpod) ──▶ repository (interface)
                        │                          ├─ _local  → assets/demo + PrefsStore
                        └── domain use cases       └─ _remote → ApiClient (dio) → Node.js API
```

Example: ticking "Running low" on Dish soap calls `zonesProvider.notifier.toggleLow`, which updates the zones at once and saves them. `shoppingListProvider` watches the zones, so Shop and Today's list count update by themselves; nothing calls Shop directly.

## First run: the flow

Account first, then the home. Someone who has never signed in always meets Welcome; nobody reaches Today without an account and a home.

```text
Splash
  → signed out:                Welcome (3 slides)
                                 → Get started → Create your account
                                 → I already have an account → Welcome back
  → signed in, no home:        Setup
  → signed in with a home:     Today

Create your account / Welcome back
  Google or Apple (one tap) | phone number → 6 digit code | email (→ forgot password)
  → no home yet: Setup        → home found: Today

Setup ("Welcome, Sarah")
  Set up a new home → the questions (who, size, mood, goals, meals, currency, diet)
                    → Your home is ready → Premium offer (Start free or See plans) → Today
  Join a home       → invite code → Today
```

The splash decides with `routeOnLaunch`, every sign in screen with `routeAfterSignIn` (both in `ui/auth/view_models/auth_viewmodel.dart`). Sign out returns to Welcome. "Set up the household again" keeps the account and returns to Setup. Premium opened without a home offers "Set up my home" instead of a payment.

Demo flavor: phone code `123456`, invite code `DOM123`.

## Running it

```bash
flutter run -t lib/main_development.dart   # demo data, no server (use this until the API exists)
flutter run -t lib/main_staging.dart       # staging API
flutter run                                # production API
flutter test
```

VS Code users get all three in the Run menu (`.vscode/launch.json`).

## You, settings and legal

The initials at the top of Today open **You** (`ui/you/`): the profile card, then Home (household, Edit my answers, plan), App (Settings, Help and support) and Legal, with Sign out at the bottom.

- **Profile** (`ui/profile/`): name, email and phone, how the person signs in, Change password (email accounts), Leave this home (people who joined one) and Delete account. Deleting lists what goes and needs a tick before the red button works; Apple (guideline 5.1.1(v)) and Google Play both require deletion inside the app. The website has `/delete-account` for the Play Console.
- **Settings** (`ui/settings/`): Appearance (Match my phone, Light, Dark; the app root watches `themeModeProvider`), Currency for the household, Measurements (metric) and the reminder switches. Appearance and reminders belong to the phone (`PreferencesRepository`, the same in every flavor).
- **Edit my answers** (`ui/answers/`): the onboarding questions again, from the shared `ui/core/ui/household_choices.dart`.
- **Help** (`ui/help/`): common questions, email support (copies the address when there is no mail app), Report a problem and Share an idea (with the app version), Rate DomEase.
- **Legal** (`ui/legal/`): Terms of Use, Privacy Policy, Premium and payments, Health and dietary notice. The JSON in `assets/legal/` is the copy that works offline; the API's `/legal/:id` is the live one; the website reads the same files at `/terms`, `/privacy`, `/premium-terms` and `/health-notice`. Get them reviewed by a lawyer before launch.
- **Tablets and iPads**: every screen sits in `ReadableWidth`, a centred column up to 640 points wide (720 for legal text), so nothing stretches on a large screen and phones are unchanged.

## Cleaning zones

The four starting zones come from the admin's templates; after that the rota is the household's. Add a zone from the ready made list (`domain/models/zone_presets.dart`: Compound, Laundry, Veranda, Dining room, Children's room, Store, Garden, Animals, Car, each with starter tasks and supplies) or with a name of their own. The three dots on a zone rename it, set who looks after it, add a supply, move it up or down, or remove it (with Undo). Swipe a task left to remove it.

## Not built yet

- **Sign in, the live keys.** The screens, the flow and the API calls are built (`ui/auth/`, `data/repositories/auth/`). The development flavor runs every way in with demo accounts (phone code `123456`). For staging and production:
  - **Google:** add `google_sign_in`, the iOS and Android client ids, and replace `UnconfiguredSocialSignIn` in `config/dependencies.dart` with a class that returns Google's id token. Swap the plain "G" for Google's official button mark.
  - **Apple:** add `sign_in_with_apple`, turn on the Sign in with Apple capability in Xcode and in the Apple developer account. Apple requires it on iPhone whenever Google is offered, so the button only shows on Apple devices.
  - **Phone codes:** the server texts the code through an SMS provider that covers MTN and Airtel Uganda (Africa's Talking is the usual choice).
- **Mobile money checkout.** `HouseholdRepositoryRemote.upgrade` calls `/subscriptions/checkout`; the aggregator's hosted page opens from there.
- **AdMob.** `AdSlot` marks every placement; add `google_mobile_ads` and the unit ids to fill them.
- **Reminders.** Settings already saves the three reminder switches (`Preferences`); add `firebase_messaging` and the server's scheduler to send them (PRD 4.3, v1.5).
- **Offline first** is v1.5 (PRD 4.3).
- **Admin for support reports and legal text.** The app sends reports to `/support/reports` and reads `/legal/:id`; the dashboard needs a page for each.
