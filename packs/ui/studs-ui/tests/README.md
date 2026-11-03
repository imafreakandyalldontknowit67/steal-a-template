# Studs UI validation

The suite checks metadata validation, model/source freshness, preview coverage, and visual source contracts. For recorded Studio checks and their limits, see [VERIFICATION.md](../VERIFICATION.md). Offline tests do not establish runtime behavior or distribution rights.

## Offline commands

From the repository root, with Python 3.13 (standard library only):

```powershell
python -B -m unittest discover -s packs/ui/studs-ui/tests -v
python -B packs/ui/studs-ui/tools/validate_pack.py packs/ui/studs-ui
$LASTEXITCODE
```

An absolute pack path also works, including paths containing spaces. There is
no default path. Exit status: **0** = no definite offline failures, **1** =
failures/incomplete inspection, **2** = command-line usage error. `[WARN]` items
need review even when the exit status is zero. Neither tool installs anything,
downloads dependencies, nor runs `Build.luau`. `-B` avoids bytecode artifacts.

The unit tests create and clean up temporary metadata, lexical input, and tiny
XML trees; there is no committed fixture installer, media, or model export.
A symlink test explicitly skips if the
OS does not grant symlink creation; portable traversal/drive/UNC tests still run.

### What the offline validator checks

- Required nonempty `pack.json`, `README.md`, `CHANGELOG.md`, `CREDITS.md`, and
  `src/Build.luau`. Missing implementation files are **failures**, not skips.
- Unambiguous JSON, template field types, identity `studs-ui` / `ui`, and this
  task's **`draft` / `UNLICENSED`** metadata. A `LICENSE` is not required for this
  unlicensed draft; no license grant or release approval is implied.
- Every path under `files`, including additional nested path collections:
  existence, file type, portable relative paths, and resolved containment.
  Absolute paths, drive/UNC paths, traversal, and external symlinks fail.
- `files.model=null` and an absent `exports/studs-ui.rbxmx` are legitimate.
  However, a non-null path to a missing model fails. All discovered `.rbxmx`
  and `.rbxlx` files are XML-checked; a model is not assumed valid merely because
  its filename exists. Binary models/places and archives get explicit warnings.
- Export ScreenGui identity, direct Controller/DesignCanvas/HUD/Modals and all
  nine direct panel Frames, `ResetOnSpawn=false`, initially hidden panels,
  controller disabled flags, and embedded script text. Known text/shared-string
  Source encodings are scanned; unresolved encodings warn. Empty/absent source
  fails. XML well-formedness is **not** a Studio import or schema validation.
- Reference/supplied-media filenames, credential filenames/signatures, and
  generic secret assignments. Matched secret values are not printed. Ordinary
  preview media warns for manual rights review, not automatic rejection. These
  filename/signature checks cannot establish ownership or detect every secret;
  renamed media, archive contents, and obfuscation require a human audit.
- Heuristic source diagnostics for loaders, asset-ID `require`, network/storage
  calls, purchase/reward/remote integrations, embedded Source candidates, and
  empty default sound IDs in the editable `CONFIG` table.

The lexical scanner ignores line/long-bracket comments and ordinary strings
when looking for API calls. Explicit embedded Source literals are scanned
separately. It does **not** parse Luau, resolve functions, prove top-level CONFIG
placement, analyze interpolated strings, decode all escape sequences, or prove
event wiring. Obfuscated/indirect API access can evade it. Source diagnostics
are warnings; harmless comments mentioning APIs are not rejected. No actual
Luau parser, Studio import, visual inspection, or interaction test is claimed.
Binary `AttributesSerialize` is not decoded; use the inspection helper for
actual button attributes. Network/purchase warnings require code review before
distribution, even though they do not change the exit status.

## Manual Studio verification procedure

1. Rerun both offline commands against the merged pack. Review every warning,
   including sounds, media rights, and any dependency. Do not invent an export
   just to suppress the optional-export warning.
2. Review the complete installer and embedded Controller, then install using `src/Build.luau` in an authorized disposable Studio place.
   If an export exists, separately import that exact file into a fresh place.
3. Read the helper locally and submit its **entire contents** as code to the
   connected Studio MCP code-execution tool; return the resulting table.
   Do not turn it into a LocalScript, `require` it, or prepend the installer.

   ```powershell
   Get-Content -Raw packs/ui/studs-ui/tests/InspectInstalled.luau
   ```

4. Run once in edit mode for `StarterGui`; then start Play and run in a **local
   client** context for `PlayerGui`. A server-only MCP context has no
   `Players.LocalPlayer` and deliberately warns; it cannot certify client state.
   Wait for layout/animations to settle **outside** the helper, then inspect.
5. Initially leave `EXPECT_INITIAL_STATE=true`. For later snapshots with a
   deliberately open modal, change only this local option in the submitted
   helper text to `false`. `StarterGui` must still always have all panels closed.
   Repeat with each panel open to inspect its live geometry and scroll viewport.

The returned table contains `summary`, `findings` (`level`, `code`, `path`,
`message`), per-container `panels`, action `coverage`, visible-modal counts,
`scrolling`, and `layout`. `ok` means no definite snapshot failures, **not** that
manual interactions passed. The helper only reads instances/properties. It does
not install, activate buttons, toggle panels/settings, play sounds, yield for
animations, read protected Source, or contact external services.

Missing/duplicate/wrong-class required children, invalid action targets, missing
launcher/close coverage, disabled controllers, and initially visible panels are
failures. Pixel/layout, external close controls, inaccessible launchers, and
potential transient overlap are warnings. Hidden panels and descendants are
excluded from live pixel judgments; `StarterGui` geometry is not a rendered
viewport. Scrolled-out rows are not off-canvas failures. Rotated objects are
skipped for rectangle checks. Intentional anchors/decorations can be zero-sized;
review rather than blindly changing them. Index's external rarity tabs need not
fit within Index's rectangle: the bounds check uses the design canvas/viewport,
not a panel rectangle. The helper does not prove hit testing, z-order, tween
cancellation, controller event connections, or scrolling reachability.

## Manual interaction matrix — ALL UNEXECUTED

Record Studio version, viewport/device, input method, exact merged commit,
source-vs-export installation, observed results, and any Output errors. For
**every row**, confirm its HUD launcher opens the correct panel, its close button
closes it, other settled panels remain closed, and reopening is responsive.

| Panel | Additional checks after open/close baseline |
| --- | --- |
| DailyRewards | Exercise available claim/day controls; feedback and counters remain local demo state, no real rewards. |
| Shop | Exercise categories/items/buy controls; no marketplace prompt, Robux charge, or server purchase. |
| Rebirth | Exercise preview/confirm/cancel if present; only demo counters change, no real progression reset. |
| Index | Switch every rarity tab, including external tabs; verify alignment, reachability, selected state, collection scrolling. |
| SeasonPass | Scroll to the final tier and exercise available tier/claim controls; no live entitlement/reward. |
| Upgrades | Exercise upgrade choices; displayed levels/costs change only as documented local demonstrations. |
| StockShop | Exercise stock/item controls and scroll to the last item; no real inventory or stock changes. |
| Settings | Exercise every toggle/slider, especially reduced motion and sound controls where offered; open/close still works. |
| StarterPack | Exercise offer/CTA/close controls; clear demo feedback with no actual purchase flow. |

| Cross-panel scenario | Expected evidence to record |
| --- | --- |
| Rapid cancellation | Open A → close before tween completes → open B → close → reopen A; repeat rapid A/B/A and double activation across all nine panels. After settling, at most one visible modal, no stuck overlay, input lock, stale tween, or Output error. |
| Repeated installation | Run the real installer twice in edit mode in a disposable place. Exactly one `StarterGui.StudsUI`, one direct enabled Controller, nine panels, all initially closed; Play has no duplicated callbacks or audio. Reenter Play to avoid judging an old PlayerGui clone. |
| Resize and respawn | Inspect desktop widescreen, smaller window, narrow/tall mobile, and landscape; resize with modal open. HUD launchers, close controls, and Index tabs remain usable. Respawn in Play and confirm documented `ResetOnSpawn=false` behavior without duplicate GUI/controller instances. |
| Touch activation | Use Studio device emulation and, if available, a physical touch device. Tap all launchers/closes/actions; swipe scroll areas. No hover-only requirement, accidental clicks while scrolling, or mouse-only callback. |
| Sound IDs unset | All four installer CONFIG sound IDs empty. Exercise hover/click/open/close: no missing-ID spam or audio dependency; settings still work. |
| Sound IDs operator-set | Supply permitted audio IDs only in a disposable copy, with suitable SoundVolume. Verify each sound, repeated rapid actions, mute/volume controls if present, and graceful behavior for unavailable audio. Restore four empty defaults before distribution; do not commit the operator's IDs. |
| Motion/settings | Toggle reduced motion before/during panel transitions; repeat cancellation matrix. Check each setting's documented local behavior, selected visuals, and no unintended persistence/networking. Do not assume settings persist across sessions. |
| Scrolling | For every scroll container, reach both extremes and the final row using wheel/trackpad/touch. No unreachable clipped controls, content spill, inappropriate scroll axis, or zero viewport after resize/filtering; off-window rows are expected. |
| Demo-only state | Exercise every non-navigation action in a disposable place. Observe local feedback, then reenter Play to check documented reset behavior. Review source as well: absence of a visible purchase dialog alone does not prove absence of network/reward integration. |
| Source vs optional export | Repeat installation, helper, and interaction matrix on the exact distributed export, if provided. Compare hierarchy, controller source, initial state, and behavior; do not infer export validity from source tests. |

Do not mark these rows passed until the reviewer actually executes them. Attach
structured helper findings and separately recorded interaction results to the
pack's verification report.

Property semantics used by the helper: Roblox's official
[GuiObject reference](https://create.roblox.com/docs/reference/engine/classes/GuiObject),
[ScrollingFrame reference](https://create.roblox.com/docs/reference/engine/classes/ScrollingFrame),
and [BaseScript reference](https://create.roblox.com/docs/reference/engine/classes/BaseScript).
