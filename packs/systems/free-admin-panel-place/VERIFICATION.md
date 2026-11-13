# Verification

- Native file preserved byte-for-byte from the owner-supplied input.
- Local native hierarchy and embedded source inspected; actual file opened in Studio.
- Opened the actual supplied place through Studio and inspected via MCP. Original client scripts generated the UI in Play. The real open button enabled the panel, mouse-wheel input scrolled to announcement controls, and the close button disabled it. A local-client GlobalAnnounce remote request with the fixed text Steal a Template preview reached the original announcement client; its label and tween position were read back. No live server or other player was targeted. Captures at 685 x 634. No mobile/gamepad test.
- INSECURE DEMO: AdminHandler explicitly allows every player to kick, ban and announce, with no admin authorization, input type validation, text filtering or rate limiting. Bans are in-memory only. Do not publish this place as a live game or copy its server handler into production before securing it. No real kicks/bans or multiplayer moderation tests were performed. The announcement banner overlaps the panel and exposes a default Label at rest in this viewport.
- External mesh/image/audio dependencies may require permission in the destination experience.
- Inspection, Play checks and captures performed through the connected Studio MCP. Original file was not saved or overwritten.
- SHA-256: 028254480df6e494524bbc0efc648a281bca1f93002fa52fab799f70d5d93102
