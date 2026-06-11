# Sprint 13: Isolated Dialogic Test

## Scope

Dialogic `2.0-alpha-19` is pinned for evaluation only. No production scene,
save data, mission, adventure, or character-select flow uses Dialogic.

Open and run:

`res://experiments/open_source_tests/DialogueTest.tscn`

## Manual Checklist

- Confirm the group conversation shows Finn, Blaze, Nova, and Dash.
- Confirm every speaker has a visible portrait and character name.
- Press the large Continue button and confirm the conversation advances.
- Press Space and confirm it also advances.
- Use each hero button to launch that character's individual test conversation.
- Confirm the header reports a voice-ready hook after each hero speaks.
- Confirm missing future voice audio does not interrupt dialogue.
- Confirm the production title, character select, hub, and race scenes still run.

## Automated Check

```sh
godot --headless --path . --script res://scripts/tests/sprint13_check.gd
```

The automated check validates the pinned addon, four Dialogic character
resources, portrait paths, individual timelines, group conversation, Continue
button, names, and future voice-ready signals.

## Evaluation Note

Dialogic `2.0-alpha-19` runs correctly in the Godot 4.6 project, but currently
reports retained-resource/ObjectDB warnings when headless runs shut down. This
does not fail the test or affect production scenes, but it should be resolved
or re-evaluated against a newer pinned Dialogic release before production use.

## Rollback

1. Disable `res://addons/dialogic/plugin.cfg`.
2. Remove the `Dialogic` autoload and `dialogic_default_action`.
3. Delete `res://addons/dialogic/`, `res://third_party/dialogic/`, and the
   experiment-owned Dialogic resources.

No production scene or save migration is required.
