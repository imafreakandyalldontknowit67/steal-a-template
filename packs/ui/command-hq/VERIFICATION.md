# Command HQ 0.3.0 verification

Native export SHA-256: 4f38308502be97352dce5a3be9b5eeced554e9a562b504f18d1c9d399fc4d3ec; 53,560 bytes, 2,320 descendants. Final bytes were serialized/deserialized in Studio. Controller, Assets, Theme and Palette sources matched. Current gallery captures use that imported model in Play.

## Reference color revision

The latest military screenshot is the color source; the accidental Discord image was excluded. [reference-colors.json](assets/reference-colors.json) records 49 roles with exact source coordinates and literal applied RGB values. This confirms sampled property values, not pixel identity of the complete composite.

1. Color pass 1 replaced the approximate palette with per-component values. Reviewed selected tabs, sliders, dividers and body contrast; reopened shadow and header finish.
2. Color pass 2 removed the bright stacked shadow halo, added a procedural Gaussian shadow image, separated toggle/action/tab golds, and removed oversized pale button specular bands.
3. Color pass 3 inset the header paint to preserve the outer chamfer rim. Reviewed full Settings, exported/imported the model, and captured 19 runtime viewport/profile cases with 11 states each. Invalid tablet preset attempts were discarded and recaptured with ipad_6th_generation.

Evidence and originals remain in ignored .ui-reference/command-hq. Shadow falloff is estimated because a composited still does not expose alpha. Generated icons, geometry, typography and background still differ; no whole-screen pixel-perfect claim is made. Controller geometry is unchanged from 0.2.0.

The current turn began in Play. Default device and Play with Settings open are restored after testing. No place file save or public release is implied.

## Earlier behavior checks

Desktop interaction and scroll details below were established in 0.2.0 with the unchanged Controller. The final color build rechecks tab/toggle selection, image loading and blur. Physical touch/gamepad remain unverified.

## Gallery inventory

| Root-relative path | State | Current capture | README anchor | Version |
| --- | --- | --- | --- | --- |
| HUD | hud | [image](previews/hud.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/Settings/Pages/Audio | settings-audio | [image](previews/settings-audio.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/Settings/Pages/Game | settings-game | [image](previews/settings-game.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/Settings/Pages/Graphics | settings-graphics | [image](previews/settings-graphics.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/Settings/Pages/Controls | settings-controls | [image](previews/settings-controls.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/UpdateLog | update-log | [image](previews/update-log.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/RedeemCode | redeem-code | [image](previews/redeem-code.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/Missions | missions | [image](previews/missions.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/LeaveQueue | leave-queue | [image](previews/leave-queue.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| Panels/PurchaseUnit | purchase-unit | [image](previews/purchase-unit.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |
| HUD/Notifications | notifications | [image](previews/notifications.jpg) | [gallery](README.md#screenshot-gallery) | 0.3.0 |

## Actual runtime results

- Imported mouse activation: Settings opened; Game/Graphics/Audio tabs selected; the Auto Deploy sample toggle changed false→true; LOW quality acquired the gold selected surface; Master Volume changed 75→50; Interface Sounds changed true→false; Close hid Settings and disabled the owned blur. No gameplay/audio/graphics backend was altered.
- All four generated Settings icon assets reported IsLoaded=true: Game, Audio, Graphics and Controls.
- Opened every panel and all Settings tabs through the controller for capture. Those direct calls establish layout/state coverage, not touch or gamepad input coverage.
- Portrait→landscape→portrait while open and scrolled returned panel sizes 326×484→606×276→326×484 and usable bounds 358×580→638×300→358×580. CanvasPosition remained y=136; ribbon dimensions returned 36×64→36×48→36×64. No scale drift observed. Prior scroll evidence is retained in private history; controller geometry is unchanged.
- No tweened animation or hover motion is introduced. Glass reflections are static. Blur toggles immediately on open/close and was observed in Play captures. Native scrolling was previously exercised with mouse-wheel input; this revision rechecked resized/scrolled layout and bottom reachability. Intermediate visual scrolling frames remain unrecorded; do not claim full motion acceptance.
- Console output after the final imported interaction and resize checks was empty.

## Current device coverage

All rows are actual running Studio device-emulator/resized-camera cases. Raw probes and per-state image paths are in [color-device-measurements.json](exports/color-device-measurements.json). Each row captured HUD, Audio, Game, Graphics, Controls, Updates, Codes, Missions, both confirmations and Notifications (11 states). Preset insets and emulator rounding account for requested/actual differences. Resized desktop and phone-profile large-tablet cases establish geometry only. The platform orientation remains Sensor and ScreenGui uses CoreUISafeInsets.

| Case | Requested | Actual camera | Actual usable GUI | Profile | Audio evidence |
| --- | --- | --- | --- | --- | --- |
| reference | 1619×971 | 1618, 970 | 1618, 912 | average_laptop | [capture](previews/devices/v030/reference-settings-audio.jpg) |
| small-p | 360×640 | 358, 638 | 358, 580 | iphone_7 | [capture](previews/devices/v030/small-p-settings-audio.jpg) |
| small-l | 640×360 | 638, 358 | 638, 300 | iphone_7 | [capture](previews/devices/v030/small-l-settings-audio.jpg) |
| iphone-p | 402×874 | 401, 778 | 401, 720 | iphone_17_pro | [capture](previews/devices/v030/iphone-p-settings-audio.jpg) |
| iphone-l | 874×402 | 750, 381 | 750, 323 | iphone_17_pro | [capture](previews/devices/v030/iphone-l-settings-audio.jpg) |
| tall-p | 390×844 | 389, 843 | 389, 785 | iphone_7 | [capture](previews/devices/v030/tall-p-settings-audio.jpg) |
| tall-l | 844×390 | 843, 389 | 843, 331 | iphone_7 | [capture](previews/devices/v030/tall-l-settings-audio.jpg) |
| large-p | 430×932 | 429, 930 | 429, 872 | iphone_7 | [capture](previews/devices/v030/large-p-settings-audio.jpg) |
| large-l | 932×430 | 930, 429 | 930, 371 | iphone_7 | [capture](previews/devices/v030/large-l-settings-audio.jpg) |
| tablet-p | 768×1024 | 768, 1023 | 768, 965 | ipad_6th_generation | [capture](previews/devices/v030/tablet-p-settings-audio.jpg) |
| tablet-l | 1024×768 | 1023, 768 | 1023, 710 | ipad_6th_generation | [capture](previews/devices/v030/tablet-l-settings-audio.jpg) |
| large-tablet-p | 820×1180 | 819, 1179 | 819, 1121 | iphone_7 | [capture](previews/devices/v030/large-tablet-p-settings-audio.jpg) |
| large-tablet-l | 1180×820 | 1179, 819 | 1179, 761 | average_laptop | [capture](previews/devices/v030/large-tablet-l-settings-audio.jpg) |
| laptop720 | 1280×720 | 1279, 720 | 1279, 662 | average_laptop | [capture](previews/devices/v030/laptop720-settings-audio.jpg) |
| laptop768 | 1366×768 | 1365, 768 | 1365, 710 | average_laptop | [capture](previews/devices/v030/laptop768-settings-audio.jpg) |
| desktop-hd | 1920×1080 | 1919, 1079 | 1919, 1021 | average_laptop | [capture](previews/devices/v030/desktop-hd-settings-audio.jpg) |
| qhd | 2560×1440 | 2559, 1440 | 2559, 1382 | average_laptop | [capture](previews/devices/v030/qhd-settings-audio.jpg) |
| ultrawide | 2560×1080 | 2559, 1079 | 2559, 1021 | average_laptop | [capture](previews/devices/v030/ultrawide-settings-audio.jpg) |
| console | 1920×1080 | 1919, 1079 | 1919, 1021 | xbox | [capture](previews/devices/v030/console-settings-audio.jpg) |

## Limits and unfinished acceptance

The matrix covers geometry and captured visual states; it does not establish physical-device behavior, touch gestures, virtual-keyboard appearance, gamepad traversal, TV overscan or couch-distance readability. MCP mouse input in phone emulation did not establish touch activation, so those cases used controller routes. Exact below/at/above breakpoint coverage remains incomplete. Console is a layout capture, not a passed TV usability test. Small landscape panels intentionally scroll; lower endpoints were not captured for every tab at every viewport. Full responsive and motion acceptance therefore remain partial.

Purchases, rewards, queues, live missions, saving, real audio mixing, real graphics settings and rebinding are demo-only/unconnected. Five uploaded image permissions must be checked in other experiences. Native/editable design, model round trip, current gallery, desktop interactions, loaded assets and sampled responsive layout were checked; no production-readiness claim is made. This pack is prepared for the requested GitHub contribution; draft status and input-testing limits remain.

Final clean-root check: temporary authoring roots removed. Play/default Settings open: owned blur enabled; all images loaded. Desktop mouse selected Game then Audio, and Interface Sounds changed true to false with the sampled off gradient. Console output was empty. Earlier false blur probe selected an inactive preview copy; the clean-root check resolves it.
