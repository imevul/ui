# Development

Dev emulator is **CraftOS-PC** (C++ CC:Tweaked emulator). CCEmuX is not used.

On CachyOS / Arch the binary is usually `craftos` from AUR `craftos-pc` or `craftos-pc-bin`. This repo accepts `craftos` or `craftos-pc` on `PATH`.

Examples already `dofile('/imevul/ui/init.lua')`. The Makefile mounts the library at that path.

## Targets

```bash
make help    # list targets
make run     # GUI computer, library mounted read-only at /imevul/ui
make smoke   # headless: dofile the library, construct ui.App, quit; fail if craftos is missing or SMOKE_OK is absent
```

Save data goes to gitignored `.craftos/` (`--directory`).

`make smoke` mounts the library, `dofile`s `/imevul/ui/init.lua`, constructs `ui.App` with a `load` callback that calls `quit`, and requires `SMOKE_OK` on stdout.

## Manual equivalent

```bash
# GUI
craftos --single --id 0 --directory .craftos \
  --mount-ro /imevul/ui="$PWD/imevul/ui"

# Headless smoke
craftos --headless --id 0 --directory .craftos \
  --mount-ro /imevul/ui="$PWD/imevul/ui" \
  --script dev/smoke.lua
```

`--script` is a host path. `--mount-ro /imevul/ui=...` is the in-computer path.

In the GUI, open the Lua prompt and run:

```lua
dofile('/imevul/ui/examples/example-basic.lua')
```

Use `make smoke` to confirm the library loads without a GUI.
