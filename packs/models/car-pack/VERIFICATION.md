# Verification

Date: 2026-11-04. Source session: `CarPack.rbxl`, Edit mode.

## Security inspection

Inspected the connected DataModel for LuaSourceContainers (including disabled scripts and ModuleScripts), PackageLinks, RemoteEvents, RemoteFunctions, and UnreliableRemoteEvents. No instances of those classes were found. The six exported groups contain only Models, MeshParts, SurfaceAppearances, Attachments, and ParticleEmitters.

The imported export was audited again: **0 scripts, 0 remotes, 0 package links**. No embedded executable scripts or backdoor indicators were found. No source scripts were executed, no content needed removal, and HTTP requests were not enabled.

This is an inspection of the supplied place and exported collection, not a guarantee about installed Studio plugins, future modifications, or the future availability/content of externally hosted assets.

## Native export and import comparison

- Serialized only MainColors, GoldColors, DiamondColors, RubyColors, EmeraldColors, and CelestialColors using Roblox's SerializationService.
- Saved a 647,630-byte binary native model. SHA-256: `1FD3F9C2750BE4FB5B738B407E4592620DE2F5E1CE1D71E460C0B0AF07C53D7E`.
- Deserialized the same byte sequence in Studio: 6 collection roots and 2,091 descendants, including 150 car Models.
- Compared all 2,097 instances recursively: names, classes, child counts/order, and applicable CFrame, Size, Anchored, CanCollide, Material, Color, Transparency, CollisionGroup, MeshId, TextureID, and four appearance-map fields. **No differences found.**
- Verified 840 anchored, collidable MeshParts, 705 SurfaceAppearances, 124 Attachments, and 272 ParticleEmitters.
- ContentProvider preload completed with **2,224 successful callbacks and zero reported failures** in the current Studio session. This is a callback count, not a unique-asset count.
- The native model itself is authoritative editable source. No runtime code or reconstructed geometry was introduced.

## Visual verification

Captured the imported instances in the source Studio place with the originals temporarily detached and retained. Four 1920 × 888 screenshots cover all 150 variants. The three sections each cover nine designs and overlap by one, giving 25 unique designs in total. Inspected framing for clipping, readable shapes, and all six finishes.

The baseplate and lighting are preview context and are not in the export. Original groups, camera CFrame/Focus, 70-degree field of view, empty selection, and Edit mode were restored. The original place was not saved over.

## Remaining checks and limitations

- **Fresh-place import through Studio's native file dialog is not verified.** The Windows computer-use pipe was unavailable. The completed same-session deserialization and property comparison are not presented as that test.
- Physical collision behavior in Play mode and a drivable chassis are not tested. Only collision properties were checked; no driving system is included.
- External asset access was tested in this session only, not a different account or published experience.
- Embedded particle instances were preserved and visible effects appeared in screenshots; no dedicated motion demonstration or exhaustive particle timing test was made.
- The contributor directed publication under the existing project MIT license on 2026-11-04; see CREDITS.md for license scope and source attribution.
- No repository-wide automated test suite exists for this asset contribution.
