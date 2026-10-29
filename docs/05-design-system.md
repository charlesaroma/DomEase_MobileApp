# 05: Design System

The DomEase brand in the app: **Terracotta and Sage**, chosen by the client. Sources: the Colour and Interface Direction (RTH-DOM-2026-BRAND-01) and the logo (RTH-DOM-2026-LOGO-01). Tokens live in `lib/ui/core/themes/tokens.dart` and match the website's `src/index.css` name for name.

## Logo

The house in bloom, drawn by `DomEaseLogo` (`lib/ui/core/ui/brand/domease_logo.dart`) from the approved artwork's paths (`brand_paths.dart`, generated, do not edit).

```dart
const DomEaseLogo(tone: LogoTone.reversed, width: 220);                                   // splash
const DomEaseLogo(layout: LogoLayout.horizontalNoTagline, height: 34);                      // app bar
const DomEaseLogo(layout: LogoLayout.markIcon, width: 48);                                  // small
```

| Layout | Use |
| --- | --- |
| `stacked` | Splash, onboarding, about. The primary logo. |
| `horizontal` / `horizontalNoTagline` | App bars, headers. |
| `mark` | The house in bloom alone. |
| `markIcon` | The mark with the heavier line, for 64 px and below. |
| `wordmark` | The name alone. |

| Tone | Ground |
| --- | --- |
| `primary` | Paper or white: clay house, sage plant, clay tulip, ink name |
| `reversed` | Clay 900 or Night |
| `clay` | One colour on light grounds |
| `white` | One colour on Clay 700 or photos |

## Colour

| Family | Role | Tokens |
| --- | --- | --- |
| Clay | The brand: logo, buttons, progress, active tab | `clay950` to `clay100`, `clay` is 700 |
| Sage | Cleaning and success. Small marks only | `sage800` to `sage100`, `sage` is 700 |
| Amber | Only for action: Premium, Start free | `amber800` to `amber200`, `amber` is 700 |
| Ink and paper | Everything else | `ink`, `ink2`, `ink3`, `paper`, `paper2`, `line`, `line2` |
| Evening | Dark mode surfaces, chosen not inverted | `night`, `nightCard`, `nightLine`, `nightText`, `nightClayTint` |

About nine tenths of every screen is paper, white or warm grey. Status is never colour alone: low stock carries a tinted pill, an icon and a word.

## Type

| Face | Use | In code |
| --- | --- | --- |
| Outfit | Display, titles, headings, buttons | `outfit()`, `AppText.display` to `subheading`, `eyebrow` |
| Inter | Body, labels, fields | `inter()`, `AppText.body`, `label`, `caption` |
| IBM Plex Mono | Shillings and counts | `AppText.money` |
| Lustria | The logo's name (drawn from paths) | none |

## Icons and launch

- App icon: the icon cut in white, sage and blush on Clay 700. Generated into `android/`, `ios/` and `web/`; sources in `assets/icon/`.
- Android adaptive icon: Clay 700 background, the mark as foreground, plus a monochrome layer for Android 13 themed icons.
- Launch screen: Clay 900 on Android and iOS, the colour the Flutter splash opens on.
