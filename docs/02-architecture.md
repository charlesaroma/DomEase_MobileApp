# 02: Architecture

The app follows the **official Flutter architecture guide** (docs.flutter.dev/app-architecture), laid out like the Artistry360 streaming app. The UI is organised **by screen**; the data layer is organised **by type**, because one repository serves many screens.

## Folders

```text
lib/
├── main.dart                  production entry
├── app.dart                   the root widget (MaterialApp.router), day and evening themes
├── routing/
│   ├── router.dart            go_router: splash first, then Today
│   └── routes.dart            every path as a constant
├── config/                    (next) flavors and which repository each flavor gets
├── utils/                     (next) small shared helpers: money.dart for UGX
├── domain/
│   ├── models/                (next) Household, Meal, Zone, ListItem… pure Dart
│   └── use_cases/             (next) rules many screens share
├── data/
│   ├── model/                 (next) API models: the exact JSON the API sends
│   ├── services/              (next) api/ (HTTP), token_store
│   └── repositories/          (next) one folder per area: meals/ zones/ shopping/ household/
└── ui/
    ├── core/
    │   ├── themes/            tokens.dart (colours, spacing, radii, motion), typography.dart, theme.dart
    │   ├── ui/                shared widgets · brand/ (the DomEase logo, painted from paths)
    │   └── view_models/       (next) state many screens share: session, household
    └── <screen>/              splash, today, then meals, clean, shop, house_help, profile
        ├── view_models/       <screen>_viewmodel.dart
        └── widgets/           <screen>_screen.dart and its private pieces

assets/
├── fonts/                     Outfit, Inter, IBM Plex Mono, Lustria + OFL.txt
└── icon/                      app-icon.png, adaptive-foreground.png, adaptive-monochrome.png

test/                          mirrors lib/
```

Folders marked (next) are created when their first file is written; an empty folder is not committed.

## Rules

- A screen never types a raw hex value, size or duration: it uses `AppColors`, `AppSpace`, `AppRadii`, `AppDurations`.
- The logo is always `DomEaseLogo`, never text in a font.
- No em or en dashes in any copy the user sees.
