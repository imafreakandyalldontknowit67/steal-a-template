# Studs UI - Roblox HUD and Modal Kit

**0.1.0 | In-development, unverified draft | UNLICENSED**

A reference-guided UI using native Roblox decorations, an editable HUD, nine modal panels, and local demo interactions on a responsive **2000x1125 design canvas**. This documentation describes the fixed implementation contract, not a verified build. Studio behavior, mobile/gamepad compatibility, and visual fidelity remain unverified. No public release or download is advertised.

## Install from source

The authoritative installer entry is [`src/Build.luau`](src/Build.luau), supplied by the implementation work. If it is missing from this checkout, wait for that work to be integrated; this documentation alone cannot install the UI.

1. Open a working copy of your place in Roblox Studio **Edit mode**, not Play mode. Preserve any existing `StarterGui.StudsUI` customizations first.
2. Review the **complete** `Build.luau`, including its embedded controller and the `CONFIG` table near the top. Set configuration values as needed.
3. Open Studio's **Command Bar**, paste the complete file contents, and execute it once. Do not paste a partial excerpt or use a network loader.
4. Inspect `StarterGui.StudsUI` in Explorer. Confirm the direct `Controller` LocalScript and the hierarchy below, with all nine modals initially closed.
5. Enter **Play** to exercise the controller and local demo interactions. Stop Play before making persistent instance edits in Edit mode.

Installation and runtime require no filesystem access or network code loader. No arbitrary third-party plugin setup, package manager, or external dependency is required by the installer contract. Reading the source file before pasting is a manual preparation step, not a runtime filesystem dependency.

Re-running the installer replaces **only `StudsUI` in `StarterGui`**. It is not a merge: edits to the previous installed GUI are lost. Other UI should remain untouched; verify that before accepting the build.

## Installed hierarchy and panel guide

```text
StarterGui
  StudsUI (ScreenGui)
    Controller (LocalScript; direct child)
    DesignCanvas (2000x1125 design space, responsive)
      HUD
      Modals
        DailyRewards
        Shop
        Rebirth
        Index
        SeasonPass
        Upgrades
        StockShop
        Settings
        StarterPack
```

All nine modals start closed. `HUD` is the persistent interface region; `Modals` holds the panels. For HUD review, cover status/readout areas, panel-navigation controls, and any action or promotion regions against the supplied references. These are functional review labels, not verified child names, content, or screen positions.

| Panel | Demo scope / review focus |
| --- | --- |
| `DailyRewards` | Daily reward presentation and claim feedback; no real rewards. |
| `Shop` | Product presentation and purchase feedback; no real transactions. |
| `Rebirth` | Rebirth presentation and action feedback; no authoritative progression reset. |
| `Index` | Collection/index presentation; not a live ownership record. |
| `SeasonPass` | Progression/reward-track presentation; no entitlements or reward grants. |
| `Upgrades` | Upgrade options and action feedback; no authoritative stat changes. |
| `StockShop` | Stock/item presentation and purchase feedback; not a live inventory service. |
| `Settings` | Local settings controls; no promise of saved preferences. |
| `StarterPack` | Starter-offer presentation and purchase feedback; no entitlement grants. |

Purchases, rewards, balances, ownership, and progression shown here are **demo-only**, not persistent game data. Actual integration requires separately implemented **server-authoritative** systems for purchase verification, reward eligibility, inventory, currencies, progression, and saving. Validate client requests on the server; never treat a UI click or local state as proof of a purchase or earned reward.

## Customize

Edit `CONFIG` near the top of `Build.luau` before installation:

| Key | Purpose |
| --- | --- |
| `OpenSoundId`, `CloseSoundId` | Modal open/close audio. |
| `HoverSoundId`, `ClickSoundId` | Button hover/click audio. |
| `SoundVolume` | Volume for configured sounds. |
| `ReducedMotion` | Reduced-motion preference for controller transitions; behavior needs Studio verification. |

All four sound IDs are **empty by default**, so the default UI is silent. Supply only IDs you have permission to use and that are accessible to the target experience; test their playback there. No uploaded asset IDs are supplied. Optional audio uses Roblox's normal asset delivery, not a code loader.

Installed instances are editable in Studio: adjust text, colors, typography, spacing, sizes, and native decorations. Edit in Edit mode and save the place to retain those instance changes. To survive **rebuilding**, put the corresponding changes in `src/Build.luau` (including its generated controller/configuration), then reinstall. Editing installed instances or the installed `Controller` does not update the source.

## Validation and parent acceptance checklist

Companion tooling is supplied independently at pack-relative [`tools/validate_pack.py`](tools/validate_pack.py) and [`tests/InspectInstalled.luau`](tests/InspectInstalled.luau). Once available, follow the validator's usage and the inspection script's execution-context instructions. Static checks cannot establish Studio runtime behavior or visual fidelity. This documentation task has not run those tools or tested Studio.

The following **two-pass workflow is pending acceptance work for the parent**, not completed verification. Check items only after inspecting the integrated implementation and recording evidence.

### Pass 1 - rough layout

- [ ] Install in a fresh test place; verify hierarchy, all modals closed, and HUD regions against references.
- [ ] Compare the rough composition at **2000x1125**: scale, spacing, hierarchy, alignment, and HUD placement.
- [ ] `DailyRewards`: inspect reward layout and open/close behavior.
- [ ] `Shop`: inspect product layout and open/close behavior.
- [ ] `Rebirth`: inspect information/action layout and open/close behavior.
- [ ] `Index`: inspect collection layout and open/close behavior.
- [ ] `SeasonPass`: inspect reward-track layout and open/close behavior.
- [ ] `Upgrades`: inspect upgrade layout and open/close behavior.
- [ ] `StockShop`: inspect stock/item layout and open/close behavior.
- [ ] `Settings`: inspect control layout and open/close behavior.
- [ ] `StarterPack`: inspect offer layout and open/close behavior.

### Pass 2 - refinement and interaction

- [ ] Refine native approximations, typography, colors, borders, spacing, and button states; compare every panel and HUD region at **2000x1125** again.
- [ ] Check all scrollable content, including first/last items, clipping, and reachability.
- [ ] Exercise rapid modal switching, repeated open/close clicks, and transitions; check for stale overlays or stuck input.
- [ ] Resize across desktop and mobile-sized viewports; check canvas scaling, legibility, overlap, and accessible controls.
- [ ] Verify normal, hover, pressed, selected, and disabled states where applicable; exercise demo actions without granting real purchases or rewards.
- [ ] Confirm silence with empty IDs; test permitted IDs for open/close/hover/click behavior, volume, and rapid interaction without unwanted repeated sounds.
- [ ] Test `ReducedMotion`, desktop input, touch/mobile, gamepad navigation, and respawn behavior; document actual support and failures.
- [ ] Reinstall after an instance edit; confirm only `StudsUI` is replaced and source-backed edits persist.

No exact reference match is claimed. Missing screenshots or unobserved states are verification gaps, not evidence that an inferred layout matches the reference.

## Optional export and licensing

An XML model **may** later be generated at `exports/studs-ui.rbxmx`; its creation and correctness are not guaranteed. It is not an existing verified download. Keep `pack.json`'s `files.model` as `null` until the parent verifies the actual artifact, inspects its scripts, and tests fresh-place import and Play behavior. Only then set it to `exports/studs-ui.rbxmx` and document the verified import steps. No demo place or previews are currently advertised.

License: **UNLICENSED**; no reuse or redistribution grant is included. Review [credits and reference permissions](CREDITS.md), [repository licensing](../../../docs/LICENSING.md), and the [release checklist](../../../docs/DISTRIBUTION.md) before distribution. An export or a passing validation check does not constitute permission to publish.
