# Verification — Steal an Egg

Status: private repository draft. Desktop functional and visual review completed; full responsive and motion-equivalence acceptance incomplete.

## Current revision: 0.1.1 — user critique pass

This section supersedes historical 0.1.0 measurements below. Export: **49,670 bytes, 1,838 descendants, 9 panels**. The embedded controller survived serialization/deserialization unchanged.

- Revisited video 2.0s and 3.0s: backpack opens All Items, followed by Settings in a round top-bar control.
- Moved Settings out of scaled DesignCanvas. Backpack and Settings now follow the free top-bar region via [GuiService.TopbarInset](https://create.roblox.com/docs/reference/engine/classes/GuiService#TopbarInset); actual inset was (164,0)–(1701.33,58), custom group at (172,11) in screen coordinates.
- Added editable AllItems panel and a search field. Real local Tool list responds to Backpack/Character changes; built-in Backpack display is disabled to prevent duplication. Temporary test Tool appeared (1 row), unmatched search hid it (0 rows), and the test Tool was removed. Tool equip behavior is implemented but was not separately exercised.
- Replaced HUD egg, paw and Index marks with explicit antialiased shapes. Compared against video and carousel. Native/source art variations remain.
- Left-aligned bottom-left cash and speed values, with bold italic typography and corrected spacing.
- Centered both drawer arrows. ActivePets measured arrow button and text centers were both (1307.25061,394.543488).
- Added visible Fuse and Trails demo launch buttons after the user reported discovery problems. These are usability additions, not claimed original-reference controls. ShowDemoLaunchers=false hides them for world-trigger integration.
- Imported-model real mouse tests: backpack, Settings, interrupted switching, drawer close/open, Fuse launcher → three selected slots → confirmation → result/reset/dismiss, Trails launcher. No console errors.
- Inventory opening trace recorded in verification/revision-0.1.1-motion.json; sampled y=394,196,142,137 at ~0,.066,.134,.200s. Its entrance easing is inferred; exact native backpack timing is not claimed.
- All 21 gallery captures refreshed from the imported revision. Some MCP captures show a dark preview background and Roblox controls; environment/core UI are not packaged.
- Source and companion controller identical; hashes updated. Play stopped, all nine panels closed, final imported root left enabled in StarterGui. Only our transfer instance removed.
- Coverage remains desktop mouse at 1701.33 × 787.33 UI pixels; the device matrix below is still blocked.

Historical traces/instance inventory below describe 0.1.0 unless marked revision-0.1.1. Current revised controls are additionally listed in verification/revision-0.1.1-elements.csv.

## Reference evidence

User supplied seven carousel WebPs and a 47.276-second, 30 fps, 1280 × 532 MP4. Carousel images are 1333 × 682. Archived originals/hashes and derived ffmpeg frames are ignored under .ui-reference/steal-an-egg. The site carousel count was not independently verified; all seven supplied WebPs were inspected.

| Reference | Used for |
| --- | --- |
| builtbybit.webp | HUD composition |
| builtbybi23t.webp | Index geometry, Basic cards, detail, claim, baton |
| builtby3422bit.webp | Fuse layout and fox result |
| builtb423ybit.webp | Shop limited offer |
| builtb243ybit.webp | Settings |
| builtbyb3244it.webp | Speed Shop treadmill |
| built34bybit.webp | Trail final cards |
| MP4, 2.5–3.1 seconds | Settings entrance trajectory |
| MP4, extracted 3/9/15/23/27/29/33/35/37/41/43/45 seconds plus detailed adjacent frames | Main panels, scroll sections and drawer states |

## Review passes

1. **Structure:** editable HUD and eight panels built. Initial Settings/Shop captures exposed rounded typography, spacing and missing art. Evidence: ignored evidence/pass1-settings.jpg and pass1-shop.jpg.
2. **Visual controls:** corrected heavy type, native outlines/currency marks, gloss/studs, icons, offers, two passes, dragon/fox and trail variants. Compared all panel states to source frames. Evidence: runtime-shop-settled.jpg and runtime-fuse-confirm.jpg; runtime-settings-mid.jpg records motion.
3. **Runtime/export:** serialized and re-imported model, exercised normal mouse routes, modal exclusivity, slider/toggle values, selection/claim, scroll reachability, equip, grow and fuse. Found tinted rainbow pass and last cash row dimensions.
4. **Shop polish:** white gradient base, explicit coin badge, wider speed cards, two wide cash cards with bag/chest art; corrected initial 4/7 equipment state and Eternal background. Final cash5 button mouse click recorded one demo action.
5. **Final gallery:** replaced unsupported treadmill arrow glyph with artwork; compared the Index symbol again and added the baton white grip. Re-exported, re-imported, replayed fuse and all panel transitions. Affected Index/treadmill screenshots were recaptured. Unaffected gallery panels retained from the equivalent imported predecessor; their objects/controller are unchanged.

Current gallery: [README](../steal-an-egg/README.md#screenshot-gallery). Every main panel and fuse child state is present. Per-control inventory and review anchors are in verification/elements.csv. A panel-level review is not a claim of exact pixel equality for every descendant.

## Runtime checks actually run

- Native serialization/deserialization: **44,821 bytes; 1,813 descendants; 8 direct panels**. Embedded Controller source identical before/after.
- Imported LocalScript reported ControllerReady=true. Source companion matches embedded Build string.
- Real mouse HUD routes: Shop, Index, Settings, speed plus, egg and paw.
- Interrupted sequence Shop → Index → Settings → close → reopen ended with only Settings visible and at its home.
- Music slider changed .5 → approximately .249812; other-pets toggle became OFF; treadmill toggle became ON. Audio itself is not supplied or verified.
- Index selected card, claim changed to CLAIMED; vertical scrolling reached later collections.
- Three fuse slot clicks → Fuse → confirmation Yes → result visible and slots reset to “3 Pets Left”; result dismissal checked. Final exported model repeated this successfully.
- Active Pets unequip / Equip Best updated count; five demo rows produce 5/7 after Equip Best.
- Closing the pet drawer then using the egg launcher and Grow All yielded Ready!.
- Trail mouse wheel reached final card: max horizontal scroll approximately 1961.80 UI px (canvas 2793; window 831.20). Divine artwork loaded.
- Final wide cash5 Buy click reached LastDemoAction ending Shop.Content.Cash5.Buy; DemoActionCount=1. No real purchase was initiated.
- Final console output empty. Play stopped; final imported ScreenGui enabled under StarterGui with all panels closed. Only our export transfer and backup instances were removed.
- Final per-panel open/close position traces: verification/panel-motion.json. Supplemental probe: verification/final-probe.json. Raw inventory: verification/instances.json.

## Motion fidelity and limitations

Reference Settings entrance first appears near 2.833s; panel top about 154px at 2.917s, 102px at 3.0s and 96px at 3.083s. This supports about .25s visible upward travel and ease-out without obvious overshoot. The implementation uses .28s Quart Out open, .18s close, .1s hover scale 1.035 and pressed .97.

An earlier runtime trace sampled Settings y=328,130,79,74 at approximately 0,.066,.132,.200 seconds from its first sampled frame; the settled home was 74 design px. Start latency and differing viewports prevent a frame-exact comparison. Final traces cover every main panel opening and closing; endpoint visibility and positions were checked.

Detailed per-panel source timing alignment, audio, blur and real-device input remain unverified. Fuse result triggering is inferred from the static result reference. Do not describe all animations as exact matches.

## Device coverage

| Case | Requested / actual UI pixels | Method and result |
| --- | --- | --- |
| Current desktop | Actual 1701.33 × 787.33 | Studio MCP Play, mouse; all panels inspected and exercised |
| Small phone | 360 × 640; 640 × 360 | Blocked/untested: no MCP viewport/device setter |
| Tall phone | 390 × 844; 844 × 390 | Blocked/untested: no MCP viewport/device setter |
| Large phone | 430 × 932; 932 × 430 | Blocked/untested: no MCP viewport/device setter |
| 4:3 tablet | 768 × 1024; 1024 × 768 | Blocked/untested: no MCP viewport/device setter |
| Large tablet | 820 × 1180; 1180 × 820 | Blocked/untested: no MCP viewport/device setter |
| Small desktop | 1280 × 720; 1366 × 768 | Blocked/untested: no MCP viewport/device setter |
| Desktop | 1920 × 1080; 2560 × 1440 | Blocked/untested: no MCP viewport/device setter |
| Ultrawide | 2560 × 1080 | Blocked/untested: no MCP viewport/device setter |
| Console / TV | 1920 × 1080 + gamepad/safe area | Blocked/untested: no MCP viewport/device setter |
| Carousel reference | 1333 × 682 | Blocked/untested: no MCP viewport/device setter |
| Video reference | 1280 × 532 | Blocked/untested: no MCP viewport/device setter |
| Compact breakpoint | 649 / 650 / 651 px wide | Blocked/untested: no MCP viewport/device setter |
| Resize / rotation | small → large → small; portrait → landscape → portrait | Blocked/untested: no MCP viewport/device setter |

The tool inventory was checked for resize, preset enumeration, orientation and device input; these capabilities were unavailable. No synthetic Frame or camera FOV substitute was used. Screenshots are 1920 × 888 physical pixels and do not establish a 1920 × 1080 UI viewport. Touch, cutouts, Roblox mobile controls, safe-area behavior, keyboard navigation and gamepad are untested.

Responsive code fits a reference canvas, anchors HUD edges and scales/repositions panels below 650px width. Its compact legibility and interaction targets are **not accepted** until the matrix can run.

## Known deviations and integration boundaries

- Generated pets, egg, sneaker, trail figures, runner, cash and containers differ from the commercial source artwork; they preserve the intended themes and silhouettes.
- Text/font rendering and emoji appearance depend on Roblox/platform. The reference's placeholder Name, rarity and counters are intentionally retained.
- The scene, avatar, native topbar/backpack are not included. Fuse/Trail world launchers are unobserved.
- UI-only demos do not implement game economies, saving, pet ownership, real growth timers, purchases or audio.
- No public distribution rights review is complete. Nothing was committed or pushed.

Hashes and model metadata: verification/checksums.json.

## Fuse Return label correction

Selected slots narrowed the button to 68 design px while the label stayed 105 px wide. Label bounds now follow the button and selected text uses 16px. Tested all three slots by mouse, including return/reselect; labels fit and share the button width (78.5024 rendered UI px). Imported native model rechecked; selected/confirmation captures refreshed. Native size is now 49,715 bytes; hashes updated. Play was already running and was restarted, with the selected fuse slots left visible for inspection.

## Repository gallery refresh

All 21 gallery views were recaptured from the corrected imported model in the same running Studio session and checked together. Source/native hashes remained valid. Existing Play mode and the selected Fuse state were restored after capture. Reference originals remain ignored. This draft is included in the existing private asset repository; it is not a public release.
