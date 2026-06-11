class_name AdventureHall
extends Control

var selected_adventure_id := "lighthouse_hero"
var launch_after_dialogue := false
var adventure_ids: Array[String] = []
var selected_index := 0

func _ready() -> void:
	$DialoguePanel.continued.connect(_on_dialogue_continued)
	for adventure: AdventureData in ContentCatalog.get_all_adventures():
		adventure_ids.append(adventure.id)
	adventure_ids.sort()
	if adventure_ids.is_empty():
		$Board/Card/Title.text = "NEW ADVENTURES COMING SOON!"
		$Board/Card/Action.disabled = true
		return
	if selected_adventure_id in adventure_ids:
		selected_index = adventure_ids.find(selected_adventure_id)
	_show_adventure(adventure_ids[selected_index])
	$Board/Card/Action.grab_focus()

func _show_adventure(adventure_id: String) -> void:
	selected_adventure_id = adventure_id
	var adventure := ContentCatalog.get_adventure(adventure_id)
	var guide := ContentCatalog.get_character(adventure.guide_character)
	var mission := ContentCatalog.get_mission(adventure.mission_id)
	var progress := SaveManager.get_adventure_progress(adventure_id)
	var sticker := ContentCatalog.get_sticker(adventure.rewards.get("sticker", ""))
	$Board/Card/GuidePortrait.configure(adventure.guide_character, "Adventure Guide")
	$Board/Card/Title.text = adventure.title
	$Board/Card/Guide.text = "GUIDE: %s" % guide.get("name", "Academy Hero").to_upper()
	$Board/Card/Story.text = adventure.intro_dialogue
	$Board/Card/Rewards.text = "REWARDS  🏅 BADGE  •  %s STICKER  •  📘 STAMP" % sticker.get("icon", "★")
	$Board/Card/Progress.text = "PROGRESS  %d / %d GOALS" % [progress.get("completed_objectives", 0), progress.get("total_objectives", mission.get("objectives", []).size())]
	var status: String = progress.get("status", "available")
	$Board/Card/Status.text = status.to_upper()
	$Board/Card/Action.text = "★  VIEW CELEBRATION" if status == "complete" else "★  CONTINUE ADVENTURE" if status == "active" else "★  START ADVENTURE"
	$Board/Count.text = "%d / %d" % [selected_index + 1, adventure_ids.size()]

func _open_selected() -> void:
	var adventure := ContentCatalog.get_adventure(selected_adventure_id)
	if SaveManager.is_adventure_complete(selected_adventure_id):
		$AdventureCompletionScreen.show_adventure(selected_adventure_id)
		return
	launch_after_dialogue = true
	$DialoguePanel.show_dialogue(adventure.guide_character, adventure.intro_dialogue)

func _on_dialogue_continued() -> void:
	if not launch_after_dialogue:
		return
	launch_after_dialogue = false
	var adventure := ContentCatalog.get_adventure(selected_adventure_id)
	SaveManager.start_adventure(selected_adventure_id)
	get_tree().change_scene_to_file(adventure.destination_scene)

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")

func _previous_adventure() -> void:
	selected_index = wrapi(selected_index - 1, 0, adventure_ids.size())
	_show_adventure(adventure_ids[selected_index])

func _next_adventure() -> void:
	selected_index = wrapi(selected_index + 1, 0, adventure_ids.size())
	_show_adventure(adventure_ids[selected_index])
