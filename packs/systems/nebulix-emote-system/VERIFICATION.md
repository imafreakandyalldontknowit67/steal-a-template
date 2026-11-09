# Verification

- Native file preserved byte-for-byte from the owner-supplied input.
- Local binary hierarchy/root counts matched Studio imports.
- Edit-mode GUI preview only. Wheel/list visibility was set on temporary clones; scripts were disabled. No animation/reward/purchase/save test. Missing Shared.Icon, SettingsFrame and game-specific handlers are documented.
- Integration template, not drop-in working gameplay. Shared.Icon and MainGUI.SettingsFrame are absent; Topbar also references an unassigned settingsIcon. Reward/purchase/slot-change dependencies and remote validation need review. Data-store saving and emote playback are unverified.
- External mesh/image/audio dependencies may require permission in the destination experience.
- No desktop/browser control used; Studio connector only.
- SHA-256: ba714391e93a2390c7dc2071d6d7af5fb55a4bfb36f3d25d3d6c3768e49d9327
