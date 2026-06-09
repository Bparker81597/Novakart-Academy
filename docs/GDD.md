# NovaKart Academy Game Design Document

## Vision

NovaKart Academy is a kid-friendly educational kart racing game for ages 4+.
Players race colorful tracks while practicing early learning skills through
simple, readable challenges.

## MVP Gameplay Loop

1. Press a large play symbol.
2. Choose one of four color-coded drivers.
3. Steer an automatically moving kart.
4. Collect bright coins placed along a wide track.
5. Cross a glowing finish line.
6. Replay or return home using symbols.

## Design Rules For Ages 4+

- Reading is optional during the core flow.
- Use large buttons, familiar symbols, bright colors, and immediate feedback.
- Keep the kart moving so the player always makes progress.
- Keep the track wide and prevent the kart from leaving it.
- Do not punish missed coins or slow driving.
- A race should take less than one minute.

## MVP Architecture

- `MainMenu.tscn`: Large play button.
- `CharacterSelect.tscn`: Four color-coded driver buttons.
- `RaceScene.tscn`: Track, coins, finish line, kart, and HUD.
- `PlayerKart.tscn`: Simple visible kart and follow camera.
- `race_manager.gd`: Tracks coins and completes the race.
- `kart_controller.gd`: Automatic forward movement and simple steering.
- `HUD.tscn`: Coin count, direction hint, and finish controls.

## Next Learning Feature

Add optional shape gates that reward driving through the matching large shape.
Incorrect choices should gently redirect the player without ending the race.
