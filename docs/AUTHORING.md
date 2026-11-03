# Authoring asset packs

## Pack layout

Keep each pack in `packs/<category>/<pack-id>/`, using a stable lowercase, hyphenated ID. Categories are `ui`, `models`, `effects`, `audio`, and `systems`.

- `README.md`: what's included, a complete preview gallery, downloads, installation, customization, dependencies, and compatibility.
- Asset files at the pack root: `.rbxm` or `.rbxmx` for Roblox instances, audio files for sound packs, or Luau modules for code-only systems. Name each download clearly.
- `src/`: editable scripts and design source where applicable. State which source is authoritative if there are multiple formats.
- `previews/`: labeled screenshots, recordings, and audio samples covering the full pack.
- `demo/`: an optional example place showing the assets in use.
- `CREDITS.md` and `LICENSE`: creator credits, a copy of the project MIT license for original contributions, and any third-party terms. See [license scope](LICENSING.md).
- `CHANGELOG.md`: changes by version.
- `pack.json`, if used: pack-specific metadata; file paths are relative to the pack folder.

List the pack in its category README with a direct link and a representative preview. Keep installation and download details on the pack page so a developer can use it without following a chain of guides.

## Show every included asset

Capture the actual delivered assets in Studio, with readable framing and lighting. A cover image alone is not a complete gallery.

| Asset type | Required previews |
| --- | --- |
| UI | Every distinct screen, panel, dialog, and meaningful state, including content hidden behind tabs or scrolling. Capture each frame that presents a separate view; decorative layout frames do not need individual screenshots. Show supported desktop and mobile layouts. |
| Models | Every model and meaningful variant, with enough angles to show its shape, materials, and scale. Label items in group shots and add individual views where details are unclear. |
| VFX | Every effect, with a clear still and a short recording showing its motion and timing. |
| Audio | A labeled playable sample for every sound or track; screenshots cannot demonstrate audio. |
| Luau systems | Screenshots or short recordings of every user-facing feature, plus a runnable example for systems without visible output. |

Match preview labels to the item list in the README. Embed screenshots directly on that page and link recordings or sound samples beside the relevant item. Refresh them whenever an asset changes.

## Build and verify

1. Create clearly named, editable assets and include the source needed to customize them.
2. Export the intended instances or files. Give each component an exact installation destination; do not assume every asset belongs in `StarterGui`.
3. Import the exported files into a fresh Studio place and follow your own installation instructions.
4. Check every included item. For UI, test navigation, scrolling, scaling, and respawn behavior. For models, check appearance and collision. For effects and audio, test playback. For systems, exercise the documented behavior.
5. Test the devices and inputs you claim to support, and record any untested cases or limitations.
6. Capture previews from the final imported version and keep exports, source, and documentation synchronized.

Describe required game integration plainly: for example, whether a shop displays sample products or connects to actual purchases. Include asset IDs and access requirements for linked images, meshes, animations, and audio.

Inspect included scripts and dependencies. Keep secrets, private game data, and unrelated files out of the pack. Preserve creator credits and include permission terms for externally sourced assets.
