# "noir"

## Overview
Side-View John Wick-Inspired PICO-8 prototype.
The player will press a single button to do gun-fu counters on attacking enemies.
It will be a cinematic power-trip in which the player character cannot be hurt. There is no fail-state.

## Style
- **Attire:** Mid 20th-century inspiration for clothing and aesthetics.
- **Combat:** Snappy, exaggerated impact frames. John Wick/Aiden Pearce gun-fu fighting style.
- **Palette:** Lots of shades and low saturation colors. Blood will be colored with high saturation for contrast.

## Character
- **Protagonist:** Wears a dark trenchcoat to create a sharp silhouette and contrast him cleanly against basic enemy sprites.
- **Weapon:** Semi-Automatic sidearm for close-range gun-fu takedowns.

## CHANGELOG
### [v0.3.0] - *2026-05-29*
- **Added:** Draw function `draw_obj()` using new object property `fx` (Horizontal Flip).
- **Added:** Movement function `move_obj()` using new object property `spd`.
- **Added:** Movement logic for player and enemy in their respective `update()` functions.
- **Changed:** Organized tables for better visibility.

### [v0.2.0] - *2026-05-26*
- **Added:** Core architectural functions `_init()`, `_update60()`, and `_draw()`.
- **Added:** Clock functions recording ticks.
- **Added:** Character tables for the player and enemies: `plr={}` and `en={}`
- **Added:** Independent draw functions `draw_player()` and `draw_enemies()` using data directly from character tables.

### [v0.1.0] - *2026-05-26*
- **Added:** Initial repository architecture, and .p8 code structure/organizatiom.
- **Added:** Basic global palette swap loops (`apply_global_pal()`).
- **Added:** Early 16x24px idle player sprite.
