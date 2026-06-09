class_name MenuNavigation
extends Control

var animation_time := 0.0

func _ready() -> void:
	$MenuPanel/StartRacing.grab_focus()
	AudioManager.request_narration("welcome_to_novakart_academy")

func _process(delta: float) -> void:
	animation_time += delta
	_animate_cloud($World/CloudLeft, 0.0, 28.0)
	_animate_cloud($World/CloudRight, 1.8, 22.0)
	_animate_float($Showcase/Blaze, 0.0, 7.0)
	_animate_float($Showcase/Finn, 0.8, 8.0)
	_animate_float($Showcase/Nova, 1.6, 7.5)
	_animate_float($Showcase/Dash, 2.4, 8.5)
	for index: int in $Sparkles.get_child_count():
		var sparkle := $Sparkles.get_child(index)
		sparkle.modulate.a = 0.35 + sin(animation_time * 2.4 + index) * 0.35
		sparkle.rotation = animation_time * (0.25 + index * 0.03)

func _animate_cloud(cloud: Control, phase: float, distance: float) -> void:
	if not cloud.has_meta("start_x"):
		cloud.set_meta("start_x", cloud.position.x)
	cloud.position.x = cloud.get_meta("start_x") + sin(animation_time * 0.22 + phase) * distance

func _animate_float(card: Control, phase: float, distance: float) -> void:
	if not card.has_meta("start_y"):
		card.set_meta("start_y", card.position.y)
	card.position.y = card.get_meta("start_y") + sin(animation_time * 1.35 + phase) * distance
	card.rotation = sin(animation_time * 0.75 + phase) * 0.018

func _on_start_pressed() -> void:
	open_scene("res://scenes/hub/HubWorld.tscn")

func _on_characters_pressed() -> void:
	open_scene("res://scenes/main/CharacterSelect.tscn")

func _on_stickers_pressed() -> void:
	open_scene("res://scenes/main/StickerBook.tscn")

func _on_settings_pressed() -> void:
	open_scene("res://scenes/main/Settings.tscn")

func open_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
