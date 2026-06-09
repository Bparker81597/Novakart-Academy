class_name BigKidButton
extends Button

@export var button_color := Color("169ee8")

func _ready() -> void:
	custom_minimum_size.y = max(custom_minimum_size.y, 72.0)
	add_theme_font_size_override("font_size", 28)
	_apply_style()
	mouse_entered.connect(_hover_on)
	mouse_exited.connect(_hover_off)
	button_down.connect(_press_down)
	button_up.connect(_hover_on)

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = button_color
	style.border_color = button_color.lightened(0.35)
	style.set_border_width_all(5)
	style.set_corner_radius_all(24)
	style.shadow_color = Color(button_color.darkened(0.5), 0.45)
	style.shadow_size = 8
	for state: String in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, style)
	add_theme_color_override("font_color", Color.WHITE)

func _hover_on() -> void:
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2(1.045, 1.045), 0.14)

func _hover_off() -> void:
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ONE, 0.14)

func _press_down() -> void:
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2(0.97, 0.97), 0.08)
