# Dungeon Camera

**Client follow-camera template · native LocalScript · limited Play check**

[Download DungeonCam.rbxm](DungeonCam.rbxm?raw=1) · [Actual Play gallery](GALLERY.md) · [Verification](VERIFICATION.md)

## Included

A LocalScript that sets a Scriptable camera, uses a fixed `(18, 12, 18)` world-space offset, sets FOV to 50 and lerps toward the character every RenderStepped event. No map, UI, zoom system or collision-avoidance controller is included. The avatar, floor and colored cubes in the screenshots are test fixtures.

## Install

1. Stop Play in a disposable Roblox Studio place.
2. Import `DungeonCam.rbxm` into **StarterPlayer → StarterCharacterScripts**. The imported object is a **LocalScript** whose supplied name happens to be `StarterCharacterScripts`; do not confuse the script with its destination folder.
3. Keep one copy and remove/disable conflicting custom camera controllers in the test place.
4. Press Play. The supplied script should switch to its fixed-offset follow view.

## Customize

Edit `OFFSET`, `TARGET_FOV` and `SMOOTHNESS` in the native script. The companion extracted source under `src/` matches the supplied code; keep the native model and source synchronized when changing it. The native file is authoritative, not a generated reconstruction.

## Verification and limits

The original controller was enabled in Place3 in Play. FOV 50 and Scriptable mode were observed; settled camera-position error from the expected offset was approximately 0.000024 studs. After moving the character, follow was observed with a 2.56-stud residual error at 0.8 seconds. The source uses a per-frame lerp, so settling behavior depends on frame rate.

Respawn/reset cleanup, camera replacement, physical touch, gamepad, occlusion and zoom were not tested. The supplied code does not implement raycast collision avoidance or a zoom interface. This is not a complete production camera framework.

The embedded source comment credits `DEVJM (sorryladiesihave)`; that is a preserved source credit, not an independently verified identity or redistribution grant. See CREDITS.md and pack.json. Published as a limited preview, not a production-verified release.

## License

[MIT](LICENSE), subject to [credits and third-party terms](CREDITS.md).
