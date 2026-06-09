class_name CharacterPortraitCard
extends Control

var character_id := "nova_spark"
var base_position := Vector2.ZERO
var animation_time := 0.0

func _ready() -> void:
	base_position = position

func _process(delta: float) -> void:
	animation_time += delta
	position.y = base_position.y + sin(animation_time * 1.7) * 7.0
	$Mascot/Content/Icon.rotation = sin(animation_time * 1.3) * 0.045

func configure(new_character_id: String) -> void:
	character_id = new_character_id
	var profile := ContentCatalog.get_character(character_id)
	var color := Color(profile.get("color", "#a94dff"))
	$Mascot/Content/Icon.text = profile.get("icon", "★")
	$Mascot/Content/Icon.modulate = color
	$Mascot/Content/Type.text = profile.get("type", profile.get("theme", ""))
	$Pattern.text = "%s   %s   %s" % [profile.get("icon", "★"), profile.get("particle_icon", "✦"), profile.get("icon", "★")]
	$Pattern.modulate = Color(color, 0.18)
	var style := StyleBoxFlat.new()
	style.bg_color = color.lightened(0.58)
	style.border_color = color
	style.set_border_width_all(9)
	style.set_corner_radius_all(48)
	style.shadow_color = Color(color.darkened(0.4), 0.35)
	style.shadow_size = 16
	$Mascot.add_theme_stylebox_override("panel", style)
