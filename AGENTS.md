# Working in Steal a Template

Steal a Template is a Roblox asset library. UI kits exist today; models, VFX, audio, and Luau systems are planned. This file guides agents editing the repository, not scripts inside a game.

## Find the right pack

- Read `catalog.json`, then the selected pack's README and any verification/credits files.
- Paths in the root catalog are relative to the repository root. Paths inside a pack's `pack.json` are relative to that pack.
- Treat `catalog.json` as the discovery index. Pack READMEs and source contain the detailed behavior and limitations.
- `.rbxm` is an exported Roblox model, not text. Read `src/` to inspect Luau; use Studio to inspect the instance hierarchy.
- Current packs are private drafts without a reuse license. Do not change license or release status as a side effect of editing.

## Make a scoped change

- Keep packs self-contained under `packs/<category>/<id>/`. Preserve unrelated packs and user changes.
- Inspect the actual scripts before changing them. Do not assume every pack has the same controller or configuration scheme.
- Current UI imports belong in StarterGui. Preserve editable instances; runtime code should handle behavior rather than replace the whole UI with an image.
- Build source creates the authored UI; companion runtime scripts must also match the scripts embedded in the exported model. Read the build source before running it: it may replace a named root.
- If Studio is connected, identify the intended place, snapshot preview state, and change only the selected kit. Restore the previous Play/preview state afterward.
- Persist changes in source and the native model together. If Studio/export access is unavailable, report the source-only change and stale model explicitly.
- Reuse real asset IDs from the pack. Record new uploaded IDs and source artwork. Never invent an ID or claim successful loading without checking.
- Keep original third-party references and credentials out of commits. `.ui-reference/` and `.local-reference/` are local evidence, not distributable pack assets.

## Verify what changed

- Import the final exported model and check affected UI in Play mode. Exercise changed interactions, not just static visibility.
- Capture changed panels into `previews/` and keep the gallery current. Screenshots must show the implementation.
- Update applicable checksums, pack metadata, and verification notes. Record the viewport and inputs actually tested.
- Do not infer mobile or gamepad support from a desktop screenshot. Existing device gaps remain gaps until tested.
- UI purchases, currency, inventory, and rewards are demos unless documented otherwise. Production state and transactions need authoritative server integration.
- There is no repo-wide build or test command. Use the selected pack's checks; do not invent a passing test suite.

## Keep discovery accurate

When adding or renaming a pack, update `catalog.json`, `packs/<category>/README.md`, and the root README. Verify every referenced model, source, and screenshot exists. Follow `docs/AUTHORING.md` for new packs.

Brand voice: playful in headlines, precise in instructions. Use **Steal a Template**, **Roblox Studio**, **Luau**, **UI kit**, **native model**, and **demo** consistently. Do not claim production readiness, public availability, or rights that have not been established.
