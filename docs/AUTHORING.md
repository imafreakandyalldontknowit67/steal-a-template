# Authoring packs

## Keep each pack self-contained

Use a stable lowercase kebab-case ID, such as `inventory-ui`. Copy `_templates/ui-pack` into `packs/ui/<pack-id>`. Do not ship the template as a finished pack.

- `pack.json`: identity, version, status, license, file paths, and dependencies. This is repository metadata, not a Roblox package manifest.
- `exports/`: ready-to-insert `.rbxm` downloads (or `.rbxmx` if desired).
- `demo/`: optional `.rbxl` / `.rbxlx` example place.
- `src/`: editable Luau scripts, optional XML model source, and design source you own. Do not maintain duplicate sources without documenting which is authoritative.
- `previews/`: screenshots and a short GIF/video showing interactions.
- `README.md`: installation, customization, behavior, and compatibility.
- `CHANGELOG.md`: changes by version.
- `CREDITS.md`: attribution and external asset permissions.
- `LICENSE`: add the actual selected license before publishing.

## Studio-first UI workflow

1. Develop a `ScreenGui` with clearly named descendants in Studio.
2. Keep visual-only packs separate from gameplay logic. Document whether buttons are decorative or connected to actual systems.
3. Export the intended instances as a model file using Studio's save/export-to-file option. A folder can bundle multiple components, but consumers must move each component to its documented service.
4. Test importing into a fresh place. Move the ScreenGui into `StarterGui`; put any other instances in the services documented by the pack.
5. Run Play mode and verify open/close actions, scrolling, scaling, respawn behavior, and input support.
6. Test desktop and mobile layouts; document gamepad support rather than assuming it.
7. If a demo place helps explain the pack, save it separately. Never make a full place the only download for a reusable UI.

## External assets and scripts

List every image, font, audio, animation, or other external asset ID and its ownership/permission requirements. A model export does not automatically make linked cloud assets usable by everyone.

Do not include secrets, unpublished game data, unlicensed third-party art, hidden telemetry, remote-code loaders, or undocumented dependencies. Inspect every included script before release.

## Format reference

- `.rbxm`: binary model; recommended convenient UI download.
- `.rbxmx`: XML model; optional text-oriented source/export.
- `.rbxl`: binary place; useful for an optional demo.
- `.rbxlx`: XML place; optional text-oriented demo source.

Roblox references: [place files](https://create.roblox.com/docs/projects/place-files), [sharing exported models](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations).
