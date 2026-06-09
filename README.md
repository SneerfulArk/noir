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
### [v0.9.1] - *2026-06-08*
#### Changed
- **Time-slow:** Tweaked game-time deceleration multiplier and snap threshold to make time-slow feel more cinematic.
- **Animation:** Edited preexisting enemy walking animation to look more like an aggressive sprint.
- **Sprites:** Slight reorganization of spritesheet, and code tweaked accordingly.

### [v0.9.0] - *2026-06-07*
#### Added
- New `time_slow` variable and controls for future debugging and testing.
- Reposition logic for raindrops falling below the screen, resulting in an infinite rain loop.
#### Changed
- `init_vfx()` and `update_vfx` to use a nested loop of rows and columns for the rain table.

### [v0.8.0] - *2026-06-05*
#### Added
- Early `rain` table, update, and draw logic under VFX section. Rain currently reacts to game-time.
- Extra time logic in `animate()` function to prepare for possible reverse-time features.

### [v0.7.0] - *2026-06-03*
#### Added
- Simple loop for drawing ground texture lines behind entities.
- New palette swaps in the `pal_global` table, and reworked spritesheet with new palette.
#### Changed
- Time-Slow/Halt logic now multiplies `gt` by 0.9655 every frame instead of incrementing by a fixed number.
#### Fixed
- Was unable to change enemies speed easily with `obj.spd` because of the direction logic constantly updating it. Solved by adding a `dx` (x-axis direction) variable to decide dirction, while `spd` is used purely for movement speed now.

### [v0.6.0] - *2026-06-03*
#### Added
- Clock variable `gt` (game-time) injected into `animate()` and `move()` math to control overall game speed.
- Early time-slow/halt mechanic when enemies get within a certain threshold around the players x-axis.
- Clock variable `time_elapsed` which records the total game-time ticks (separate from the `ticks` variable, which is not affected by game time).

### [v0.5.0] - *2026-06-01*
#### Added
- Factory `make_obj()` function to create object (mainly enemies) tables.
- `animate()` function using new `ani`, `anispd`, and `frame` object animation variables.
- Global `walk` table containing early enemy walking animation frames.

### [v0.4.0] - *2026-05-30*
#### Added
- Combat functions `init_combat()` and `update_combat()`.
- SFX slot 0 for player melee attack sound effect.
- `hitstop` cooldown timer for player attack input.
- `doshake()` (camera shake) function and its companion variable `shake` for player attacks.
- `plr.facing` variable to dictate player horizontal sprite flip, and to prepare for future combat logic.
#### Changed
- `--#region` section and subsequent code-block indentation for better readability in VS Code.

### [v0.3.0] - *2026-05-29*
#### Added
- Draw function `draw_obj()` using new object property `fx` (Horizontal Flip).
- Movement function `move_obj()` using new object property `spd`.
- Movement logic for player and enemy in their respective `update()` functions.
#### Changed
- Organized tables for better visibility.

### [v0.2.0] - *2026-05-26*
#### Added
- Core architectural functions `_init()`, `_update60()`, and `_draw()`.
- Clock functions recording ticks.
- Character tables for the player and enemies: `plr={}` and `en={}`
- Independent draw functions `draw_player()` and `draw_enemies()` using data directly from character tables.

### [v0.1.0] - *2026-05-26*
#### Added
- Initial repository architecture, and .p8 code structure/organizatiom.
- Basic global palette swap loops (`apply_global_pal()`).
- Early 16x24px idle player sprite.
