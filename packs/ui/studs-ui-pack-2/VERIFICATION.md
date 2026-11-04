# Verification

2026-11-04 — Roblox Studio.

The final exported native model was deserialized and installed into the documented services in Studio, then tested in Play mode. Desktop mouse input opened Index, Pass, Rebirth, Shop, StockShop, Upgrades, Daily and StarterPack; each panel’s Visible state was checked. The initial Starter Pack Close button was clicked and its hidden state verified. Settings and lower/right scroll regions were previewed by explicitly setting client visibility/CanvasPosition; no user-facing Settings navigation is supplied. Screenshots cover the HUD, all nine panels, and scrolled content. The inspected client viewport was about 1701 × 787 logical pixels; captured output was 1920 × 888. Mobile, gamepad, respawn, real purchases and persistent game state were not tested.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The original open Stud asset pack place was returned to Edit mode with its asset folder, camera and HTTP setting restored. Source input files were not overwritten.
