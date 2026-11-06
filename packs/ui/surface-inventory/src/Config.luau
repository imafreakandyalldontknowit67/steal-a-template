return {
 StartOpen = false,
 ToggleKey = Enum.KeyCode.I,
 Distance = 1.5,
 MaxTiltDegrees = 6,
 TiltFrequency = 15,
 OpenFrequency = 24,
 OpenDamping = 0.28,
 SlotDelay = 0.18,
 SlotStagger = 0.031,
 SlotDuration = 0.18,
 HoverResponse = 16, -- smooth ~0.2s hover entry/return, interruptible
 BackpackArrivalSeconds = 0.65, -- subtle slow startup turn
 StudSpeed = 18, -- visible native pixels/sec left AND down; 44px seamless period
 ShowDemoMoney = true,
 -- Real upload of assets/backpack-v2.png; source and ID recorded in assets/manifest.json.
 -- Empty means fully editable native approximation, not a missing image.
 BackpackImage = "rbxassetid://86135425235678",
}
