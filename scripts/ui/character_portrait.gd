class_name CharacterPortrait
extends PanelContainer

@export var character_id := "nova_spark"
@export var show_name := true
@export var show_subtitle := true
@export var subtitle_override := ""
@export var idle_animation := true

var base_position := Vector2.ZERO
var idle_time := 0.0

func _ready() -> void:
	base_position = position
	configure(character_id, subtitle_override)

func _process(delta: float) -> void:
	if not idle_animation:
		return
	idle_time += delta
	position.y = base_position.y + sin(idle_time * 1.7 + character_id.length()) * 4.0
	$Content/Icon.rotation = sin(idle_time * 1.2 + character_id.length()) * 0.035

func configure(new_character_id: String, new_subtitle: String = "") -> void:
	character_id = new_character_id
	var profile := ContentCatalog.get_character(character_id)
	var color := Color(profile.get("color", "#a94dff"))
	$Content/Icon.text = profile.get("icon", "★")
	$Content/Icon.modulate = color
	$Content/Name.text = profile.get("name", "Nova Spark")
	$Content/Name.visible = show_name
	$Content/Subtitle.text = new_subtitle if not new_subtitle.is_empty() else profile.get("theme", "")
	$Content/Subtitle.visible = show_subtitle
	var style := StyleBoxFlat.new()
	style.bg_color = color.lightened(0.55)
	style.border_color = color
	style.set_border_width_all(5)
	style.set_corner_radius_all(24)
	style.shadow_color = Color(color, 0.4)
	style.shadow_size = 8
	add_theme_stylebox_override("panel", style)
