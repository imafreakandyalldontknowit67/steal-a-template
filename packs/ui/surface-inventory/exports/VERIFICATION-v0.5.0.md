# Surface Inventory0.5.0 — actual desktop scrolling

- Source `567a6f7a7b0ec271fa2b81091a588f87c12cf6b998b5522996f6109c1e89f0e9`.
- Studio-native SHA-256 `06ecf35b98d77a8f82109cd89b46ab6196916cb1c62dcd13902f6ff502a21bd8`, 53399 bytes.
-12989 editable instances,60 slot buttons /64 total TextButtons,2070 native bevel centers. Included Controller/Config independently decoded and matched by tools/verify.py.

## Requested change and reference check

Breakdown20s and demo frames10/11/12/13/14/18/19/20s were rechecked; fresh timestamped originals retained under `derived/scroll-recheck/`. Increased the blank inventory cells from28 to60 to make genuine scrolling possible and fill the visible grid. The expanded count and prominent white thumb are the user's explicit extension, not a claim of an exact original60-cell design.

Desktop ScrollingFrame is500x550, content1078 high, maximum CanvasY528. Its10px white native thumb occupies the center gutter between cells and detail. Initial thumb height is approximately280.61 canvas pixels. Compact layouts use6px white thumbs. Content height now derives from actual authored slot count rather than a fixed28. No visible cells are constructed at runtime.

## Actual input and native reimport

- Actual desktop thumb drag changed CanvasY from0 to290.49.
- Actual mouse wheel reached CanvasY528/max528. Actual click emitted ItemSelected60.
- Native model was serialized, deserialized, included sources/count verified, and UI reinserted. Exact included source restored with supported script editor because raw MCP serialized-script reparent remains capability-blocked. No permission escalation; fresh one-step Insert from File remains uncertified.
- On imported final UI, the wheel again reached528 and a click selected60. The thumb is genuine scroll UI, not a fake white decorative Frame.
- Current phone portrait, phone landscape and iPad landscape projected essential bounds are clear. Portrait canvas1460/view316 was scrolled to1144, exposing cell60. Desktop starts at the first row after preview reset.
- Open/reveal, slot/action/backpack hover and pointer tilt were replayed in actual Client and captured. Sixty cells extend total sequential reveal to roughly2.2s; captures wait for settlement when appropriate.
- Background fractional movement was observed again on imported final UI; darker raised/socket bevel treatment is retained. Earlier detailed150-sample bevel-motion evidence remains at its original0.4 version, not relabeled.
- Runtime console clean. User began in Play; restored Play with inventory open, default simulator/orientation and task-owned temporary resources removed.

All16 README screenshots are current actual imported-model captures, including desktop bottom and mobile bottom. Native scrollbar local textures are Roblox's built-in Scroll textures; no new external uploaded asset IDs were invented.

## Coverage and limits

This scoped revision rechecked desktop input plus representative phone/tablet layouts; it does not claim a new full27-case hardware or motion certification. Prior27-case spacing geometry evidence is historical; source-video scale/easing/speed are still unmeasured. Scrolling viewport top/bottom may intentionally expose partial neighboring rows; left/right perimeters remain padded.

Physical touch, gamepad/TV/VR, other-owner backpack access and production economy remain unverified. Very close geometry can occlude the ordinary AlwaysOnTop=false SurfaceGui. Historical bevel/source checks: `exports/VERIFICATION-v0.4.0.md` and `exports/v0.4-studio-verification.json`. Original references and raw captures remain private under `.ui-reference/surface-motion/revision-06/`. No commit/push/publish; UNLICENSED private draft.
