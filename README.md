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
### [v0.15.0] - *2026-06-19*
#### Added
- **Effect:** Palette swap flash effect added to takedown keyframes. Implemented similarly to previous takedown effects like screen-shake and muzzle-flash.
#### Changed
- **Palette:** Refactored `pal_global` into nested-tables and edited the `apply_global_pal()` function to support both the `main` palette, and the new `flash` palette.
- **Palette:** `main` palette optimized alongside new `flash` palette. Most notably the rain colour is darker now.

### [v0.14.0] - *2026-06-18*
#### Added
- **VFX:** `muzflash()` (muzzle flash) function dictated by keyframes from the `takedowns` table using the variables `muzzle` to calculate size & lifespan, and `muz_x`, `muz_y` `muz_offsetx`, and `muz_offsety` to calculate position.
- **Sound:** Gunshot sound effects also dictated by specific keyframes from the `takedowns` table.
- **Sound:** Looping ambient rain sound effect.
#### Changed
- **Colour:** `pal_global` now includes new colour swaps. A lighter yellow for the muzzle flash, and two reds for the blood.
- **Sprite:** Blood redone on dual-character takedown sprites.
- **Organization:** Keyframes table organized into rows for readability.

### [v0.13.1] - *2026-06-17*
#### Added
- **Clock:** `full_spd` dev variable plugged into clock logic for easier testing of time-slow mechanics.
#### Fixed
- **Draw:** Player sprite was being drawn with flipped 4x3 tile offset too early, causing a slight flicker upon entering combat from the flipped side (left). Fixed by changing the offset condition to be the `cframe` variable rather than the `"combat"` player state.

### [v0.13.0] - *2026-06-15*
#### Added
- **Combat:** `cframe` variable to track current frame in takedown sequences. Used in the new `takedown()` function.
- **Combat:** Early `takedown()` function utilizing the `leg_shot` sequence within the `takedowns` table. Draws specified sprites and triggers effects like screen-shake upon the specified combat-frame.
- **Enemy:** New `"dead"` enemy state and logic to stop movement and drawing of enemy once combat starts. The enemy is drawn as part of the players 4x3-tile dual-character sprite during combat.
- **Draw:** New offset logic in `draw_obj()` function to support flipped 4x3-tile combat sprites.
#### Changed
- **Naming:** Renamed `takedown_anims` table to `takedowns` since the table contains more data than just the animation sprites.
- **Sprites:** Edited combat animation sprites limb positioning and added blood.
#### Removed
- **Combat:** Removed `hit_cool` (hit-cooldown), which wont be used in new combat system.

### [v0.12.0] - *2026-06-13*
#### Added
- **Animation:** Early architectural setup for the combat animations via the `takedown_anims` table, located near the top of the `init_combat` function. Opted for a table oriented combat state machine for scalability over messy if/then conditions.
- **Animation:** 2-frame enemy punch animation to transition between walk and dual-character combat animations, and `punch_dist` variable for easier tweaking of said animation.
- **Animation:** 3-frame dual-character combat/takedown animation added to spritesheet.
- **State:** `state` variable added to player and enemy tables.
#### Changed
- **Effect:** `hitstop` variable renamed to `hit_cool`, because `hitstop` will be used for a freeze-frame effect going ahead rather than a cooldown-timer.

### [v0.11.0] - *2026-06-12*
#### Added
- **State:** New `game` variable controlling game states like "menu" and "play".
- **State:** Unused testing section replaced with state section to organize game state functions.
- **Clock:** New `return_spd` variable and logic to smoothly transition back to full game speed.
- **Debug:** `draw()` function debug overlay now shows the `gt` variable.

### [v0.10.0] - *2026-06-10*
#### Added
- **Distance:** Simplified all player-enemy distance checks with a new `distance` variable calculated with the `abs()` function using the player and enemies new `cent` (center) variable.
- **Clock:** New `slow_dist`, `stop_dist`, and `slow_spd` variables for simpler time-slow/time-stop tweaking.
- **Sprites:** Drew the first dual-character 4x6-tile takedown frame.
#### Changed
- **Sprites:** Flipped all standalone sprites to face to the right and modified code accordingly.
- **Debug:** Updated debug overlay with labels for readability.
#### Fixed
- **Draw:** Player and enemy sprites used to be off by one pixel when flipped. Fixed by adding a local offset variable to the `draw_obj()` function, which decides the offset based on the objects `facing` variable.

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
- Was unable to change enemies speed easily with `obj.spd` because of the direction logic constantly updating it. Solved by adding a `dx` (x-axis direction) variable to decide direction, while `spd` is used purely for movement speed now.

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
