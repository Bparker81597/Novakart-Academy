# NovaKart Academy

A kid-friendly educational kart racing game for ages 4+, built with Godot by Parker Tech Labs.

## MVP

The first playable MVP lets a child:

1. Press the large green play button.
2. Pick a driver by color.
3. Drive a kart down Sunny Speedway.
4. Collect 10 bright Nova Stars.
5. Cross the glowing finish line.
6. Replay or return home using symbol buttons.

## Controls

- `Up Arrow`: Accelerate
- `Down Arrow`: Brake and reverse
- `Left Arrow` / `Right Arrow`: Steer
- `Space`: Boost

## Tech Stack

- **Game Engine:** Godot 4.x
- **Language:** GDScript first
- **Version Control:** GitHub
- **Art Tools:** Meshy, Blender, Figma/Stitch
- **Future Backend:** Firebase
- **Target Build First:** Desktop/Web demo

## Getting Started

1. Install Godot 4.x.
2. Import `project.godot` from this repository.
3. Run the project to open the main menu.

The project structure separates scenes, scripts, game data, documentation, and
art assets to support incremental development.

## Character Identity Layer

- Four large portrait cards with names, abilities, icons, and catchphrases
- Selected character is saved and displayed in the Sunny Speedway HUD
- Voice-ready character greeting and narration hooks
- Sticker rewards unlocked by finishing races and collecting Nova Stars
- Sticker Book available from the main menu
- Local save data for unlocked characters, stickers, and race progress
