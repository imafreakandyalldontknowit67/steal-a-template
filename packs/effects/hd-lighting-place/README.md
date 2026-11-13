# HD Lighting

Clean lighting package with 31 instances: a Lighting folder containing 28 lighting objects (two Atmosphere, two Sky, four Bloom, eight Blur, two ColorCorrection, four DepthOfField and six SunRays), plus a LightingSettings ModuleScript. The original pistol, seven weapon scripts, two misplaced sound effects and 134 unrelated nested avatar/geometry objects are excluded.

**Preview release 0.1.1.** Static combined-lighting preview only. Original duplicate skies/atmospheres, enabled/disabled effects and eight blur objects are retained. No device/performance certification, animation or audio testing. The unsafe unrelated pistol is NOT included in this model.

## Download

[Download HDLighting.rbxm](HDLighting.rbxm?raw=1) - 6,613 bytes, actual native Roblox model.

![HD Lighting](previews/cover.jpg)

[Full gallery - 3 screenshots](GALLERY.md) | [Inventory](INVENTORY.md) | [Compressed hierarchy](HIERARCHY.json.gz) | [Verification](VERIFICATION.md)

## Installation

Insert HDLighting.rbxm into ServerStorage with Play stopped. Move the CONTENTS of HDLighting.Lighting into game.Lighting, after reviewing existing effects to avoid unwanted stacking. Keep LightingSettings in ServerStorage; it returns the supplied Lighting property values. Apply the settings through the Command Bar snippet below, then remove the empty staging folder when finished. Do not put the Settings module inside Lighting or expect automatic installation.

## Apply saved Lighting properties

After inserting the package in ServerStorage, run this in the Studio Command Bar (Edit mode), after reviewing the values:

```luau
local settings = require(game.ServerStorage.HDLighting.LightingSettings)
for property, value in pairs(settings) do
    game.Lighting[property] = value
end
```

This changes the destination place Lighting properties; review conflicts before applying. It does not move the Lighting child objects for you.

## Included source and customization

1 embedded scripts/modules are extracted in [src/manifest.json](src/manifest.json). The model is authoritative; do not install duplicate extracted copies. Customize native instances in Studio and preserve internal names and references. Linked Roblox assets may need permission in your destination experience; see [asset references](ASSET-REFERENCES.json).

## Verification and limitations

Exported real binary .rbxm with Studio SerializationService, not a renamed place file. Deserialized the final export buffer back through Studio; root names, native instance counts and class counts matched the local file inventory. Temporary export objects were unparented for serialization; source place originals were not saved or overwritten. LightingSettings was added for explicit property transfer; it is configuration, not an auto-installer. Prior place previews show the same delivered geometry/lighting; no new model-specific full runtime test is claimed.

Static combined-lighting preview only. Original duplicate skies/atmospheres, enabled/disabled effects and eight blur objects are retained. No device/performance certification, animation or audio testing. The unsafe unrelated pistol is NOT included in this model.

SHA-256: `4f67a3fa39fbb9dd7dee59b8e0444efa664e5dc570979f408b15141e4647d275`

## Credits and license

Original attribution and notices remain applicable. [Credits](CREDITS.md) | [Scoped project MIT notice](LICENSE) | [Repository licensing](../../../docs/LICENSING.md) | [Changelog](CHANGELOG.md)

[Back to category](../README.md)
