# Surface Inventory0.4.0 — stud relief and visible background motion

- Source version `0a98601068287c4e239c688bccf8b189eb40f4282a21f8333c3cae6b129b7bb9`.
- Studio-native SHA-256 `a69e24ec1bc48e5e27730b51ee33e479c2ee2a629ff3cdb838d1f506db10ea24`; 53136 bytes;12733 instances including2070 native FlatFace relief pieces.
- Final included Controller and Config independently decoded and matched to source; actual native UI reimported and Play-tested in Place1.

## Supplied bevel reference

The user's gray four-stud reference is archived privately as `revision-05/user-bevel-reference.png`. Color is deliberately not matched. Its relevant treatment is a flat square face, softly rounded bevel perimeter, strong opposing bright/dark edges, and reversed relief polarity. Native red studs now use a separate flat center and rounded outer bevel rather than a diagonal gradient across the whole square. Main motif12px, bevel2px, center8px; recessed face darker, highlights/shadows reversed. Smaller/fainter title and detail variants are retained.

Actual complete Studio renders and decorative close regions were reviewed. Matching exact source-pixel contrast is not claimed: the supplied reference is gray, enlarged, and differently sampled from these tiny red GUI motifs. No whole-interface image or uploaded stud texture replaces native editability.

## Motion diagnosis and verification

The old7px/sec loop did update its positions, but was too subtle and integer-offset stepped. Revised loop uses real elapsed time and fractional UDim scale translation at18px/sec down-left. The two-cell44px wrap preserves alternating raised/recessed polarity.

-150 actual RenderStepped samples span roughly9s, covering multiple wrap crossings. Unwrapped median movement is **17.985px/sec left, 17.985px/sec down**.
-16 original Studio screenshots span **12.76s**, fixed supplied camera/pointer, with visibly shifted rendered stud positions. These are sparse tool captures, **not** a60fps recording or a claim of runtime frame rate. Original bytes/times retained privately under `revision-05/captures/motion-*` and evidence.json.
-Final imported UI replay measured approximately(-4.783,+4.783) native pixels over a quarter-second wait; actual frame/layer positions moved fractionally. No integer-only offset approximation is used now.
-Visual review retained the opposite bevel styles through wrapping; no uncovered strip was seen. Exact original video speed/easing remains unmeasured;18px/sec is configurable, not certified original timing.

## Native export and regressions

Actual Studio SerializationService binary was decoded/deserialized; included sources and descendant count checked. Raw MCP parenting of serialized scripts remains capability-blocked, so native UI was inserted and the exact embedded sources restored through the supported editor. No capability escalation. A fresh-place one-step Insert from File is still uncertified.

All15 gallery states were refreshed on the imported UI: closed/open, four hover states, selection, opening/reveal, tilt directions, phone portrait/landscape/bottom-scroll and tablet. Current representative emulator probes have no essential projected bounds outside their viewport; images loaded and title fit. Grid/bar/title/input geometry is unchanged from0.3.1; earlier27-case spacing coverage is historical, **not falsely relabeled as a newly run27-device motion test**. Hover and open/reveal were replayed. Runtime console clean.

The20px desktop title-to-grid rest gap remains intact. Real touch, physical controller/TV/VR, all-state performance and every-device loop smoothness remain unverified. Other-owner backpack access remains unverified. AlwaysOnTop=false can be occluded by very close geometry. No production inventory/economy or soundtrack integration.

Historical spacing/opening/lifecycle evidence remains in `exports/VERIFICATION-v0.3.1.md` and versioned reports, with original hashes. Original video scaling still blocks numeric source-video fidelity. No invalid source comparison score substitutes for visual review.

User began with Play running; restored Play with inventory open, default simulator and LandscapeRight orientation, temporary preset and detached backups removed. UNLICENSED private draft; no commit/push/publish.
