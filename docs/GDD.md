# NovaKart Academy Game Design Document

## Vision

NovaKart Academy is a kid-friendly educational kart racing game for ages 4+.
Players race colorful tracks while practicing early learning skills through
simple, readable challenges.

## MVP Gameplay Loop

1. Press a large play symbol.
2. Choose one of four color-coded drivers.
3. Accelerate and steer a kart around Sunny Speedway.
4. Collect 10 bright Nova Stars placed along a wide track.
5. Cross a glowing finish line.
6. Replay or return home using symbols.

## Design Rules For Ages 4+

- Reading is optional during the core flow.
- Use large buttons, familiar symbols, bright colors, and immediate feedback.
- Use a simple four-arrow control scheme with a large, fun boost.
- Keep the track wide and prevent the kart from leaving it.
- Do not punish missed Nova Stars or slow driving.
- A race should take less than one minute.

## MVP Architecture

- `MainMenu.tscn`: Large play button.
- `CharacterSelect.tscn`: Four color-coded profiles and greeting hooks.
- `CharacterIntro.tscn`: Animated 2D hero introduction before entering campus.
- `StickerBook.tscn`: Collected sticker gallery and unlock hints.
- `RaceScene.tscn`: Track, Nova Stars, finish line, kart, and HUD.
- `PlayerKart.tscn`: Simple visible kart and follow camera.
- `race_manager.gd`: Tracks Nova Stars, rewards stickers, and completes the race.
- `kart_controller.gd`: Arrow-key driving and boost controls.
- `HUD.tscn`: Nova Star count and direction hint.
- `VictoryScreen.tscn`: Animated celebration, confetti, and next actions.
- `SaveManager`: Persists characters, stickers, and player progress.
- `AudioManager`: Provides voice-ready greeting and narration hooks.

## Next Learning Feature

Add optional shape gates that reward driving through the matching large shape.
Incorrect choices should gently redirect the player without ending the race.

## Character Identity Layer

Each driver has a name, large visual icon, special ability identity, color, and
catchphrase. Selecting a driver requests a greeting through `AudioManager`, so
recorded narration can be added later without changing the character UI.

The selected driver is saved immediately and restored the next time Character
Select opens. Sunny Speedway displays the selected driver's name in the HUD.

Finishing races unlocks stickers for the selected driver and race achievements.
The Sticker Book shows collected rewards and gentle visual hints for locked
stickers. Progress is saved locally after every completed race.

### Sticker Progression

The first Sticker Book collection includes Academy Student, First Race, First
Win, Star Collector, and one fan sticker for each hero. Stickers are grouped
into Characters, Racing, Academy, and Exploration categories. Common,
uncommon, rare, and epic rarity colors make rewards easy to distinguish.

New stickers use a reusable reward popup with a large preview, animation,
confetti, and a silent-safe sound hook. The Academy Student sticker unlocks
during the first character introduction; race stickers unlock on the victory
screen.

## Coral Coast

Coral Coast is the first expansion destination and is reached through the
Academy Coral Coast Gate. Its ocean-blue hub uses a lighthouse, palm trees,
coral decorations, sand, and water to immediately distinguish it from campus.

Finn Tide acts as the world guide and introduces a five-seashell discovery
mission. Discovery Beach provides safe exploration and short educational signs.
Wave Rider Raceway is a wide beginner track framed by coral arches, ocean
tunnels, collectible seashells, and a lighthouse finish.

Finn's first structured mission, **Lighthouse Hero**, asks players to collect
five seashells, visit Discovery Beach, and finish Wave Rider Raceway. A large
mission tracker shows progress without requiring menu navigation. Completing
all three goals awards the Lighthouse Hero badge, Coral Coast sticker, and
Coral Coast passport stamp. Mission progress and rewards are saved locally.

Character Select cards link to data-driven profile pages. Each profile shows a
large portrait, name, bio, catchphrase, ability, and favorite academy activity,
with previous/next browsing and a direct Choose action.

Selecting a driver opens a reusable character introduction. Large animated
portrait cards, themed particles, a short speech bubble, and a clear Start
Adventure action give each hero personality before final 3D models exist. The
first introduction awards a one-time Academy Student Badge saved locally.

## Premium Title Screen

The title screen presents NovaKart Academy as a magical commercial game world:
the academy campus sits behind a large logo, four animated character showcases
frame the scene, stars sparkle, clouds drift, and the primary actions use large
high-contrast buttons.

The four title showcases use cropped portraits from the supplied NovaKart
character lineup. Portraits preserve their aspect ratio and fall back to the
character icon only when an art asset cannot load.

`Start Racing` enters Character Select, followed by the selected hero's
introduction and the Campus Hub. Characters, Sticker Book, and Settings remain
available as direct title-screen shortcuts.

## Campus Hub

The Campus Hub is a safe 3D exploration space with no enemies and no timers.
Large labeled landmarks and reusable trigger zones connect activities:

- Race Center launches the selected hero into Sunny Speedway.
- Sticker Book Hall opens collected rewards.
- Learning Lab is prepared for educational activities.
- Garage is prepared for kart customization.
- Event Plaza is prepared for seasonal content.

Nearby buildings show large color-coded prompts. Arrow keys move through the
Hub and Space activates the nearby building, keeping navigation consistent with
the race controls without requiring small menus.

### Visual Polish Foundation

The Hub presentation uses reusable stylized academy buildings with colorful
roofs, domes, glowing windows, columns, banners, and clear signs. Landscaped
paths connect a central fountain plaza to trees, bushes, flowers, and street
lamps. Soft fog, drifting clouds, sunlight, floating stars, and subtle player
idle motion make the campus feel magical without changing gameplay.

Character identity remains visible across the complete flow through reusable
portrait panels on the title screen, Character Select, Hub welcome panel, race
HUD, and victory celebration. Reusable kid-button and floating-star components
keep touch targets and ambient effects visually consistent.
