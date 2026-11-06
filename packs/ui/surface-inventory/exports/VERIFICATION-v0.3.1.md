# Surface Inventory0.3.1 — title/grid clearance

- Source: `495fb8792b95631457d906eaeeb8d3735517a73fd88ee81dfd0b8384306a2d81`.
- Native model SHA-256: `5cc7b6bce81aee677c1a454c420537a29cb48a80395e70a2803fab2d15fbb85c`; 45727 bytes,6523 instances.
- Actual Studio Client testing in Place1; included Controller/Config independently inspected and matched by `tools/verify.py`.

## Focused correction

Raised the desktop title/backpack plaque22 native-canvas pixels. The first row now has20px of face clearance at rest; actual first-cell hover measured11.43px before a conservative6px combined outline allowance. Native first-cell and header coordinates were queried, not inferred from a screenshot. Portrait/compact titles were raised14/8px, preserving their grid spacing and giving25/24px rest gaps.

Actual resting and hovered Studio captures were inspected. All15 gallery states were refreshed for this spacing revision; opening and hero views were refreshed after the final opening-only safeguard. Settled-source equivalents are recorded, not falsely labeled as new full-motion tests.

## Regression checks

-27/27 sampled actual emulator title/essential bounds checks passed. Requested/actual viewport, profile and gap measurements are in `exports/device-coverage.json`. The matrix used spacing-source f583646e; final495fb879 only changes transient overshoot size/translation, which is inactive at settled phase1. No physical-input certification is implied.
- Actual open/reveal and first-slot mouse hover replayed on native UI reimported for this revision, with byte-identical embedded source restored via supported editor. Final source was serialized/deserialized again, and embedded sources/count/title verified.
- Raising the plaque initially exposed transient top clipping at peak overshoot. Corrected with a36% maximum visible scale overshoot and small downward recenter during overshoot, leaving normal geometry unchanged.
- A final136-sample actual RenderStepped opening trace at logical1279x720 measured title top at least4.46px and panel bottom at most713.78px. Corresponding opening/stagger screenshots were inspected. This is sampled desktop motion coverage, not every in-flight mobile state.
- Runtime console clean. User already had Play running; returned to Play with inventory open, default simulator, original simulator orientation, and24 temporary device presets removed.

Private source evidence: `.ui-reference/surface-motion/revision-04/` including matrix.json, motion.json, before model/image and original Studio captures.

## Limits and historical evidence

The source-video scaling/easing/speed and exact original idle controller remain unmeasured. New numeric source-video comparison is still blocked by unknown source viewport/scaling; no invalid pixel score was substituted.

The prior0.3 headless,82-pixel roundtrip retention, full hover/stud trace, camera/respawn/teardown and rotation checks retain their original version in [historical verification](exports/VERIFICATION-v0.3.0.md), `exports/v0.3-studio-verification.json` and `exports/v0.3-device-coverage.json`. They are not represented as rerun full lifecycle/device-motion certification for this small fix.

Direct MCP parenting of serialized scripts remains policy-blocked; supported script-editor restoration was used. Fresh one-step Insert from File and other-owner image access remain uncertified. Real touch, physical gamepad/TV/VR, production inventory/economy and soundtrack integration are unverified. AlwaysOnTop=false means very close world geometry may occlude this camera-relative surface. Private UNLICENSED draft; no commit/push/publish.
