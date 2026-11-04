# Verification

Date: 2026-11-04. Source: `Dialogue System.rbxl`. Target: separate empty local `Place1` Studio session.

## Export and clean scene

- The core native model contains five service-named folders and 359 descendant instances, including four NPC Models, both GUIs, remotes, dialogue modules, `QuestConfig`, `QuestService`, `QuestServer`, fragments, and the Sword example.
- The core export has **no Crystal folder, Slime model, or Monsters folder**. `OptionalQuestTargets.rbxm` separately contains the five crystals and six slimes from the source place.
- The original place's crystals and slimes were moved to `ServerStorage.OptionalQuestTargets` in the live Edit session. The redundant `DialogueServer` was disabled and excluded from the export. Camera and talk-point markers were adjusted for clean dialogue framing.
- The native model is authoritative for instances; `src/` contains corresponding editable Luau. No code uses HTTP requests, `loadstring`, or numeric external `require` calls in the source audit.

## Fresh-place check

- Deserialized the exact exported binary into a separate empty `Place1` Edit session, moved each folder's children to its named service, then started Play.
- Confirmed four NPCs, no background crystals/slimes, and a functional Guide `TalkPrompt`. Its first line and five-choice menu appeared in the fresh-place client.
- In the source place, triggered Guide, Wizard, Hunter, and Duelist prompts through Play mode, inspected the visible text and camera state, and captured the gallery at 1920 × 888.
- Started the Fragments quest through `QuestService`; the HUD displayed `Fragment 0/5`. Added five fragments and turned in: the service returned success and awarded 10 Coins and 50 EXP. This was a direct service-path check, not a full manual collection loop.
- Stopped Play and removed the imported assets from `Place1`, leaving its original four Workspace children and empty script/GUI services.

## Limits

- The source local place could not be saved through MCP: `game:SavePlace()` reported `placeID is not valid`. The live Studio scene is clean; the GitHub native export is the durable clean artifact.
- Crystal and Slime quests require the optional targets or developer replacements. Their full objective loops, player defeat quest, and Sword combat were not playtested.
- Only desktop 1920 × 888 was captured. Mobile and gamepad behavior were not verified.
- Quest state is in memory and resets with the server. The pack is a demo, not a persistent production quest/economy system.
