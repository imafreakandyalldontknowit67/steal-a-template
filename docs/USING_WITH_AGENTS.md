# Install with your agent

Use an agent connected to your intended Roblox Studio place. Repository access lets it read the kit; Studio access is needed to inspect Explorer, import or move the model, and check it in Play.

## One setup request

Replace `[kit name or pack URL]` with the pack you want. The repository is currently private, so the agent needs authorized access to read it and download models.

```text
Install [kit name or pack URL] in my intended Roblox Studio place.
Repository: https://github.com/imafreakandyalldontknowit67/steal-a-template
Catalog: https://github.com/imafreakandyalldontknowit67/steal-a-template/blob/main/catalog.json
Use my authorized repository access to read AGENTS.md, the catalog,
and the selected pack's setup notes. Inspect the imported kit first.
Move its ScreenGui into StarterGui only if it is elsewhere; leave an
existing StarterGui copy in place. Import the native model once only
if absent. Do not create duplicates or overwrite my edits. Preserve
included scripts and unrelated UI. If Studio tools are available,
verify it in Play and restore the previous mode. Report what remains
if repository access, import, or verification is unavailable.
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
