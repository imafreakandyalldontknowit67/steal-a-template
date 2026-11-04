# Command HQ 0.3.1 verification

Model SHA-256: 56194bf8b5046575d8ba7d390c11512dcccf7c0a8efd351b71c0c0cf16db6e01. Native model: 52,810 bytes; 2,138 descendants. Serialized and deserialized through Studio. Controller, Theme, Assets, Palette and SharedIcons source equality passed; screenshots use the imported model.

## Shared icon revision

The supplied current-implementation crop showed the rough cog and disconnected wrench placeholder. The original military UI references guide the intended simple white/gold silhouettes. Four icons were regenerated through built-in imagegen with true transparency: document, plus, eight-tooth cog and open-ended wrench.

All eight uses were replaced: HUD Updates document, HUD Settings gear, Update Log header document, Update Log three section symbols, Settings header gear and Missions first-card wrench. No old native frame remains at these names. Existing positions, bounding dimensions and IconScale values were preserved. SharedIcons is the authoritative asset mapping; InstallIcons is the editable authoring step.

## Three review passes

1. Inspected generated originals and a navy-backed montage. Checked clean silhouettes, holes/alpha, plus symmetry and wrench jaw. Cropped by alpha bounds and fit proportionally to a transparent 256px canvas; originals retained.
2. Applied to every matching authored instance and inspected Edit-mode Update Log/toolbar after loading. Confirmed readable white/gold tint and alignment. An immediate capture before image loading was rejected; the loaded capture is the comparison evidence.
3. Exported/imported native model, entered Play and checked all eight assets loaded at their actual use sites. MCP mouse activation of Updates opened the log and enabled its owned blur. Captured all 11 gallery states at four actual runtime viewport/profile cases; reviewed the montage and full-size affected views.

No layout, responsive controller, transition or behavior code changed. The 0.3.0 full 19-case geometry evidence remains under previews/devices/v030 and exports/color-device-measurements.json as earlier evidence. The four-case 0.3.1 icon regression is separate: reference 1618x970 (usable1618x912), small portrait 358x638 (usable358x580), short landscape638x358 (usable638x300), ultrawide2559x1079 (usable2559x1021). Raw probes and state paths: [icon-device-measurements.json](exports/icon-device-measurements.json).

## Gallery and source checks

The main README's 11 gallery images are current 0.3.1 imported-model captures. Device images are under previews/devices/v031. Native signature, source hashes, image decoding, dependency paths and README links were checked.

Generated artwork is not pixel-identical to the reference. Touch gestures, virtual keyboard, hardware, gamepad traversal and TV readability remain unverified. Demonstration purchases/rewards/settings have no production backend. Nine image assets require access in destination experiences. Draft status and reference/external rights limitations remain.

Studio began in Edit with all panels closed and default device. Testing temporarily entered Play; restore that original Edit/default/closed state after checks. Private references and review captures stay ignored.
