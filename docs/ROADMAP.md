# Imevul UI Roadmap

> Durable "what shipped and what remains." `[X]` landed. `[ ]` open.
> Update this file in the same change that ships, splits, or reschedules a line.

## Phase legend

- **P0 Foundation**: AGENTS.md, docs, CraftOS-PC smoke / `make run`
- **P1 Replace Cobalt**: in-repo graphics + event adapter; drop the Cobalt 2 dependency
- **P2 Bugfix**: confirmed library defects from the 2026-09-02 review
- **P3 Packaging**: installer rewrite, stop bare `UI_*` globals, version field, `.gitignore`
- **Future**: more widgets, wiki/CI, monitor attach

P1 is the first library work. Do not implement P1+ unprompted.

---

## P0 - Foundation

Goal: agents and humans can find the plan, and CraftOS-PC can mount the library for a headless smoke.

| ID | Task | Status |
| --- | --- | --- |
| P0-1 | `AGENTS.md` (read order, boundaries, verification, roadmap honesty) | [X] |
| P0-2 | `docs/ROADMAP.md` (this file) | [X] |
| P0-3 | `docs/DEVELOPMENT.md` (CraftOS-PC on CachyOS, mount at `/imevul/ui`) | [X] |
| P0-4 | Makefile + `dev/smoke.lua` + `.craftos/` gitignore (mount check, no Cobalt load) | [X] |
| P0-5 | README pointer to docs and `make smoke` / `make run` | [X] |

---

## P1 - Replace Cobalt

Goal: keep the widget tree and `gfx.*` call sites; replace `ui.lib.cobalt` with an in-repo adapter. Do not pull in Basalt, CCGL, or pixelbox.

| ID | Task | Status |
| --- | --- | --- |
| P1-1 | Graphics adapter (`newCanvas`, `renderTo`, `draw`, `print`, `rect`, `pixel`, `clear`, colors) | [X] |
| P1-2 | Overwrite flag (today: `gfx.currentCanvas.surface.overwrite` in Container / ScrollPanel) | [X] |
| P1-3 | Event loop in `App:initialize` via `os.pullEvent` (including `mouse_drag`, `mouse_scroll`, `term_resize`) | [X] |
| P1-4 | Images via `paintutils.loadImage` | [X] |
| P1-5 | Drop `cobaltPath` from `init.lua`; README / wiki no longer require Cobalt | [X] |
| P1-6 | Expand `make smoke` to `dofile` + `UI_App` + quit | [X] |

Notes: adapter is `imevul/ui/lib/graphics.lua`. App owns `os.pullEvent` (drag, scroll, generic events). Mouse is converted to 0-based in App; Container hit tests use `>= 0` and `< size` (also `P2-3`).

---

## P2 - Bugfix

Library defects only. Installer and globals are P3.

| ID | Task | Status |
| --- | --- | --- |
| P2-1 | `Container:_keyPressed` calls `Object._keyReleased` | [X] |
| P2-2 | `Container:getPositionOf` calls `Object.gePositionOf` (typo); DropDown uses `getPositionIn` | [X] |
| P2-3 | Hit test `rx > 0 and ry > 0` misses left column and top row | [X] |
| P2-4 | GridLayout row `math.ceil((index-1)/cols)-1` places index 3 of a 2-col grid on row 0 | [X] |
| P2-5 | `App:_update` never calls `Container:update` (layouts / nil-size fill only run on add/remove) | [X] |
| P2-6 | `ScrollPanel:_mouseScroll` passes `x + offsetY` into the parent handler | [X] |
| P2-7 | `overwrite = data.overwrite or true` cannot be set false | [X] |
| P2-8 | `Container:add` duplicate check compares a freshly allocated wrapper table | [X] |
| P2-9 | `Object:update` always `resize()` / `newCanvas()` even when size is unchanged | [X] |
| P2-10 | Panel / ScrollPanel read `theme.focussedText`; App theme defines `focusedText` | [X] |
| P2-11 | Dead/wrong `App:_render` calls `App:_draw()` on the class, not `self` | [X] |
| P2-12 | `List` uses nonexistent `ScrollPanel.DIR_VERTICAL` (works only by `or` fallback) | [X] |
| P2-13 | `pairs` over children plus `drawOrder == 0` treated as missing in `table.sort` | [X] |
| P2-14 | Theme table is replaced, not merged; `App:_draw` hard-codes black | [X] |
| P2-15 | ToggleButton skips `Checkbox.init`; Checkbox `_draw` calls `setText` every frame | [X] |
| P2-16 | `example-app` assigns `bar.value = cnt` instead of `setValue` | [X] |

---

## P3 - Packaging

| ID | Task | Status |
| --- | --- | --- |
| P3-1 | Rewrite `install.lua` to fetch raw file contents (not Git Trees blob JSON) | [X] |
| P3-2 | Pass the requested version through `pb_installer.lua` into `install.lua` | [X] |
| P3-3 | Stop exporting bare `UI_*` globals; return a constructor table from `init.lua` | [X] |
| P3-4 | Version field in `init.lua` | [X] |
| P3-5 | Fix `.gitignore` `lib` footgun (tracked `class.lua` would hide future lib files) | [X] |

---

## Future

| ID | Task | Status |
| --- | --- | --- |
| F-1 | Tab / Shift-Tab focus ring and default-button / Escape-to-close | [X] |
| F-2 | `term_resize` reflow (fill children + layouts) | [X] |
| F-3 | Input caret, overflow scroll, max length, left/right movement, click-to-caret | [X] |
| F-4 | More widgets (radio group, number field, tooltip, dialog helper) | [X] |
| F-5 | Wiki / in-source annotation refresh (typos, List, Events) | [ ] |
| F-6 | Optional GitHub Actions via `craftos-pc-action` | [ ] |
| F-7 | Monitor / peripheral attach (redirect, detach fallback, `monitor_touch`) | [ ] |
