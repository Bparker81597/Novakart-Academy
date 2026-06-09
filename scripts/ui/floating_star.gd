extends Label

@export var float_distance := 8.0
@export var float_speed := 1.3

var base_position := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	base_position = position

func _process(delta: float) -> void:
	time += delta
	position.y = base_position.y + sin(time * float_speed + position.x) * float_distance
	rotation = sin(time * 0.8 + position.y) * 0.18
	modulate.a = 0.55 + sin(time * 2.0 + position.x) * 0.35
