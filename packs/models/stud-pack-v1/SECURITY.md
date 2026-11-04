# Script and backdoor review

Reviewed 2026-11-04.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The supplied model contains zero Script, LocalScript, or ModuleScript instances.

Source file: `Stud pack V1.rbxm`. Serialized instance count: 320. Script containers: 0.

Source SHA-256: `844ad4da496dfea76c40e815d7c8dd379bdb242fc0f875e7911783928ba7f45f`.

Download SHA-256: `844ad4da496dfea76c40e815d7c8dd379bdb242fc0f875e7911783928ba7f45f`.

The `.rbxl.lock` file is not a pack and is excluded. Unrelated templates in the source folder were outside this review.

Microsoft Defender custom scans were run against the packaged directory on 2026-11-04 with AntivirusEnabled=True and signatures updated that day. No threat detections referencing this batch were returned by Get-MpThreatDetection.
