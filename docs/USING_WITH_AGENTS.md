# Install with your agent

Use an agent connected to your intended Roblox Studio place. Repository access lets it read the kit; Studio access is needed to inspect Explorer, import or move the model, and check it in Play.

## One setup request

Replace `[kit name]` with the pack you want.

```text
Install [kit name] from Steal a Template in my open Studio place.
Read its catalog entry and setup notes. Check whether the kit is
already imported. If its ScreenGui is outside StarterGui, move it
into StarterGui. If it is already there, leave it in place.
If it is missing, import the pack's native model once. Preserve
unrelated UI and included scripts. Verify it opens in Play mode.
If you cannot access Studio or import the file, tell me what remains.
```

## What the agent should do

1. Read [AGENTS.md](../AGENTS.md), the selected entry in [catalog.json](../catalog.json), and the pack README.
2. Identify the intended open place and its current mode. Inspect the actual instances in Edit mode; a runtime copy in PlayerGui is not the installed source.
3. Check the catalog's root name and class against the imported kit. If a same-named object does not match the pack, report the conflict instead of replacing it.
4. If the kit is already under StarterGui, keep that copy. If it was imported elsewhere, move its ScreenGui into StarterGui with all descendants intact.
5. Import the pack's native model only if it is absent and the available Studio tools support that operation. Do not silently rebuild it from source as an installation fallback.
6. Check the installed copy in Play, then restore the previous mode. Report the installed path and any asset-loading or behavior issues.

Do not delete duplicates automatically; identify them and explain which copy is active. Preserve unrelated UI and any changes already made to the kit. Do not wire purchases, rewards, or persistence as part of installation.

## Manual fallback

Download the pack's RBXM, stop Play, and use **StarterGui → Insert from File**. If it lands in Workspace or another container, move its ScreenGui into StarterGui. If it is already there, no move is needed. Press Play.

An agent without Studio access can guide these steps, but should not claim the kit was installed or tested.

For source changes rather than installation, use [AGENTS.md](../AGENTS.md) and the selected pack's README. Keep the source, exported model, and affected screenshots synchronized.
