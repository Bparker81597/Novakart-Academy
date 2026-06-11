# Open Source Migration Roadmap

This roadmap preserves the current playable prototype. No phase may modify
production scenes or `SaveManager` until its exit criteria pass.

## Phase A: Study Only

Actions:

- Pin candidate release tags or commit hashes.
- Review licenses and create future third-party notice entries.
- Document addon files, autoloads, signals, serialization, and export behavior.
- Compare candidate APIs with NovaKart's dialogue, mission, adventure, and kart
  interfaces.
- Run the current full regression suite and record protected-file checksums.

Exit criteria:

- One-page API mapping for Dialogic and QuestSystem.
- No addon files, plugins, or autoloads in the NovaKart project.
- All existing tests pass.

Rollback:

- Delete study notes or abandon the integration branch.

## Phase B: Isolated Dialogue Test

Actions:

- Branch from the latest known-good main branch.
- Import a pinned Dialogic release under `addons/dialogic/`.
- Enable only the Dialogic plugin/autoload.
- Use `DialogueTest.tscn` for a short Finn Tide greeting.
- Use experiment-owned dialogue resources and a temporary adapter.
- Verify large text, portrait display, Continue input, future voice hooks, web
  export, and silent missing-audio behavior.

Do not connect:

- Character Select
- Character Intro
- Adventure Hall
- Friendship rewards
- SaveManager

Exit criteria:

- Dialogue test works in desktop and web builds.
- Disabling the plugin restores a clean project.
- Existing full regression suite still passes.

Rollback:

- Disable plugin, remove `Dialogic` autoload, delete addon and experiment data.

## Phase C: Isolated Quest Test

Actions:

- Import only pinned `addons/quest_system/`.
- Enable only the QuestSystem plugin/autoload.
- Build a temporary quest in `QuestTest.tscn`.
- Implement `NovaQuestAdapter` inside the experiment folder.
- Compare QuestSystem status with NovaKart mission status in memory only.
- Test serialization into a separate experiment file, never `user://save.json`.

Do not connect:

- Academy Hub
- Coral Coast
- Adventure Hall
- Production rewards
- SaveManager

Exit criteria:

- Quest starts, updates, completes, serializes, and restores in isolation.
- Adapter can translate objectives without changing production data.
- Removing the plugin leaves the current mission system operational.

Rollback:

- Disable plugin, remove `QuestSystem` autoload, and delete experiment files.

## Phase D: Finn Tide — Sea Turtle Rescue

Purpose:

Prove dialogue and quest integration with a new test adventure that has no
production reward or save dependency.

Suggested test flow:

1. Finn introduces Sea Turtle Rescue through the dialogue adapter.
2. Start a QuestSystem quest with three child-friendly objectives.
3. Find three safe turtle markers.
4. Visit the test beach marker.
5. Return to Finn for completion dialogue.
6. Show a temporary experiment-only celebration.

Rules:

- Build entirely inside `res://experiments/open_source_tests/`.
- Use placeholder shapes and text.
- No timers, failure states, penalties, or production collectibles.
- Store progress in a separate experiment save file.

Exit criteria:

- A child can follow the flow without reading complex instructions.
- Dialogic and QuestSystem can be disabled independently.
- No production scene or save file changes.

Rollback:

- Delete Sea Turtle Rescue experiment resources and disable addons.

## Phase E: Academy Hub Connection

This phase requires explicit approval after Phases B–D pass.

Actions:

- Add one optional test doorway or developer-only launch button.
- Keep existing Lighthouse Hero and dialogue systems active.
- Run old and candidate implementations side by side for comparison.
- Define a versioned migration for any saved data before changing authority.

Required approval gates:

- Kid-friendly usability is equal or better.
- Desktop and web performance is acceptable.
- Save migration and rollback are tested.
- Full regression and manual Maize Test pass.
- Third-party notices and pinned versions are committed.

Rollback:

- Remove the optional entry point and adapter.
- Restore previous plugin/autoload state.
- Preserve current NovaKart missions, adventures, dialogue, and saves.

## Vehicle Evaluation Track

Vehicle experiments remain separate from Phases A–E.

- Use `VehicleTest.tscn` only.
- Compare current kart controller, Easy Vehicle Physics arcade demo, and
  sphere-car concepts with identical arrow/Space controls.
- Do not change project physics ticks.
- Measure ease of steering, recovery, stopping, and boost clarity with a young
  player.
- Adopt nothing unless it clearly improves kid-friendly handling and can be
  rolled back without changing tracks or race progression.
