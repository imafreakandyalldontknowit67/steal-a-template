# Essential STUD UI

Editable Roblox UI recreation with reference-guided generated artwork and animated demo interactions.

**[Download EssentialStudUI.rbxm](EssentialStudUI.rbxm?raw=1)** · [Verification](exports/verification.json) · [Review notes](REVIEW.md)

Status: private UI/demo kit. Native export round-tripped and played in Studio. Not a production monetization/economy system; not a pixel-identical copy.

## Install
Right-click **StarterGui → Insert from File**, choose `EssentialStudUI.rbxm`. If imported elsewhere, move the ScreenGui into StarterGui. Press Play. No pasted script or additional plugin is needed.

The current target Studio already contains `StarterGui.EssentialStudUI`. Do not insert a second copy there. The other Place1 window containing StudsUI was left untouched.

## Included
- Left navigation, cash display, settings shortcut, staggered cycling right-side offers.
- Shop with limited-time packs, gamepasses, gifting controls and four cash products.
- Gift recipient list/username input and confirmation dialog.
- Group, daily and playtime rewards with demo claimed/locked states.
- Codes (`Cash100` demo), lucky wheel and spin-count UI, Music/SFX sliders.
- Loading overlay with skip/fade, modal slide/blur, hover/press feedback, stacked toasts, falling confetti, cash gain/loss interpolation.

## Editable hierarchy
`EssentialStudUI` contains `Canvas/HUD`, `Canvas/Panels`, `Canvas/Loading`, `Canvas/Feedback`, `Controller`, `Runtime`, `Configuration`, and `DemoAPI`.

All nine panels, cards, controls, labels and decorative layers exist at edit time. To inspect a panel, set its `Visible` property under Canvas/Panels; hide it again before saving. Wheel segments and stud patterns are native editable Frames. Artwork is in ImageLabels referencing two generated atlases. Total descendants: 11,385 (intentionally highly editable; optimize/bake decorative stud groups before constrained-device deployment).

`Configuration` controls initial cash/spins, loading, offer cadence, spin timer, playtime thresholds and demo codes. Runtime resizes the design canvas to the viewport. In Edit mode, `Canvas.ViewportScale` is the preview scale; runtime resets it automatically.

`src/Build.luau` is the developer authoring stage, creating a disabled `EssentialStudUI_Building` root. Install the three script sources into it and verify before swapping it for the named root. Ordinary users should use the native model, not this build-stage script.

## Integration and safety
**Every purchase and gift is a demo. No Robux is charged.** Demo balances/claims reset between play sessions. Production integration requires server-validated receipts, entitlements, recipient checks, persistent rewards and economy logic. DemoAPI is for local testing only and must not grant real rewards.

The sliders publish MusicVolume/SFXVolume attributes and control SoundGroups named `EssentialMusic` / `EssentialSFX` if provided. No music or sound files are included: the supplied video had no audio track.

Example local Play test: `PlayerGui.EssentialStudUI.DemoAPI:Invoke("Action", "Open:Shop")`. Other test calls include `Cash`, `Toast`, `Confetti`, and `State`. Negative cash is allowed only to demonstrate the reference loss animation.

## Gallery — actual imported model
All images below are Studio MCP captures of the deserialized native export, not reference screenshots. Edit captures use 1041×761; Play checks used 1325×761. Later changes affected only the panels whose captures were refreshed.

### HUD
![HUD](previews/hud.jpg)

### Limited-time shop
![Limited-time shop](previews/shop.jpg)

### Gamepasses
![Gamepasses](previews/shoppasses.jpg)

### Cash products
![Cash products](previews/shopproducts.jpg)

### Gift recipients
![Gift recipients](previews/gift.jpg)

### Gift confirmation
![Gift confirmation](previews/confirm.jpg)

### Group rewards
![Group rewards](previews/rewards.jpg)

### Daily rewards
![Daily rewards](previews/daily.jpg)

### Playtime rewards
![Playtime rewards](previews/time.jpg)

### Codes
![Codes](previews/codes.jpg)

### Lucky wheel
![Lucky wheel](previews/wheel.jpg)

### Settings
![Settings](previews/settings.jpg)

### Loading
![Loading](previews/loading.jpg)

## Remaining differences / untested areas
- Generated icon contours/shading, native stud/ray rendering and font metrics differ somewhat from the reference. The loading backdrop is a gradient rather than the reference subtle textured treatment.
- The video is edited/accelerated; easing and real-time durations are estimates. Wheel intermediate/settled frames and modal position samples were checked; every transient animation has not received frame-perfect matched-time verification.
- No trailer camera spins, seller logo/contact graphic, 3D showcase scene or world leaderboard included. Those are not invented HUD controls.
- Gift demo uses reference usernames with current Roblox thumbnails, which may differ from their appearance in the recording. Replace the demo list for your game.
- Sizing was subsequently simulated at nine phone/tablet/desktop dimensions: no root overflow or panel/HUD overlaps, but portrait phones are too small to read and landscape-phone text is compact. See SIZING.md. Touch/gamepad, low-end performance, long countdown expiry, cross-account asset permissions and live backend behavior remain untested.

## Artwork / permissions
Two fresh transparent icon atlases were generated with the built-in image tool using privately archived references for design guidance. Native geometric decorations are authored in Luau. Asset IDs and generation provenance are in `assets/manifest.json` and `assets/PROMPTS.md`. No purchased seller source files, seller screenshots, logo, contact artwork or sound recordings are bundled.

Roblox avatar thumbnails are dynamically requested from Roblox. Preview screenshots are not a license to redistribute seller artwork. Rights to public resale/redistribution of the reference-inspired kit have not been established; keep this a local/private draft pending rights review. Asset availability for other Roblox owners must be checked before deployment.
