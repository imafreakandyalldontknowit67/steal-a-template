# Free Admin Panel Demo Place

Native Roblox place containing the Lemonade UI Builder AdminPanel template, OnyxUI and Fusion packages, kick/ban controls, an announcement client, three remotes and a demo server handler. Includes 210 embedded scripts/modules.

**Preview release 0.1.0.** INSECURE DEMO: AdminHandler explicitly allows every player to kick, ban and announce, with no admin authorization, input type validation, text filtering or rate limiting. Bans are in-memory only. Do not publish this place as a live game or copy its server handler into production before securing it. No real kicks/bans or multiplayer moderation tests were performed. The announcement banner overlaps the panel and exposes a default Label at rest in this viewport.

## Download

[Download Free Admin Panel System.rbxl](Free%20Admin%20Panel%20System.rbxl?raw=1) — 170,080 bytes.

![Free Admin Panel Demo Place](previews/cover.jpg)

[Full gallery — 3 screenshots](GALLERY.md) | [Native inventory](INVENTORY.md) | [Compressed full hierarchy](HIERARCHY.json.gz) | [Verification](VERIFICATION.md)

**Native format: `.rbxl` place. Open it separately in Studio; this is not an `.rbxm` model.**

## Included assets

Native Roblox place containing the Lemonade UI Builder AdminPanel template, OnyxUI and Fusion packages, kick/ban controls, an announcement client, three remotes and a demo server handler. Includes 210 embedded scripts/modules.

210 embedded scripts are extracted verbatim in [src/manifest.json](src/manifest.json). The binary is authoritative; do not install duplicate extracted copies.

## Installation

Open the downloaded .rbxl with File > Open from File in Roblox Studio as a separate place. Do not insert it into StarterGui. To integrate selected components, copy ReplicatedStorage.Packages, ReplicatedStorage.UITemplates and ReplicatedStorage.AdminPanelRemote, then the two StarterPlayer.StarterPlayerScripts clients and ServerScriptService.AdminHandler only after securing the handler. Merge into existing services; do not replace your game wholesale.

## Customization and dependencies

Work on a copy in Studio. Preserve required internal hierarchy, attachments, bones and relative transforms. Inspect [asset references](ASSET-REFERENCES.json); their availability in this Studio session does not guarantee permission in your destination experience. Keep original creator notices.

## Verification and limitations

Opened the actual supplied place through Studio and inspected via MCP. Original client scripts generated the UI in Play. The real open button enabled the panel, mouse-wheel input scrolled to announcement controls, and the close button disabled it. A local-client GlobalAnnounce remote request with the fixed text Steal a Template preview reached the original announcement client; its label and tween position were read back. No live server or other player was targeted. Captures at 685 x 634. No mobile/gamepad test.

INSECURE DEMO: AdminHandler explicitly allows every player to kick, ban and announce, with no admin authorization, input type validation, text filtering or rate limiting. Bans are in-memory only. Do not publish this place as a live game or copy its server handler into production before securing it. No real kicks/bans or multiplayer moderation tests were performed. The announcement banner overlaps the panel and exposes a default Label at rest in this viewport.

SHA-256: `028254480df6e494524bbc0efc648a281bca1f93002fa52fab799f70d5d93102`

## Credits and license

[Credits](CREDITS.md) | [Scoped project MIT notice](LICENSE) | [Repository scope](../../../docs/LICENSING.md) | [Changelog](CHANGELOG.md)

[Back to category](../README.md)
