# NovaKart Academy

A kid-friendly educational kart racing game for ages 4+, built with Godot by Parker Tech Labs.

## MVP

The first playable MVP lets a child:

1. Press the large green play button.
2. Pick a driver by color and meet their hero.
3. Enter the Academy Hub and drive a kart down Sunny Speedway.
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
- Viewable character profile pages with bios, catchphrases, abilities, and
  favorite activities
- Animated character introductions between Character Select and the Campus Hub
- One-time Academy Student Badge celebration saved to local progress
- Selected character is saved and displayed in the Sunny Speedway HUD
- Voice-ready character greeting and narration hooks
- Future character intro recordings are expected in `assets/audio/voice`
- Sticker rewards unlocked by finishing races and collecting Nova Stars
- Sticker Book available from the main menu
- Local save data for unlocked characters, stickers, and race progress

## Campus Experience

- Premium animated title screen inspired by the supplied campus concept
- Character Select and hero introduction entered from `Start Racing`
- Safe arrow-key exploration with no enemies or timers
- Large proximity prompts with Space interaction at every Hub building
- Race Center launches Sunny Speedway; future buildings show coming-soon prompts
- Learning Lab, Garage, and Event Plaza expansion-ready trigger zones
- Stylized buildings, fountain plaza, trees, gardens, banners, lamps, pathways,
  soft atmosphere, moving clouds, sparkles, and character idle animation
- Reusable `BuildingCard`, `CharacterPortrait`, `BigKidButton`, and
  `FloatingStar` presentation components
- Selected-character portraits integrated into the title flow, Hub welcome,
  race HUD, and victory celebration
- Large race HUD star count, character identity, and simple control hint
