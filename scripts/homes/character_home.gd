class_name CharacterHome
extends Node3D

@export var home_data: HomeData

var animation_time := 0.0

func _ready() -> void:
	if not home_data:
		home_data = ContentCatalog.get_home("finn_dock")
	configure_home(home_data)
	$CanvasLayer/HUD/Back.focus_mode = Control.FOCUS_NONE

func _process(delta: float) -> void:
	animation_time += delta
	$HomeIcon.position.y = 6.0 + sin(animation_time * 1.7) * 0.15
	$HomeIcon.rotate_y(delta * 0.45)

func configure_home(new_home_data: HomeData) -> void:
	if not new_home_data:
		return
	home_data = new_home_data
	var profile := ContentCatalog.get_character(home_data.character_id)
	var friendship_level := SaveManager.get_friendship_level(home_data.character_id)
	$HomeTitle.text = "%s  %s" % [home_data.home_icon, home_data.home_name.to_upper()]
	$HomeTitle.modulate = home_data.accent_color
	$HomeIcon.text = home_data.home_icon
	$HomeIcon.modulate = home_data.accent_color
	_apply_material($Floor, home_data.primary_color.lightened(0.35))
	_apply_material($BackWall, home_data.primary_color)
	_apply_material($AccentWall, home_data.accent_color)
	$CanvasLayer/HUD/Portrait.configure(home_data.character_id, home_data.home_name)
	$CanvasLayer/HUD/FriendshipPanel.configure(home_data.character_id)
	$CanvasLayer/HUD/GreetingPanel/Name.text = profile.get("name", "Academy Friend").to_upper()
	$CanvasLayer/HUD/GreetingPanel/Text.text = home_data.greeting
	_configure_decorations(friendship_level)
	_configure_rewards()
	_configure_collectibles()

func show_character_greeting() -> void:
	$CanvasLayer/HUD/GreetingPanel.visible = true
	$CanvasLayer/HUD/GreetingPanel.scale = Vector2(0.7, 0.7)
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property($CanvasLayer/HUD/GreetingPanel, "scale", Vector2.ONE, 0.28)
	AudioManager.play_character_greeting(home_data.character_id)
	get_tree().create_timer(4.0).timeout.connect(_hide_greeting)

func _hide_greeting() -> void:
	$CanvasLayer/HUD/GreetingPanel.visible = false

func _configure_decorations(friendship_level: int) -> void:
	var decoration_nodes := $Decorations.get_children()
	for index: int in decoration_nodes.size():
		var decoration: Dictionary = home_data.decorations[index] if index < home_data.decorations.size() else {}
		decoration_nodes[index].visible = not decoration.is_empty()
		if not decoration.is_empty():
			decoration_nodes[index].configure(decoration, friendship_level, home_data.accent_color)

func _configure_rewards() -> void:
	var unlocked: Array = SaveManager.get_friendship_rewards(home_data.character_id)
	var lines: Array[String] = []
	for reward: Dictionary in ContentCatalog.get_friendship_character(home_data.character_id).get("rewards", []):
		var marker := "✓" if reward.get("id", "") in unlocked else "🔒"
		lines.append("%s  LV.%d  %s" % [marker, int(reward.get("level", 1)), reward.get("label", "Friendship Reward")])
	$CanvasLayer/HUD/RewardsPanel/List.text = "\n".join(lines)

func _configure_collectibles() -> void:
	var lines: Array[String] = []
	for slot: Dictionary in home_data.collectible_slots:
		lines.append("◇  %s  %s" % [slot.get("icon", "★"), slot.get("label", "Future Collection")])
	$CanvasLayer/HUD/CollectiblesPanel/List.text = "\n".join(lines)

func _apply_material(mesh: MeshInstance3D, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	mesh.material_override = material

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")
