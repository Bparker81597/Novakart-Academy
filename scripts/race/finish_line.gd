class_name FinishLine
extends Area3D

signal race_finished

func _on_body_entered(body: Node3D) -> void:
	if body is KartController:
		race_finished.emit()
