class_name RaceCoin
extends Area3D

var collected := false

func _process(delta: float) -> void:
	rotate_y(delta * 2.5)

func _on_body_entered(body: Node3D) -> void:
	if collected or not body.has_method("collect_coin"):
		return
	collected = true
	body.collect_coin()
	visible = false
	set_deferred("monitoring", false)
