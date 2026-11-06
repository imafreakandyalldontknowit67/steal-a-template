# Surface Inventory 0.3.0 verification

## Artifact and authority

- Place1, Studio MCP session `433aee66-06bd-4b27-9923-176ea00995ec`; actual **Client** Play captures and inputs, not Edit-only previews.
- Source version: `e4016f89c48860cd0da15d80364511aa2cc761c8f30ae886f24f3d1c9aef7e80`.
- Studio-native model SHA-256: `e6395955257df9111cdba61939049404e5e315f8c55b7774b70c163ee00f07ce`; 45690 bytes.
- 6523 editable native instances, 28 slots, 32 TextButtons, one SurfaceGui and ScrollingFrame, included Controller and Config. No runtime UI reconstruction, external source loader, server script or economy backend.
- Private draft. No commit, push or publish. Incoming media and raw evidence remain ignored under `.ui-reference/surface-motion/`.

## Reference reanalysis and corrections

Both supplied videos were reexamined, with fresh timestamped frames and original-size launcher/cell/bar crops. Private evidence: `derived/refinement-hover/` and `refinement-analysis/observations.md`.

| ID | Observed reference | Implemented and replayed |
| --- | --- | --- |
| G01 | Glossy red cells, complete square perimeter; hovered cell turns clockwise without reflow | Added 16px scrolling-viewport padding, center anchors and raised hover ZIndex. First left cell visibly retains its outline and tilted corners. Kept 28 cells; count is not the clipping fix. |
| H01 | Demo 0.0-1.4s: launcher moves from upright to roughly 8-10 degree clockwise, modest enlargement | Smooth +8 degree, 1.12x hover; actual mouse enter/leave checked. Slow -8 -> 0 startup settling is a reconstruction because the reference already begins with the cursor over the launcher. No claim of a measured autonomous idle cycle. |
| H02 | Demo 3.2s row3/col5 and 4.0s row3/col4 tilt individually | +8 degree, 1.08x cell hover. Hover exit returns to 0 degree / 1x; press feedback and interruption retained. |
| H03 | Breakdown 16s top-bar design-tool size 178x47; lower approximately 162x37. Demo 8-9.4s bars expand independently | Desktop top 297x82, lower269x65, centered underneath; hover1.09x. Compact sizes intentionally maintain hit targets. |
| B01 | Breakdown10s alternates light/dark bevel polarity; title faint lattice; detail subtle smaller motif | Editable Raised/Recessed layers with opposite diagonal shading on panel, title and detail. Down-left motion follows user observation; 7px/sec speed is inferred. 44px/two-cell wrap preserves alternating polarity. |

Exact original viewport/scaling/insets are unknown. **Numeric fidelity against the videos remains blocked**, not silently replaced by an implementation-to-itself score. Artwork, motif contrast and easing are still reconstructed.

## Runtime motion and interaction

Raw numeric evidence: `exports/studio-verification.json`; private originals: `revision-03/sealed/motion.json` and actual full-size screenshots. A 150-sample actual RenderStepped trace spans 14.92 seconds, covering multiple stud wraps. It records intermediate values, not just endpoints:

- Cell reaches ~8 degrees and1.08x, launcher8 degrees and1.12x, each bar1.09x. Exit sample returns cell0 degrees/1x, bars1x, launcher~0 degrees/1x.
- Stud offsets progress negative X / positive Y and wrap by44. Three wrap crossings occur in this phase-offset 14.92s trace. No missing strip was seen in gallery/capture review. Exact source speed was not measured.
- Read-only temporary startup observer on the imported model sampled launcher~ -7.59 degrees at0.087s, -1.74 at1.01s and -0.14 at2.65s. Observer removed afterward; it is not inside the model.
- Actual mouse clicks select14 and invoke primary/secondary14 on the tested version. Imported final model replay selects1 and invokes both actions1. No rewards/purchases are asserted.
- Opening overshoot and intermediate stagger captured again. Four rapid I reversals settle open with all28 cells and one proxy; no stuck bar hover.
- Actual mouse wheel reaches portrait CanvasY376 (692px content /316px viewport), exposing final row. Direct scroll-to-bottom was also captured; neither is a real-finger gesture test.
- Root disable hides surface and query proxy; camera replacement follows at~1.5006 studs. Respawn preserves SurfaceGui with ResetOnSpawn=false. Destroying root leaves zero proxies, zero drivers and no detached surface.
- Runtime console had no script errors. Studio emitted its informational camera-type restoration message during the camera test.

## Device geometry

`exports/device-coverage.json` records **27/27 actual Studio emulator geometry cases**, their requested and observed dimensions, profiles, projected essential bounds, loaded images and TextFits. Both 27-case contact sheets and the gallery were inspected. Minimum sampled hit side: **44.25px**. A scrolling viewport intentionally shows a clipped partial row at its top/bottom during scroll; its left/right square perimeter is now padded.

Coverage: six phone sizes/orientations360x640 through932x430; four tablet orientations768x1024 through1180x820; desktop1280x720/1366x768/1920x1080/2560x1440; ultrawide2560x1080; console1920x1080; seven width/height breakpoint cases; iPhone17Pro and iPadM5 in both orientations. Exact observed viewport differences and safe insets remain in JSON.

Final native UI and embedded source were checked equivalent to that matrix. Imported-model smoke rechecked reference, smallest/widest geometry and iPhone portrait -> landscape -> portrait. Repeating rotation after camera replacement and respawn also returned no outside essential bounds. The earlier0.2 rotation warning **did not reproduce in these final tests**; this does not certify every camera/game state.

Physical touch, physical gamepad navigation, TV overscan and VR are unverified. Desktop resize/geometry and injected mouse events do not certify those inputs.

## Native export and round-trip

Primary model was exported by Studio SerializationService, independently decoded by Lune, checked for correct included Controller/Config and real artwork ID86135425235678, and reimported. **MCP capability policy blocks direct reparenting of serialized scripts**; native UI was deserialized and its exact embedded source restored through the supported script editor. No capability escalation occurred. This is **not** a certified fresh-place, one-step Insert from File test.

Actual Studio Client baseline and imported-native screenshots were captured at logical1279x720 / original1466x825. Same supplied camera(0,100,0)->(0,100,-1), pointer center, no selection. Temporary QA hook froze only decorative layer offsets at(-44,-44) for both comparison captures, and was removed before motion testing. No resampling, shift or mask.

Pixelmatch8 threshold0.1/includeAA=false: **82 /1,209,450 mismatched pixels (0.00678%)**. Reference/actual/diff/mask were inspected; residual sparse edge pixels do not show a missing/clipped element. The mask is fully black. This measures **round-trip retention only**, never source-video design accuracy. Private bundle: `revision-03/roundtrip/iteration-01/`.

## Optional headless check

RHR1.0.0rc1 static-native check returned no warning/error findings and no missing assets. The exact generated/uploaded backpack PNG already exists in its offline cache; this is not a successful remote-fetch claim. Render was inspected. RHR flattens stored SurfaceGui geometry; it does not execute hover, bootstrap, camera, springs or mobile reflow, and cannot pass runtime acceptance.

## Gallery and remaining limitations

README embeds all15 actual Studio screenshots: HUD, open, selection, overshoot, stagger, both tilt directions, portrait/landscape/scroll/tablet, plus four new hover states. Four hover views are actual imported-model replays; other views use source-equivalent native geometry. Originals retained privately.

- Source-video pixel fidelity, exact speed/easing and original idle controller remain unmeasured.
- One-step native import and other-owner artwork access are not certified.
- AlwaysOnTop=false is retained for ordinary SurfaceGui capture/rendering; sufficiently close world geometry may occlude it.
- No real touch/gamepad/VR/hardware certification, production inventory/economy or soundtrack integration.
- Studio restored to Edit mode, default simulator and original camera; temporary QA script/resources removed.
- Historical0.2 runtime/device reports retain their own old version under `exports/v0.2-*` and are not current acceptance evidence.
