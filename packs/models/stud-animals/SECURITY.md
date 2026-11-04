# Script and backdoor review

Reviewed 2026-11-04.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The supplied model contains zero Script, LocalScript, or ModuleScript instances.

Source file: `Stud Animals Pack 100+ - TU VIP.rbxm`. Serialized instance count: 24148. Script containers: 0.

Source SHA-256: `64b0563279efd123881f55a9198f146de66f45f58d5a0b5e38a4b04b7c758eb0`.

Download SHA-256: `64b0563279efd123881f55a9198f146de66f45f58d5a0b5e38a4b04b7c758eb0`.

The `.rbxl.lock` file is not a pack and is excluded. Unrelated templates in the source folder were outside this review.

Microsoft Defender custom scans were run against the packaged directory on 2026-11-04 with AntivirusEnabled=True and signatures updated that day. No threat detections referencing this batch were returned by Get-MpThreatDetection.
