# Verification

Tested through Roblox Studio MCP on 2026-11-03/04. No desktop-control automation was used for these final checks.

## Delivered files

- `StudAdminPanel.rbxm` was exported with Studio SerializationService, deserialized back into StarterGui, and tested in Play.
- The authored native model is the UI source of truth; both embedded runtime scripts are supplied in `src/`.
- Tests ran in the connected, otherwise minimal panel place, not a separately opened fresh Studio place. Fresh-place import through the documented UI is still an outstanding release check.
- A temporary play-session-only SpawnLocation was used for interaction/respawn checks. It is not part of the exported model.
- The original design remains backed up in the operator's Studio session. Rejected dashboard/reflow variants are not in this pack.

## Viewports

Measurements are actual client results. Device Simulator may report dimensions slightly different from nominal presets because of safe areas and Studio rendering.

| Test | Reported camera viewport | Safe GUI area | Uniform scale | Entire canvas in bounds |
| --- | --- | --- | --- | --- |
| Desktop, normal Studio window | 1325 × 761 | 1325 × 703 | 1.000 | Yes |
| HD desktop preset | 1918 × 1078 | 1918 × 1020 | 1.000 | Yes |
| iPad Pro M5 13-inch landscape | 1375 × 1031 | 1375 × 973 | 1.000 | Yes |
| iPhone 17 Pro landscape | 749 × 381 | 749 × 323 | 0.554 | Yes |
| iPhone 17 Pro portrait | 401 × 777 | 401 × 719 | 0.483 | Yes |
| Galaxy A06 landscape | 705 × 338 | 705 × 280 | 0.474 | Yes |

[Raw device measurements](previews/device-checks.json) accompany the screenshots. All five panels remain visible together. No claim is made that scaled phone controls meet large-touch-target accessibility guidance.

Game orientation was `Sensor`. The ScreenGui uses `CoreUISafeInsets`, `ClipToDeviceSafeArea=true`, `SafeAreaCompatibility=None`, and `ResetOnSpawn=false`. The simulator was set to Fit to Window during checks and stopped afterward; Studio was returned to Edit mode and its default viewport.

## Interactions

- Native-model Global scope selection: `Scope=Global`, preview feedback confirmed.
- Native-model close button: canvas hidden, launcher shown; launcher reopened the canvas.
- Send: preview feedback only; no remote or server action exists.
- The matching controller was also tested with actual MCP text entry (`Test message`), Send feedback, and respawn; input text and closed state persisted after respawn.
- All three referenced image IDs reported `IsLoaded=true` in the session.
- No runtime script errors were reported during the recorded device checks.

## Not verified / not implemented

- Physical touch devices, phone on-screen keyboard behavior, gamepad navigation, console overscan, VR, and every possible resolution.
- New-experience asset permissions and a separate fresh-place import.
- Real admin actions, authorization, text filtering, persistent moderation, grants, or cross-server operations.
- Interaction recordings are not included; screenshots and observed MCP state checks are provided instead.
