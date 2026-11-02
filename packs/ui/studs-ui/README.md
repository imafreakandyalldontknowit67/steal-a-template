# Studs UI - Roblox HUD and Modal Kit

**0.1.0 | Refined private draft | UNLICENSED**

Editable HUD and nine panels: DailyRewards, Shop, Rebirth, Index, SeasonPass, Upgrades, StockShop, Settings and StarterPack.

## Installation

Back up customizations, then execute the complete `src/Build.luau` through Studio Command Bar or Studio MCP in Edit mode. It installs editable instances in `StarterGui.StudsUI`, with a Controller LocalScript and DesignCanvas containing HUD and Modals. Enter Play to interact; all panels start closed.

Reinstalling replaces only the pack root; it does not merge custom edits. Preserve source-backed changes in Build.luau. Controller.luau is a readable companion copy, not automatically synchronized back into the installer.

The included `exports/studs-ui.rbxmx` is an editable XML model. Its source consistency is checked; fresh-place XML import is still untested. The source installer is the tested route.

## Features

Generated icons and stud texture, bold outlined typography, sliding transitions, hover/press feedback, cancelled stale tweens, scrolling rewards and local demo interactions. CONFIG controls sound IDs, volume and reduced motion. Replacement audio is enabled; empty IDs disable it. PNG sources and uploaded image IDs are in assets/.

**Economy, rewards and purchases are local demos.** Production integration needs server-authoritative purchases, rewards, saving and currency validation.

## Validation

See [VERIFICATION.md](VERIFICATION.md) for Studio checks, media dependencies and remaining fidelity/platform limitations.

```powershell
python -B packs/ui/studs-ui/tools/build_export.py --check
python -B -m unittest discover -s packs/ui/studs-ui/tests
python -B packs/ui/studs-ui/tools/validate_pack.py packs/ui/studs-ui
```

Run from the repository root. Private and UNLICENSED pending permission/licensing review; no exact 1:1 match or production readiness is claimed.
