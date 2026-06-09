class_name CharacterParticleEffect
extends Control

var animation_time := 0.0
var base_positions: Array[Vector2] = []

func _ready() -> void:
	for particle: Label in $Particles.get_children():
		base_positions.append(particle.position)

func _process(delta: float) -> void:
	animation_time += delta
	for index: int in $Particles.get_child_count():
		var particle: Label = $Particles.get_child(index)
		particle.position.y = base_positions[index].y + sin(animation_time * (1.0 + index * 0.09) + index) * 13.0
		particle.rotation = sin(animation_time * 0.8 + index) * 0.25
		particle.modulate.a = 0.38 + (sin(animation_time * 1.8 + index) + 1.0) * 0.28

func configure(profile: Dictionary) -> void:
	var color := Color(profile.get("color", "#a94dff"))
	var glyph: String = profile.get("particle_icon", "✦")
	for particle: Label in $Particles.get_children():
		particle.text = glyph
		particle.modulate = color
