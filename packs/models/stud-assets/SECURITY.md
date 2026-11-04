# Script and backdoor review

Reviewed 2026-11-04.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The source place contains a comment-only ScriptMateEnv helper; the exported asset folder contains zero scripts and excludes the helper and place services.

Source file: `Stud asset pack.rbxl`. Serialized instance count: 4094. Script containers: 1.

Source SHA-256: `ab4e34edfef27c314a72bf9d32558a8f7bbfcd40951bf19bb059e6a37684aa75`.

Download SHA-256: `6488c26e79520cce6b6972959771a68bea03bab0a3d783d870d64305df8e1f8b`.

The `.rbxl.lock` file is not a pack and is excluded. Unrelated templates in the source folder were outside this review.

Microsoft Defender custom scans were run against the packaged directory on 2026-11-04 with AntivirusEnabled=True and signatures updated that day. No threat detections referencing this batch were returned by Get-MpThreatDetection.
