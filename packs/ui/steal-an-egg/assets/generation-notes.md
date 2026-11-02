# Artwork provenance

All PNGs are retained as local sources. Actual Roblox upload IDs are in asset-map.json. Generated artwork is a recreation, not extracted commercial artwork.

## Generation briefs

The following are concise generation briefs, not an exact transcript of tool prompts. All requested isolated artwork used transparent backgrounds, strong black outlines and readable game-icon silhouettes, with the supplied references guiding appearance.

| File | Brief |
| --- | --- |
| speed-shoe.png | Shiny cyan running sneaker, white laces and lightning detail |
| egg.png | Brown blocky/pixel egg with a pale lower rim |
| pig.png | Pink blocky pet pig with dark ear/head accessories |
| fox.png | Orange voxel-style fox pet with white muzzle and paws |
| dragon.png | Dark fiery dragon head, orange horns and purple details |
| trail.png | Silver block-like running figure with broad trailing ribbons |
| secret.png | Matching figure and ribbons in black/white diagonal stripes |
| galaxy.png | Matching figure and ribbons with purple galaxy glow |
| divine.png | Matching figure and ribbons with rainbow colors and sparkles |
| runner.png | Glossy gold running figure with cyan speed streaks |
| bag.png | Blue sack filled with cyan sneakers |
| chest.png | Open gold chest filled with cyan sneakers |
| cash.png | Bright green cash bundle with gold band |
| cashbag.png | Green cash sack filled with bundles |
| cashchest.png | Green/gold open chest filled with cash bundles |

Original generation outputs remain in the Codex generated_images directory. The copies here are the uploaded originals. Trail color variants are applied with ImageColor3; Eternal uses a magenta tint. This causes stylistic differences from the source.

## Deterministic shapes

make_stud.py creates the stud-pattern tile. make_geometry.py creates the Robux-shaped mark, cart, book, index page, paw, hourglass, sunburst rays and red arrow using Pillow. These are simple geometry, not generated concept art. Other frames, borders, gradients, clock/coin shapes and Index baton are native Roblox instances.

## Review

Every generated icon was visually inspected. Significant revisions included the fox result, dragon collection, three special trail variants and cash bag/chest. Final gallery review replaced an unsupported arrow glyph with arrow.png. No fabricated IDs or external source-code dependencies are used.

## HUD revision 0.1.1

make_hud_icons.py draws the replacement egg, paw, index page, top-bar gear and backpack as antialiased geometry. These five sources replace the HUD-only versions; pet artwork remains separate.

## Mecha egg redesign

Built-in image_gen generated mecha-egg.png on 2026-11-02. Uploaded as rbxassetid://130327488977309. User requested a complete redesign and removal of squiggly decoration. Final brief: isolated transparent armored egg, chunky silver/gunmetal plates, cyan hexagonal power core, limited violet accents, bold clean silhouette readable at 110px; no text, frame, lightning, scribbles, limbs or external shadow. Original generated PNG retained without image postprocessing. The native card uses a dark blue/violet gradient and cyan outline; nine Lightning frames and its sunburst were removed. This is a user-directed design departure from the original reference.
