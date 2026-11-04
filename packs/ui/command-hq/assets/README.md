# Surface and icon assets

The Game, Audio, Graphics and Controls tab icons were generated with built-in imagegen from the supplied reference. Original RGBA files, UI-size crops, prompts and real uploaded IDs are included. See [asset-map.json](asset-map.json), [icon-prompts.json](icon-prompts.json) and [icons/](icons/). All four final IDs loaded in the imported Play test. Upload access in another experience is not assumed.

Two noisy generated gear attempts were rejected and archived privately. The 0.3.1 gear and document are generated shared images. Ticket, flag, crate, close, alert, party, check and other small symbols remain native geometry.

Glass surfaces, translucent gradients, reflections, corner cuts, highlight/shadow edges, gold ribbon, button gloss and control bevels are native editable instances authored by src/Polish.luau. No screenshot is used as a panel. The final panel paint uses the sampled opaque composited reference colors; the shadow image uses real alpha. the included PanelBlur template is cloned into the camera during Play, enabled while a panel is open, and disabled on close. No sounds are included.

## Shared symbol revision 0.3.1

Four additional generated transparent assets replace all eight document/plus/gear/wrench instances. Runtime copies use the -v031.png suffix; originals use -v031-original.png. Prompts and preprocessing are recorded in shared-icon-prompts.json. InstallIcons.luau applies SharedIcons.luau during authoring after ColorMatch; Play does not rebuild them.
