extends SceneTree

const REQUIRED_KEYS := {
	"steer_left": KEY_LEFT,
	"steer_right": KEY_RIGHT,
	"drive_forward": KEY_UP,
	"brake": KEY_DOWN,
	"boost": KEY_SPACE,
}

func _initialize() -> void:
	for action: String in REQUIRED_KEYS:
		if not InputMap.has_action(action) or not _action_has_key(action, REQUIRED_KEYS[action]):
			push_error("%s is not linked correctly" % action)
			quit(1)
			return
	print("Input map check passed: arrow keys and Space are linked.")
	quit()

func _action_has_key(action: String, expected_key: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			if event.keycode == expected_key or event.physical_keycode == expected_key:
				return true
	return false
