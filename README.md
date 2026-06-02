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
### [v0.5.0] - *2026-06-1*
- **Added:** Factory `make_obj()` function to create object (mainly enemies) tables.
- **Added:** `animate()` function using new `ani`, `anispd`, and `frame` object animation variables.
- **Added:** Global `walk` table containing early enemy walking animation frames.

### [v0.4.0] - *2026-05-30*
- **Added:** Combat functions `init_combat()` and `update_combat()`.
- **Added:** SFX slot 0 for player melee attack sound effect.
- **Added:** `hitstop` cooldown timer for player attack input.
- **Added:** `doshake()` (camera shake) function and its companion variable `shake` for player attacks.
- **Added:** `plr.facing` variable to dictate player horizontal sprite flip, and to prepare for future combat logic.
- **Changed:** `--#region` section and subsequent code-block indentation for better readability in VS Code.

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
