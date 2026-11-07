# Verification

- Inspected native binary instance hierarchy and embedded script source locally; matched imported roots and named entries with Studio. Roblox may add internal Status/TouchTransmitter instances on import; these do not change the delivered native binary.
- Captured isolated temporary clones in Studio Edit mode (1325 x 761), with individual normalization, anchoring, camera and neutral ground. Source instances/native bytes were not edited.
- Eight touch-part scripts and the provenance module were not executed. The Keyboard and Bubble generators original source was initialized on temporary Edit-mode clones only: 30 generated cells and eight sound-pool emitters each. No Play, touch response or sound playback was tested.
- Server scripts create touch-responsive parts and sound pools. No Play or audio playback certification. Keyboard and Bubble grids are generated only at runtime; static screenshots show their supplied edit-time instances/templates, not a tested generated result.
- Geometry captures do not prove motion, audio, physics, gameplay, mobile/gamepad support, production readiness or asset access in another experience.
- SHA-256: `cac555c65726ad40dcc66581962b67080d49757cfda179d2e0de0303b49edc73`.

Screenshots labeled initialized show generated clone geometry. Physical constraints are removed only on anchored preview clones; all delivered native instances and scripts remain unchanged.
