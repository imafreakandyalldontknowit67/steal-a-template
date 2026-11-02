# Free Roblox Assets & Asset Packs for Developers

A growing library of original Roblox asset packs for developers building games in Roblox Studio. The collection starts with reusable UI kits and is structured to expand into 3D models, visual effects, audio, and Luau systems.

The goal is simple: find a pack, preview it, download it for free, and follow clear setup instructions to use it in your own game.

**Status:** private asset repository. Studs UI includes a native model download and screenshot gallery for repository collaborators; public releases are not enabled yet.

## Catalog

| Category | Packs | Status |
| --- | --- | --- |
| [UI kits and interfaces](packs/ui/) | [Studs UI: model + screenshots](packs/ui/studs-ui/) | Private draft; native-model import/render checked |
| [3D models and props](packs/models/) | None yet | Planned |
| [Visual effects](packs/effects/) | None yet | Planned |
| [Audio and sound effects](packs/audio/) | None yet | Planned |
| [Luau scripts and systems](packs/systems/) | None yet | Planned |

## For developers

Each released pack will include a ready-to-insert `.rbxm`, installation instructions, previews, dependency information, and a license. Some packs will also include a `.rbxl` demo place.

Download one pack rather than cloning the whole collection. Public distribution is not enabled while this repository is private.

## Frequently asked questions

### Are these Roblox assets free?

Free public downloads are the intended release model. Studs UI is currently a private, unlicensed draft with an editable model available to repository collaborators. Each released pack will state its own license and permitted uses.

### How do I install a Roblox UI pack?

Insert the pack's `.rbxm` model into your existing Roblox Studio place, then move its ScreenGui into `StarterGui`. Follow the pack README for exact instance names, additional services, dependencies, and customization steps.

### Should I download an RBXM or RBXL file?

Use an `.rbxm` model to add a reusable asset to an existing game. An `.rbxl` is a full place file, useful for opening a separate demo rather than installing only the asset.

### Can I use assets in a monetized Roblox game?

Check the license included with the specific pack. Commercial-use and redistribution terms have not been selected yet; free download does not automatically grant every usage right.

### Do I need Rojo or a build tool?

The workflow is Studio-first. Studs UI includes a ready-to-insert native model, so developers do not need a source build tool to customize it.

## Structure

```text
packs/
  ui/                      # Finished and in-progress UI packs
  models/                  # Future 3D asset packs
  effects/                 # Future visual effects
  audio/                   # Future original audio packs
  systems/                 # Future scripted systems
_templates/
  ui-pack/                 # Copy this to packs/ui/<pack-id>
docs/
  AUTHORING.md             # How to add a pack
  DISTRIBUTION.md           # Downloads and release checklist
  LICENSING.md              # Licensing decision before public release
```

## Create the first UI pack

1. Copy `_templates/ui-pack` to `packs/ui/<pack-id>` (for example `inventory-ui`).
2. Update `pack.json` and the pack README.
3. Build the UI in Studio. Export the insertable UI to `exports/<pack-id>.rbxm`.
4. Optionally save a demonstration place in `demo/<pack-id>-demo.rbxl`.
5. Add previews, source files, installation steps, and dependency/credit details.
6. Choose a license and complete the [release checklist](docs/DISTRIBUTION.md).

No build tooling, Rojo, or package manager is required. Those can be added later if useful.

## License

Licensing has not been selected yet. Free downloads are the intended direction, but permission to reuse or redistribute must be stated explicitly before release. See [licensing](docs/LICENSING.md).
