# Cat Game — Claude Code Context

## What this is
A 2-player local co-op top-down game in Godot 4 (GDScript). Two black cats hunt flies across multiple worlds, each a parody of a famous game. Target platform is web (itch.io).

## Project structure
```
scenes/
  level_test.tscn   ← main playable level
  player.tscn       ← the cat (AnimatedSprite2D, CircleShape2D)
  fly.tscn          ← the enemy (Area2D, scales to 3x)
  projectile.tscn   ← snot blob shot by the cat
  win_screen.tscn   ← shown when all flies are dead

scripts/
  player.gd         ← movement, shooting, animation
  fly.gd            ← buzzing AI, flee from cats, freeze/die logic
  projectile.gd     ← moves in direction, despawns off screen
  level.gd          ← polls fly count, shows win screen
  win_screen.gd     ← emits restart_pressed signal

assets/
  zuko-animation.png   ← cat sprite sheet (32x32 frames, 4 cols x 4 rows)
  New Piskel.png       ← unused/scratch
```

## Key design decisions
- **Top-down view** — no gravity
- **Two players on one keyboard**: P1 = WASD + Space, P2 = Arrow keys + Enter
- **Input actions** defined in project.godot: p1_left, p1_right, p1_up, p1_down, p1_action (same for p2)
- **Player ID** is an @export var on player.gd — set to 1 or 2 per instance
- **Groups**: cats, flies, projectiles — used for collision detection

## Current gameplay loop
1. Cat shoots snot projectile with action key
2. Projectile hits fly → fly freezes (turns blue, wings stop)
3. Cat runs over frozen fly → fly dies
4. If cat is too slow (~3 seconds) → fly breaks free and buzzes off
5. Flies flee from cats within 150px radius
6. All flies dead → win screen appears
7. Space/Enter or clicking "Play Again" restarts the level

## Current milestone
Milestone 3 complete (shoot + freeze + eat mechanic works).
Next up: Milestone 4 — Cat 2 pounce mechanic, Milestone 5 — two players.

## Planned worlds
- Fly Hunt (current)
- Pokémon parody
- Super Mario parody  
- Super Smash TV parody

## Notes
- Fly is scaled 3x in the scene, so visual size ≠ script coordinates
- AnimatedSprite2D uses "default" animation — call anim.play("default") in _ready()
- Win screen is its own scene (win_screen.tscn) instanced into level_test.tscn
- No camera — level is fixed 1280x720, always fills screen
- Viewport stretch mode is canvas_items / expand (set in project.godot)
