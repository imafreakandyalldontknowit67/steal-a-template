# 0.5.2 X-hover correction

Reference demo14.7-15.1s: centered enlargement then click compression. Original PTS frames/crops: private derived/x-hover. Reconstructed scales hover1.12 / held0.92 / rest1, response16/s; exact source easing is inferred. Authored15-degree tilt retained.

Actual Place1 client: hover1.119955, held0.920029, release closes, leave returns0.99999994; reopen works. RenderStepped trace saved. Native12990 instances deserialized, embedded sources equal, centered pivot retained. Supported editor restored sources to run imported tree; imported hover1.119906. New close-hover screenshot is actual Studio Client. Historical device matrix not re-certified.

## Historical0.5.1 checks (headless limitation remains unresolved)

# Surface Inventory0.5.1 — skinny scrollbar and render comparison

- Source `4c12a88ffbbc1f1353e8ff4813998754a5e4efba1a8fa360b41892caf351d1c9`.
- Studio-native SHA-256 `18557f8189aab387707c4ce4587714c100749635e5ac92484bf6a77b7294c014`, 53385 bytes,12989 instances/60 slots. Included source and native properties independently inspected.

## Correction and reference review

Desktop native scrollbar10 ->4 canvas pixels,60% thinner. Viewport width500 ->497 keeps its gutter center at x501 relative to panel. Compact width415/507 and4px thumb preserve padding; content height/sixty cells unchanged. Both supplied videos were rechecked, including dense demo and enlarged breakdown frames. **A distinct white thumb is not confidently measurable in their compressed frames**; no original thickness/endcap measurement is invented. Private findings and unresampled crops: `revision-07-reference/`.

Actual imported native UI has a4px scrollbar, with the same built-in rounded Scroll textures. A1:1 Studio render shows its painted column footprint at x569..572. Dragging the imported bar changed CanvasY to256.74; mouse wheel reached528/max528 and clicking emitted selection60. Representative phone portrait/landscape and iPad landscape essential bounds remained inside viewport. All16 current gallery states were refreshed. Native white tint is1,1,1; built-in texture/fade can make it blend softly with salmon background.

## Requested headless and Pixelmatch checks

RHR1.0.0rc1 rendered the actual final native model before/after. Native check reported no warning/error findings; assets were available from the existing offline cache. Static renderer remains an approximation, not a controller/motion runtime.

For a fair1:1 comparison, a temporary Studio Client ScreenGui cloned the exact authored Canvas/HUD without scripts, on the same white background as headless. Both original outputs1001x720; no image resize, warp or auto-alignment. GUIAbsolutePosition's58px inset convention was recorded; the screen-pixel crop is x565,y134,w12,h550. No mask. Flat QA clone was removed afterward and the real3D SurfaceGui was separately Play/input-tested.

**Pixelmatch8 threshold0.1/includeAA=false:940 /6600 mismatched pixels (14.24%).** All four reference/actual/diff/mask images were inspected; mask fully black. Here reference means headless output, **not source video**. The diff exposes a native-scrollbar paint omission in this installed headless renderer: it imports the thickness property but does not draw the thumb. We did not hide that region, change the UI to imitate the renderer, or call the result a pass.

[Comparison strip: headless / Studio / diff / mask](exports/scrollbar-comparison.png) · [Diagnostic report](exports/headless-scrollbar-diagnostic.json)

The headless/native-scrollbar fidelity check therefore remains **blocked by renderer support**. Exact source-video pixel matching is separately blocked by unmeasurable source thumb/viewport. The verified implementation result is a4px native thumb, narrower per the user's correction, and functioning real scrolling. These are not interchangeable claims.

Private full evidence bundle: `.ui-reference/surface-motion/revision-07/pixelmatch/iteration-01/`, original outputs, headless stdout/stderr and capture context. Previous0.5 real-scroll and0.4 bevel/motion reports retain original source versions under exports/.

## Limits and restored state

Native UI/source was deserialized and reinserted; raw MCP script parenting was policy-blocked, so exact embedded sources restored via supported editor. One-step fresh-place import, physical touch/gamepad/TV/VR, other-owner backpack access and production economy remain uncertified. Earlier27-case geometry is historical, not a fresh full matrix for this small correction. Close world geometry may occlude AlwaysOnTop=false UI.

User started in Play. Returned to Play with inventory open, default simulator, LandscapeRight orientation and original ScaleToPhysicalSize. Temporary flat QA clone/presets/backups removed. Private UNLICENSED draft; no commit/push/publish.
