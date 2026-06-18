# Open Source Tests

These scenes isolate open-source evaluations from production gameplay.

- `DialogueTest.tscn`: pinned Dialogic test with four NovaKart conversations,
  portraits, a Continue button, character names, and future voice hooks
- `QuestIntegrationTest.tscn`: pinned QuestSystem test for Finn Tide's Sea
  Turtle Rescue quest through `QuestAdapter -> WorldState`
- `QuestTest.tscn`: placeholder retained for older roadmap references
- `VehicleTest.tscn`: study-only vehicle handling comparison

Production scenes and saves must not depend on this folder.
