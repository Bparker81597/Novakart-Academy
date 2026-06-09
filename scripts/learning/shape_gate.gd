class_name ShapeGate
extends Area3D

@export var answer: String = "circle"

func is_correct(selected_answer: String) -> bool:
	return selected_answer.to_lower() == answer.to_lower()
