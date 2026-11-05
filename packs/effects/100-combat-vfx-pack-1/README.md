# Combat VFX Collection

**Native Roblox asset collection · v0.1.0 · visual preview release**

[Download native model](100%2B%20Combat%20VFX%20Pack%20%281%29.rbxm?raw=1) · [Full labeled gallery](GALLERY.md) · [Verification](VERIFICATION.md) · [Credits](CREDITS.md)

## Included and tested scope

96 particle-effect entries and 5 trails photographed separately. Carrier geometry was hidden for triggered-effect stills. Emission timing was staged and frozen for capture; trail lifetime was extended on preview clones only. No motion recording is supplied, and original timing/playback integration remains unverified.

![Representative capture](previews-v2/effect-001.jpg)

Browse **[every captured item and alternate angle](GALLERY.md)**. Captures are actual Studio MCP images, not generated mockups. Model previews use independent framing/normalization; they are not a common-scale comparison. Original native bytes are unchanged.

## Installation

1. In a disposable Roblox Studio place, import the native model into **Workspace** in Edit mode.
2. Inspect the named groups in Explorer and select the desired asset; do not flatten the original hierarchy.
3. Keep a reusable master under **ServerStorage** or **ReplicatedStorage** and clone the desired entries into Workspace for your game.
4. Test textures, scale, collisions and any effects in your own experience before integration.
5. Use the contained ParticleEmitters/Trails with your own playback controller. A still gallery is not a runnable timing demo; integration and motion verification remain your responsibility.

## Customize

Edit the original instances in Explorer: names, transforms, mesh/appearance properties and effect settings as appropriate. Keep an untouched master. Preserve supplied asset IDs and creator notices; access to externally hosted assets may differ in your experience. No mobile, console, collision or production-readiness claim is made.

## Inventory and source

[inventory.json](inventory.json) summarizes the serialized classes/roots; [compressed full hierarchy](inventory-full.json.gz) preserves every parsed node. [dependencies.json](dependencies.json) lists deduplicated external references and occurrence counts. The native model is authoritative; src/ exists only where serialized script sources were present.

## License

[MIT](LICENSE), subject to [credits and preserved third-party terms](CREDITS.md).
