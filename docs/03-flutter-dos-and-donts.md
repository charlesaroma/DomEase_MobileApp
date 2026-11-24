# 03: Flutter Do's and Don'ts

Shorter than Artistry360's, same spirit: every rule has a reason.

## Layout and comments

| Do | Why |
| --- | --- |
| Start every file with `// ─── Title ───` and a `///` line on the public class | Anyone can scan a folder and know each file in seconds |
| One public widget per file, private `_Parts` below it | The file name tells you where a widget lives |
| Keep files under 300 lines (`test/code_size_test.dart` fails above) | Short files are read; long ones are skimmed |
| Comment why, not what, and cite the PRD requirement (`FR-SL-2`) | The code explains itself to the next developer and to the client |

## Architecture

| Do | Don't |
| --- | --- |
| Put rules in `domain/use_cases` as pure functions | Put `if (household.tier…)` maths inside `build()` |
| Widgets read view models; view models call repositories | Import `data/` or `config/dependencies.dart` in a widget |
| Pick `_local` or `_remote` only in `config/dependencies.dart` | Import a `_local` or `_remote` file anywhere else |
| Throw a domain `Failure` from repositories | Let a `DioException` reach a screen |
| Map JSON in `data/model/*_json.dart` | Put `fromJson` on a domain model |

## Riverpod

| Do | Don't |
| --- | --- |
| `ref.watch` in `build`, `ref.read` in callbacks | `ref.read` in `build` (it won't update) |
| `select` when a widget needs one field | Rebuild a whole screen for one flag |
| Update state at once, then save (optimistic) | Make the household wait for a spinner to tick a box |
| `AsyncView` for every async screen | A blank screen while loading, or a crash on error |

## Brand

- Colours, spacing and radii come from `ui/core/themes/tokens.dart`. Never type a hex value in a widget.
- The logo is always `DomEaseLogo`. Never rebuild it from `Text`.
- Amber means "this costs money or is the one action": Premium, Start free, Pay. Nothing else.
- Status is never colour alone: `StatusPill` carries an icon and a word.
- No em or en dashes in anything a household reads.
