class_name AIKartController
extends CharacterBody3D

@export var target_speed: float = 18.0

func _physics_process(_delta: float) -> void:
	velocity = -transform.basis.z * target_speed
	move_and_slide()
