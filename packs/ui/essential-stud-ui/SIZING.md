# Sizing-only review

Tested the existing UI without modifying its source, model, artwork or animations.

## Method
Temporary native Studio container using the runtime formula `min(width/1920, height/1080)` and the existing editable Canvas. Each container had the requested logical viewport dimensions; large/tall previews were zoomed to fit the Studio screenshot. Measurements divide out that preview zoom. This is layout simulation, **not hardware/device emulation**, touch testing or a performance test. No desktop takeover.

All nine panel roots and four persistent HUD groups were measured at each size (81 panel states); checked screen containment, panel/HUD intersections and text-fit flags. Shop offscreen scroll content is intentionally clipped and excluded from viewport-overflow claims. Visual screenshot review covered portrait HUD/Daily, landscape Daily/Wheel, tablet Daily and desktop Shop. Text-fit alone does not establish legibility.

## Results

| Simulated viewport | HUD button width | Navigation label size | Containment / panel-HUD overlap | Sizing verdict |
|---|---:|---:|---|---|
| 360?800 | 24.4 px | 5.4 px | No detected issues | FAIL: severely undersized; mostly empty portrait screen |
| 390?844 | 26.4 px | 5.9 px | No detected issues | FAIL: severely undersized; mostly empty portrait screen |
| 800?360 | 43.3 px | 9.7 px | No detected issues | Fits; small text around 10 px needs enlargement |
| 844?390 | 46.9 px | 10.5 px | No detected issues | Fits; small text around 10 px needs enlargement |
| 768?1024 | 52.0 px | 11.6 px | No detected issues | Fits; compact portrait-tablet text (11.6 px) |
| 1024?768 | 69.3 px | 15.5 px | No detected issues | Fits; reasonable tablet-landscape sizing |
| 1280?720 | 86.7 px | 19.3 px | No detected issues | Readable desktop proportions |
| 1920?1080 | 130.0 px | 29.0 px | No detected issues | Readable desktop proportions |
| 2560?1440 | 173.3 px | 38.7 px | No detected issues | Readable desktop proportions |

Zero measured root overflows or panel/HUD intersections across the matrix. No TextFits warnings in inspected panel text. **Portrait phones do not pass readability**: the 390?844 Shop is only 195?146 px; navigation buttons are 26.4 px wide and their labels are 5.9 px. At 360?800 they shrink further to 24.4 px / 5.4 px. Settings shortcut is about 9?10 px on portrait phones. Landscape phone nav labels are 9.7?10.5 px; smaller wheel labels are smaller still.

Cause: a single desktop-wide 1920px design scale is applied uniformly, including in portrait. Fitting everything is not the same as appropriate sizing. A future correction should use separate HUD/modal scaling plus portrait rearrangement?not blindly enlarge the whole desktop layout. No correction made because this request was to test sizing.

## Evidence
Private local evidence: `.ui-reference/essential-stud-ui/evidence/sizing/measurements.json` and six labelled screenshots:

- `390x844-hud.jpg`
- `390x844-daily.jpg`
- `844x390-daily.jpg`
- `844x390-wheel.jpg`
- `768x1024-daily.jpg`
- `1920x1080-shop.jpg`

Temporary review ScreenGui removed. Original Enabled/Visible/scroll states preserved (tests used a clone). Original kit still has 11,385 descendants; other Studio untouched. Native export and sources unchanged. No commits or pushes.
