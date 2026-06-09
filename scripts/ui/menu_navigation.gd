class_name MenuNavigation
extends Control

var animation_time := 0.0

func _ready() -> void:
	$Showcase/Blaze.configure("blaze_bolt", "Turbo Tiger")
	$Showcase/Finn.configure("finn_tide", "Captain Coral")
	$Showcase/Nova.configure("nova_spark", "Young Inventor")
	$Showcase/Dash.configure("dash_rocket", "Rocket Rabbit")
	$MenuPanel/StartRacing.grab_focus()
	AudioManager.request_narration("welcome_to_novakart_academy")

func _process(delta: float) -> void:
	animation_time += delta
	_animate_cloud($World/CloudLeft, 0.0, 28.0)
	_animate_cloud($World/CloudRight, 1.8, 22.0)

func _animate_cloud(cloud: Control, phase: float, distance: float) -> void:
	if not cloud.has_meta("start_x"):
		cloud.set_meta("start_x", cloud.position.x)
	cloud.position.x = cloud.get_meta("start_x") + sin(animation_time * 0.22 + phase) * distance

func _on_start_pressed() -> void:
	open_scene("res://scenes/main/CharacterSelect.tscn")

func _on_characters_pressed() -> void:
	open_scene("res://scenes/main/CharacterSelect.tscn")

func _on_stickers_pressed() -> void:
	open_scene("res://scenes/main/StickerBook.tscn")

func _on_settings_pressed() -> void:
	open_scene("res://scenes/main/Settings.tscn")

func open_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
