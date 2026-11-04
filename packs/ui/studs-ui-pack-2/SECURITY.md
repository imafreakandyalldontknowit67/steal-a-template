# Script and backdoor review

Reviewed 2026-11-04.

The binary Roblox files were decompressed and their instance classes and every serialized Script, LocalScript, and ModuleScript Source property were inspected before Play testing. Reviewed for external/numeric require loaders, loadstring, HTTP execution or exfiltration, obfuscated payloads, suspicious remotes, and hidden script containers. No backdoor behavior was found in the inspected content. This is a scoped static backdoor review, not a guarantee against every possible threat or future change to external Roblox assets.

The three UI scripts were reviewed in full. The only require calls load the two included child modules. The export fixes startup registration of the initially visible Starter Pack popup so its Close button works immediately.

Source file: `Studs UI Pack 2 V1.4.rbxl`. Serialized instance count: 2396. Script containers: 3.

Source SHA-256: `0ae61b404a1821b2c4f691ef377253a37f600023365e4aebd4e1b0a1f244c36c`.

Download SHA-256: `0ab5895ab84de7beb533d7b7d33af432923a674ed0528adb8083152b03295a7c`.

The `.rbxl.lock` file is not a pack and is excluded. Unrelated templates in the source folder were outside this review.

Microsoft Defender custom scans were run against the packaged directory on 2026-11-04 with AntivirusEnabled=True and signatures updated that day. No threat detections referencing this batch were returned by Get-MpThreatDetection.
