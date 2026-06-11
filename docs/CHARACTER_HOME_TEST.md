# Character Home Framework Test

## Architecture Checks

- Open `res://scenes/homes/CharacterHome.tscn`.
- Confirm the room loads with Finn's Dock data by default.
- Change the scene's `home_data` resource to each file in `res://data/homes/`.
- Confirm the room title, colors, icon, portrait, greeting, decorations, rewards,
  and future collectible displays update without editing the scene.

## Kid-Friendly Flow

- Walk into the large greeting zone and confirm the character greeting appears.
- Confirm friendship rewards show a clear locked or unlocked marker.
- Confirm decorations at friendship levels 3 and 5 begin locked.
- Raise friendship and confirm the matching decorations become visible.
- Confirm the future collectible cases are clearly labeled as displays.
- Press the large Academy button and confirm it returns to the Academy Hub.

## Automated Check

Run:

```sh
godot --headless --path . --script res://scripts/tests/character_home_check.gd
```

The check validates all four home resources, reusable scene displays,
friendship decoration unlocks, and the greeting panel.
