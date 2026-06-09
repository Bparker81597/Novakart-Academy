class_name CharacterCard
extends PanelContainer

signal character_selected(character_id: String)

var character_id := ""
var base_position := Vector2.ZERO
var selected := false

func configure(profile: Dictionary, is_selected: bool) -> void:
	character_id = profile.get("id", "")
	$Content/Portrait.text = profile.get("icon", "★")
	$Content/Name.text = profile.get("name", "")
	$Content/Theme.text = profile.get("theme", "")
	$Content/Ability.text = profile.get("ability", "")
	$Content/Catchphrase.text = "\"%s\"" % profile.get("catchphrase", "")
	var color := Color(profile.get("color", "#a94dff"))
	$Content/Portrait.modulate = color
	var style := StyleBoxFlat.new()
	style.bg_color = color.lightened(0.64)
	style.border_color = color
	style.set_border_width_all(7)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(color, 0.45)
	style.shadow_size = 12 if is_selected else 4
	add_theme_stylebox_override("panel", style)
	set_selected(is_selected, false)

func _ready() -> void:
	base_position = position
	mouse_entered.connect(_on_hover_started)
	mouse_exited.connect(_on_hover_ended)
	$Content/Select.pressed.connect(_on_select_pressed)

func set_selected(value: bool, animate: bool = true) -> void:
	selected = value
	$Content/Selected.visible = value
	if animate:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.16)
		tween.tween_property(self, "scale", Vector2.ONE, 0.28)
		var style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
		style.shadow_size = 16 if value else 4
		add_theme_stylebox_override("panel", style)

func _on_hover_started() -> void:
	z_index = 5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", base_position.y - 14.0, 0.16)
	tween.parallel().tween_property(self, "scale", Vector2(1.035, 1.035), 0.16)

func _on_hover_ended() -> void:
	z_index = 0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", base_position.y, 0.16)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.16)

func _on_select_pressed() -> void:
	character_selected.emit(character_id)
