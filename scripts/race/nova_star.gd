class_name NovaStar
extends Area3D

var collected := false
var start_height: float
var time := 0.0

func _ready() -> void:
	start_height = position.y

func _process(delta: float) -> void:
	time += delta
	rotate_y(delta * 2.2)
	position.y = start_height + sin(time * 2.5) * 0.18

func _on_body_entered(body: Node3D) -> void:
	if collected or not body.has_method("collect_nova_star"):
		return
	collected = true
	body.collect_nova_star()
	visible = false
	set_deferred("monitoring", false)
