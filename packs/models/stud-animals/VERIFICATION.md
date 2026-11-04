# Verification

2026-11-04 — Roblox Studio.

The delivered native file was imported through Studio serialization. Models were inspected in Edit mode and captured in group views. Inventory records the supplied item names. No model scripts were run; decorative models have no controllers to exercise. Anchoring and collision properties are preserved, but per-model gameplay collision was not tested.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The original open Stud asset pack place was returned to Edit mode with its asset folder, camera and HTTP setting restored. Source input files were not overwritten.

The six animal sheets used ContentProvider preload before capture. Callback totals by sheet were Success/Failure: 241/4, 236/0, 289/0, 278/2, 487/4, 85/1. Repeated references may be counted more than once. See the README for the five distinct IDs with authorization failures.
