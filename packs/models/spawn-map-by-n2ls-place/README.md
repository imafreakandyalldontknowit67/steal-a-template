# Spawn Map by N2ls

Native scene package with 6,292 instances: Workspace geometry/UI/proximity prompts and all 13 original Lighting children, grouped into Workspace and Lighting folders, plus one new LightingSettings configuration ModuleScript. Seven fenced plots and grouped perimeter prop regions are preserved. Place services, Camera, Terrain and Studio metadata are not model contents. No authored terrain content was present to export.

**Preview release 0.1.1.** No plot ownership, collecting, saving, economy or gameplay handlers are included. The only script in this export is the new LightingSettings configuration ModuleScript. No authored SpawnLocation. Screenshots show grouped scene regions, not exhaustive isolated inspection of every copy. No full traversal/collision, device or performance certification.

## Download

[Download SpawnMapByN2ls.rbxm](SpawnMapByN2ls.rbxm?raw=1) - 195,823 bytes, actual native Roblox model.

![Spawn Map by N2ls](previews/cover.jpg)

[Full gallery - 7 screenshots](GALLERY.md) | [Inventory](INVENTORY.md) | [Compressed hierarchy](HIERARCHY.json.gz) | [Verification](VERIFICATION.md)

## Installation

Insert SpawnMapByN2ls.rbxm into ServerStorage while Play is stopped. Move the CONTENTS of its Workspace folder into game.Workspace, preserving model hierarchies and transforms. Optionally merge the CONTENTS of Lighting into game.Lighting after reviewing existing effects. Keep LightingSettings in ServerStorage and apply the values with the snippet below if you want the original scene lighting. Add your own SpawnLocation and gameplay systems. Delete only the now-empty staging folders after checking installation.

## Apply saved Lighting properties

After inserting the package in ServerStorage, run this in the Studio Command Bar (Edit mode), after reviewing the values:

```luau
local settings = require(game.ServerStorage.SpawnMapByN2ls.LightingSettings)
for property, value in pairs(settings) do
    game.Lighting[property] = value
end
```

This changes the destination place Lighting properties; review conflicts before applying. It does not move the Lighting child objects for you.

## Included source and customization

1 embedded scripts/modules are extracted in [src/manifest.json](src/manifest.json). The model is authoritative; do not install duplicate extracted copies. Customize native instances in Studio and preserve internal names and references. Linked Roblox assets may need permission in your destination experience; see [asset references](ASSET-REFERENCES.json).

## Verification and limitations

Exported real binary .rbxm with Studio SerializationService, not a renamed place file. Deserialized the final export buffer back through Studio; root names, native instance counts and class counts matched the local file inventory. Temporary export objects were unparented for serialization; source place originals were not saved or overwritten. LightingSettings was added for explicit property transfer; it is configuration, not an auto-installer. Prior place previews show the same delivered geometry/lighting; no new model-specific full runtime test is claimed.

No plot ownership, collecting, saving, economy or gameplay handlers are included. The only script in this export is the new LightingSettings configuration ModuleScript. No authored SpawnLocation. Screenshots show grouped scene regions, not exhaustive isolated inspection of every copy. No full traversal/collision, device or performance certification.

SHA-256: `db809cd40eedf08f5d96d6fffaf5746ee492e5b4f579faaec01a5a1887d5496e`

## Credits and license

Original attribution and notices remain applicable. [Credits](CREDITS.md) | [Scoped project MIT notice](LICENSE) | [Repository licensing](../../../docs/LICENSING.md) | [Changelog](CHANGELOG.md)

[Back to category](../README.md)
