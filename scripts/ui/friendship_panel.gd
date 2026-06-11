class_name FriendshipPanel
extends PanelContainer

var character_id := ""

func _ready() -> void:
	SaveManager.friendship_changed.connect(_on_friendship_changed)

func configure(new_character_id: String) -> void:
	character_id = new_character_id
	var profile := ContentCatalog.get_character(character_id)
	var progress := SaveManager.get_friendship_level_progress(character_id)
	var level := int(progress.get("level", 1))
	var max_level := int(progress.get("max_level", 10))
	$Content/Header.text = "❤  FRIENDSHIP LEVEL %d / %d" % [level, max_level]
	$Content/Progress.max_value = int(progress.get("needed_xp", 100))
	$Content/Progress.value = int(progress.get("current_xp", 0))
	$Content/Progress.modulate = Color(profile.get("color", "#ff5c8a"))
	$Content/Xp.text = "MAX FRIENDSHIP!" if level >= max_level else "%d / %d FRIENDSHIP XP" % [progress.current_xp, progress.needed_xp]
	$Content/Reward.text = _next_reward_text(level)
	_apply_profile_decoration(profile)

func _next_reward_text(level: int) -> String:
	for reward: Dictionary in ContentCatalog.get_friendship_character(character_id).get("rewards", []):
		if int(reward.get("level", 0)) > level:
			return "NEXT: LEVEL %d  •  %s" % [reward.level, reward.label]
	var unlocked := SaveManager.get_friendship_rewards(character_id).size()
	return "★ %d FRIENDSHIP REWARDS UNLOCKED!" % unlocked

func _apply_profile_decoration(profile: Dictionary) -> void:
	var unlocked: Array = SaveManager.get_friendship_rewards(character_id)
	var has_decoration := false
	for reward: Dictionary in ContentCatalog.get_friendship_character(character_id).get("rewards", []):
		if reward.get("type", "") == "decoration" and reward.get("id", "") in unlocked:
			has_decoration = true
			break
	var style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	style.border_color = Color(profile.get("color", "#ff5c8a")) if has_decoration else Color("#ff5c94")
	style.set_border_width_all(11 if has_decoration else 7)
	add_theme_stylebox_override("panel", style)

func _on_friendship_changed(changed_character_id: String, _level: int, _xp: int) -> void:
	if changed_character_id == character_id:
		configure(character_id)
