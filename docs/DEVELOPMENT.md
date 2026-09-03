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
dofile('/imevul/ui/examples/example-widgets.lua')
dofile('/imevul/ui/examples/example-monitor.lua')
```

`example-monitor.lua` uses `App({ monitor = true })`: the first attached monitor (or one already present) becomes the output, detach falls back to the computer term, and `monitor_touch` is a click. Do not set `monitor` if you already redirected to a VTerm that owns the screen.

Use `make smoke` to confirm the library loads without a GUI. Smoke also adopts a 20×10 `window` as `monitor`, restores the fallback size, and — when CraftOS-PC `periphemu` is present — drives `monitor_touch` / `peripheral_detach` on a virtual `left` monitor.

## GitHub Actions

[`.github/workflows/smoke.yml`](../.github/workflows/smoke.yml) is the hosted counterpart of `make smoke`. It runs on push to `master`, pull requests, and `workflow_dispatch`.

The job checks out the repo and runs [`Commandcracker/craftos-pc-action`](https://github.com/Commandcracker/craftos-pc-action) (`@v1`, PUC Lua, not LuaJIT). `root` is the checkout, so `/imevul/ui/init.lua` exists on the computer. `--script` is the host path `/github/workspace/dev/smoke.lua` (the checkout inside the action container). Timeout is 15 seconds, matching `make smoke`. There is no repo-root `startup.lua`; success is `os.shutdown()` after `SMOKE_OK`. A hung or asserting smoke never shuts down and fails on timeout.
