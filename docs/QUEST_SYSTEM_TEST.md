# Sprint 14: Isolated QuestSystem Test

## Scope

QuestSystem `2.0.1.4_4` is pinned for evaluation only. The test does not
connect to Academy Hub, Coral Coast, Character Homes, production missions,
production adventures, or production `SaveManager` rewards.

Open and run:

`res://experiments/open_source_tests/QuestIntegrationTest.tscn`

## Test Quest

Sea Turtle Rescue

- Quest giver: Finn Tide
- Collect 5 Seashells
- Visit Discovery Beach
- Complete Wave Rider Raceway

Rewards route through `WorldState` only:

- Ocean Helper Badge
- Sea Turtle Sticker
- Finn Tide Friendship XP
- Coral Coast Passport Stamp
- Sea Turtle Rescue adventure completion

## Adapter Rule

`QuestSystem -> QuestAdapter -> WorldState`

QuestSystem owns quest lifecycle and objective serialization. It does not write
stickers, badges, friendship, passport stamps, or adventure completion.

## Automated Check

```sh
godot --headless --path . --script res://scripts/tests/sprint14_check.gd
```

The check validates quest loading, objective progress, save/load compatibility,
completion rewards through `WorldState`, and no writes to production rewards.

## Rollback

1. Disable `res://addons/quest_system/plugin.cfg`.
2. Remove the `QuestSystem` autoload.
3. Delete `res://addons/quest_system/`.
4. Delete `res://experiments/open_source_tests/quest_system/` and
   `QuestIntegrationTest.tscn`.
5. Delete `third_party/quest_system/`.
