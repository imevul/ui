# AGENTS.md — Imevul UI

Instructions for coding agents working in this repository.

## Project

- **Public name:** Imevul UI
- **What it is:** A Lua GUI widget library for ComputerCraft / CC:Tweaked
- **GitHub:** `imevul/ui`
- **License:** MIT
- **Versions:** SemVer git tags (`1.0.0`, `1.1.0`, …)

## Read order

1. This file
2. [`docs/ROADMAP.md`](docs/ROADMAP.md) before feature work or changing scope
3. [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) before emulator or test work

User instructions in chat always override this file. Note conflicts briefly; implement what the user asked.

## Boundaries

- This is a ComputerCraft / CC:Tweaked widget library. Do not add host, Minecraft, or AMP/SFTP glue.
- Do not add another UI/graphics framework (Basalt, CCGL, pixelbox, Cobalt, …). Graphics live in [`imevul/ui/lib/graphics.lua`](imevul/ui/lib/graphics.lua).
- Do not invent roadmap items. [`docs/ROADMAP.md`](docs/ROADMAP.md) is human-owned. Add or edit items only when the human explicitly asks. Do not implement P2+ unprompted.
- When a change ships, splits, or reschedules a roadmap line, update [`docs/ROADMAP.md`](docs/ROADMAP.md) in the same change. Flip `[ ]` to `[X]` only when the work has landed.

## Layout

- Library: [`imevul/ui/`](imevul/ui/) (`init.lua`, `lib/`, `modules/`, `examples/`)
- Docs: [`docs/`](docs/) (`ROADMAP.md`, `DEVELOPMENT.md`)
- Emulator harness: [`dev/`](dev/) (`smoke.lua`)
- Installers: [`install.lua`](install.lua), [`pb_installer.lua`](pb_installer.lua)

## Verification

```bash
make smoke               # CraftOS-PC headless: dofile + ui.App + quit
make run                 # CraftOS-PC GUI with the library mounted
```

If a gate cannot run, say which command failed or was skipped and why.

## Roadmap honesty

[`docs/ROADMAP.md`](docs/ROADMAP.md) is the phase-level source of truth. P0–P3 and F-1–F-6 have landed. Next work is remaining Future (F-7 monitor attach).
