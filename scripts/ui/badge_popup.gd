class_name BadgePopup
extends Control

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func celebrate() -> void:
	visible = true
	scale = Vector2(0.15, 0.15)
	modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(hide)
