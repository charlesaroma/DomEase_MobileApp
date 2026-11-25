# 04: API Contract

One contract for three clients: this app, the admin dashboard (web repo, `/admin`) and the Node.js server to come (PRD section 8.2). The seed files in `assets/demo/` (copied in the web repo at `src/data/seed/`) are the exact JSON each endpoint returns; build the server to send the same shapes and both clients switch over with no code changes.

Base: `https://api.domease.app/api/v1` (staging: `https://staging-api.domease.app/api/v1`). JSON, camelCase fields, ISO 8601 dates, money in whole Ugandan Shillings. Errors: `{ "message": "…" }` with a 4xx or 5xx status.

## Sign in (no token needed)

Every sign in answers `{ token, user: { id, name, email, phone } }`. The token (JWT) goes on every later request as `Authorization: Bearer …`. Errors are `{ message }` written for the person ("That code has expired. Send a new one.").

| Method | Path | Body |
| --- | --- | --- |
| POST | `/auth/google` | `{ idToken }` from Google Sign In on the phone; the server verifies it with Google |
| POST | `/auth/apple` | `{ idToken, name? }` from Sign in with Apple (Apple sends the name only the first time) |
| POST | `/auth/email/sign-up` | `{ name, email, password }` |
| POST | `/auth/email/sign-in` | `{ email, password }` |
| POST | `/auth/password/forgot` | `{ email }`; always 204, so it never reveals who has an account |
| POST | `/auth/phone/start` | `{ phone }` in international form (`+256772123456`); texts a 6 digit code, valid 10 minutes |
| POST | `/auth/phone/verify` | `{ phone, code }` |

## Your account (signed in)

| Method | Path | Body or response |
| --- | --- | --- |
| PATCH | `/me` | `{ name?, email?, phone? }` → the user. A new email gets a confirmation link and a new phone a 6 digit code before either can be used to sign in |
| POST | `/me/password` | `{ current, next }`; 400 with a message if `current` is wrong. Email accounts only |
| DELETE | `/me` | Deletes the account. If the person owns a home, the home and everything in it goes too; if they joined one, only their membership. 204 |
| POST | `/households/me/leave` | Leave a home someone else set up. 204; the home carries on for the others |
| GET | `/legal/:id` | `terms`, `privacy`, `premium` or `health`: `{ id, title, updated, summary, sections: [{ heading, paragraphs }] }`. Same JSON as `assets/legal/` |
| POST | `/support/reports` | `{ topic: "problem" \| "idea", message, appVersion }`; listed for the team in the admin dashboard |

Zones are the household's own: `PUT /households/me/zones` saves added, renamed, reordered and removed zones, tasks and supplies as one list.

## App endpoints (household token)

| Method | Path | Body or response | Seed |
| --- | --- | --- | --- |
| GET | `/households/me` | Household, 404 if none yet | `household.json` |
| PUT | `/households/me` | Household in, Household out | |
| POST | `/households/me/invite` | `{ code }`, the code a person types on Join a home. Same code until it is reset | |
| POST | `/households/join` | `{ code }` in, Household out; adds the signed in person as a member. 404 for an unknown code | |
| POST | `/subscriptions/checkout` | `{ plan: "monthly" \| "yearly" }`, returns the Household once paid | |
| GET | `/recipes` | Published recipes only | `recipes.json` |
| GET / PUT | `/households/me/meal-plan` | `{ breakfast: [recipeId × 7], lunch: […], … }`. The reader also accepts the web's `{ seed, premium, days: { … } }` | |
| POST | `/recipe-suggestions` | `{ name, ingredientsRaw, methodRaw, suggestedMealType? }` | |
| GET / PUT | `/households/me/zones` | Zones with tasks and consumables | `zone_templates.json` |
| GET / PUT | `/households/me/shopping` | `{ checked: [itemId], manual: [{ id, name, category, quantity, price }] }` | |
| GET | `/households/me/meal-plan/history` | `[{ weekOf, days }]`, oldest first; the server keeps each replaced week (the last 12) for Eating trends | |
| GET / PUT | `/households/me/budget` | `{ monthly, trips: [{ id, date, estimate, actual, items }] }`. Every home records trips from Done shopping; Insights is Premium | |
| GET / PUT | `/households/me/staff` | `[{ id, name, role, salary, payday, startedOn, entries: [{ id, date, kind: pay \| advance \| deduction \| bonus \| leave, amount, days, note }] }]`. Premium. Still owed for a month = salary + bonuses - advances - deductions - pay (`domain/use_cases/insights.dart`) | |
| GET | `/prices` | Market prices `{ name, pack, price, category }` | `prices.json` |
| GET | `/currencies` | `{ base, updatedAt, rates: [{ code, name, perUsd }] }` | `currencies.json` |
| GET | `/nudges` | Active nudges | `nudges.json` |
| GET | `/settings/app` | Premium prices, ads per screen, disclaimer, support email | `settings.json` |
| GET | `/house-help/questions` | Premium only | `vetting_questions.json` |
| GET | `/house-help/guides` | Premium only | `house_help_guides.json` |
| POST | `/house-help/score` | `{ answers: { questionId: optionIndex } }` → `{ fitScore, flaggedConcerns, bySection }` | |

The server is the source of truth for the plan (FR-MZ-1) and the fit score (FR-HH-4). The fit score is the sum of answer weights over the best possible total, as a whole percent; any answer weighted 1 or less is flagged. `domain/use_cases/score_candidate.dart` is the reference.

## Admin endpoints (moderator token, separate auth, PRD 7.2)

| Method | Path | Notes |
| --- | --- | --- |
| POST | `/admin/auth/sign-in` | `{ email, password }` → `{ token, user }` |
| GET | `/admin/auth/me` | The signed in team member |
| GET | `/admin/overview` | Counts for the dashboard |
| GET, POST, PATCH, DELETE | `/admin/recipes[/:id]` | The library |
| GET | `/admin/recipe-suggestions` | Pending, approved and rejected |
| POST | `/admin/recipe-suggestions/:id/approve` | Body: the normalised recipe; publishes it |
| POST | `/admin/recipe-suggestions/:id/reject` | |
| GET, PATCH | `/admin/households[/:id]` | `households.json`; PATCH `{ tier }` for support cases |
| GET | `/admin/subscriptions` | `subscriptions.json` |
| GET, POST, PATCH, DELETE | `/admin/house-help/guides[/:id]` | |
| GET, PUT | `/admin/house-help/questions` | The whole questionnaire |
| GET, POST, PATCH, DELETE | `/admin/nudges[/:id]` | |
| GET, PUT | `/admin/currencies` | PUT `{ rates }`; the server stamps `updatedAt` |
| GET, POST, PATCH | `/admin/zone-templates[/:id]` | The zones a new household starts with |
| GET, POST, PATCH, DELETE | `/admin/team[/:id]` | Roles: owner, admin, moderator |
| GET, PUT | `/admin/settings` | Same document the app reads at `/settings/app` |
