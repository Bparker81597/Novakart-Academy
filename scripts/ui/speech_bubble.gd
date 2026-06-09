class_name SpeechBubble
extends PanelContainer

func _ready() -> void:
	scale = Vector2(0.1, 0.1)
	modulate.a = 0.0

func show_line(line: String, color: Color) -> void:
	$Text.text = line
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = color
	style.set_border_width_all(6)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(color, 0.28)
	style.shadow_size = 10
	add_theme_stylebox_override("panel", style)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.42)
