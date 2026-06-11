# Open Source Integration Plan

Prepared on June 11, 2026 for branch `integration/open-source-prep`.

## Guardrails

- Do not import addons into `main` until an isolated experiment passes.
- Do not replace NovaKart's current dialogue, mission, kart, or save systems.
- Keep experiments under `res://experiments/open_source_tests/`.
- Pin an exact upstream release or commit before importing.
- Preserve every upstream license notice in a future `THIRD_PARTY_NOTICES.md`.
- Before each phase, tag the last known-good build and record protected-file checksums.

Protected surfaces:

- `project.godot` autoloads and input map
- `scenes/main/MainMenu.tscn`
- `scenes/main/CharacterSelect.tscn`
- `scenes/hub/HubWorld.tscn`
- `scenes/race/RaceScene.tscn`
- `scenes/worlds/`
- `scripts/global/save_manager.gd`

## Decision Matrix

| Repository | License | Godot Compatibility | Potential Use | Risk | Difficulty | Recommendation |
|---|---|---|---|---|---|---|
| [Dialogic](https://github.com/dialogic-godot/dialogic) | MIT; bundled Roboto font is Apache 2.0 | Dialogic 2 requires Godot 4.3+; compatible with NovaKart's Godot 4.6 project | Character conversations, story scenes, intros, friendship moments, future voice events | Medium | Medium | **Use in isolated test first** |
| [QuestSystem](https://github.com/shomykohai/quest-system) | MIT | Current v2 line requires Godot 4.4+; v1.x supports Godot 4.0–4.3 | Resource-based quests, pools, objective lifecycle, serialization reference | High | High | **Study, then test behind an adapter** |
| [QuestSystem Example](https://github.com/shomykohai/quest-system-example) | MIT | Example targets Godot 4.3 and an older QuestSystem/Dialogue Manager pairing | Basic reference for dialogue-driven quest calls and quest UI | Medium | Low to study | **Study only** |
| [Advanced QuestSystem Example](https://github.com/shomykohai/advanced-quest-system-example) | MIT, with separately attributed third-party assets/code | Example targets Godot 4.4; integrates QuestSystem, Dialogue Manager, and Pandora | Composition-based quest steps and advanced integration patterns | High | High | **Study architecture only** |
| [Godot Easy Vehicle Physics](https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics) | MIT | README states Godot 4.2+; inspected project targets Godot 4.3 | Steering assists, traction, stability, arcade vehicle tuning ideas | High | High | **Evaluate only in VehicleTest** |
| [Godot Recipes 3D Sphere Car](https://github.com/godotrecipes/3d_car_sphere) | MIT | Current project targets Godot 4.4 | Simple sphere-based arcade handling and follow-camera ideas | Medium | Medium | **Study only** |
| [GDQuest Demos](https://github.com/gdquest-demos) | Per-repository; often MIT for code, but assets may use other licenses such as CC-BY-NC-SA | Varies by repository and release; select Godot 4.x demos only | UI composition, custom Resources, save architecture, progression patterns | Medium | Low to study | **Study selected code only; verify each repo license** |

## Repository Notes

### Dialogic

Potential future import:

- Copy `addons/dialogic/` from a pinned release.
- Enable `res://addons/dialogic/plugin.cfg`.
- Plugin adds the `Dialogic` autoload using its game handler.
- Create NovaKart-only timelines, characters, styles, and layouts under an
  experiment-owned folder.

Affected only during experiment:

- `project.godot` editor plugin and `Dialogic` autoload entries
- `res://experiments/open_source_tests/DialogueTest.tscn`
- New experiment timelines and Dialogic character resources

Risks:

- Dialogic has its own save-state model. It must not write NovaKart progression
  directly.
- Plugin updates may change private APIs.
- Default layouts are not automatically suitable for large child-friendly UI.

Adapter boundary:

- A future `NovaDialogueAdapter` should expose `start_dialogue(id)` and emit
  dialogue-finished events.
- Existing character IDs remain the source of truth.
- Voice hooks route through `AudioManager`.

Rollback:

1. Disable the Dialogic editor plugin.
2. Remove the `Dialogic` autoload entry.
3. Delete `addons/dialogic/` and experiment-only Dialogic resources.
4. Restore the experiment scene; no production scenes should require Dialogic.

### QuestSystem

Potential future import:

- Copy only `addons/quest_system/` from a pinned release.
- Do not copy upstream `addons/gdUnit4/` into the game unless separately chosen.
- Enable `res://addons/quest_system/plugin.cfg`.
- Plugin adds the `QuestSystem` autoload using
  `addons/quest_system/quest_manager.gd` by default.
- Create experiment-only `QuestResource` files for Sea Turtle Rescue.

Affected only during experiment:

- `project.godot` editor plugin and `QuestSystem` autoload entries
- `res://experiments/open_source_tests/QuestTest.tscn`
- New experiment quest resources and an adapter

Risks:

- NovaKart already has saved missions and adventures. Direct replacement would
  create two competing sources of truth.
- QuestSystem serialization must not be merged into `save.json` until migration
  and rollback tests exist.
- The current v2 API targets Godot 4.4+ and differs from the older example.

Adapter boundary:

- A future `NovaQuestAdapter` maps QuestSystem events to NovaKart objective IDs.
- `SaveManager` remains authoritative until a migration is explicitly approved.
- The adapter must support dual-read comparison without dual-writing rewards.

Rollback:

1. Disable the QuestSystem editor plugin.
2. Remove the `QuestSystem` autoload entry.
3. Delete `addons/quest_system/` and experiment-only quest resources.
4. Remove the adapter; existing Lighthouse Hero progress remains untouched.

### QuestSystem Example

Useful files to study:

- `quests/` scripts and `.tres` quest resources
- `dialogue/main.dialogue`
- `shortcuts.gd`
- `gui/GUI.gd`

It uses `DialogueManager` and `QuestSystem` autoloads. Do not copy the project
wholesale or its example characters/assets. Rollback is simply deleting local
notes or experiment copies because this repository should not be imported.

### Advanced QuestSystem Example

Useful files to study:

- `quest/` composition-based quest steps
- `helpers/pandora_quest_system.gd`
- `ui.gd`
- dialogue-to-quest event flow

It requires `DialogueManager`, `Pandora`, and a custom `QuestSystem` autoload,
plus project-specific data and inventory code. Importing this stack would add
unnecessary complexity. Study patterns only; do not copy its addons or assets.

### Godot Easy Vehicle Physics

Potential experiment-only import:

- `addons/gevp/scripts/`
- `addons/gevp/scenes/vehicle_controller.tscn`
- `addons/gevp/scenes/demo_arcade.tscn`
- Required addon sounds/materials for the isolated demo only

No autoload is required. The system recommends a physics tick rate of at least
120, which is a project-wide behavior change and must not be applied during
evaluation. Test arrow-key steering and map Space to boost, not handbrake,
inside `VehicleTest.tscn`.

Rollback: delete the experiment import and addon folder. Never connect it to
`PlayerKart.tscn` during evaluation.

### Godot Recipes 3D Sphere Car

Study `car.gd`, `Camera3D.gd`, and `car.tscn` for simple arcade handling ideas.
It has no addon or autoload. Do not copy its track or art into NovaKart. Any
prototype copy belongs only under the experiment folder and can be rolled back
by deleting that folder.

### GDQuest Demos

There is no single `gdquest-demos` addon to import. Select a specific repository
and verify its code and asset licenses before copying anything. Good study
targets include Godot 4 custom Resources, UI, dialogue-tree, save, and
progression examples. Prefer reimplementing patterns in NovaKart's style over
copying complete demo projects.

Rollback: remove the isolated reference implementation and attribution entry.

## Recommendation Summary

1. Pilot Dialogic first because dialogue is easier to isolate from saved game
   state.
2. Pilot QuestSystem second behind an adapter and compare it with NovaKart's
   working mission/adventure framework.
3. Use QuestSystem examples and GDQuest demos as references, not dependencies.
4. Keep vehicle systems study-only until kid playtests establish a handling
   problem the current controller cannot solve.

## Sources

- Dialogic repository and license: https://github.com/dialogic-godot/dialogic
- QuestSystem repository: https://github.com/shomykohai/quest-system
- QuestSystem example: https://github.com/shomykohai/quest-system-example
- Advanced QuestSystem example: https://github.com/shomykohai/advanced-quest-system-example
- Godot Easy Vehicle Physics: https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics
- Sphere car recipe: https://github.com/godotrecipes/3d_car_sphere
- GDQuest demos organization: https://github.com/gdquest-demos
