extends SceneTree

const STARTER_STICKERS := [
	"first_race",
	"first_win",
	"blaze_fan",
	"finn_fan",
	"nova_fan",
	"dash_fan",
	"academy_student",
	"star_collector",
]

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")

	assert(catalog.stickers.size() == 8, "Sticker Book needs eight starter stickers.")
	for sticker_id: String in STARTER_STICKERS:
		var sticker: Dictionary = catalog.get_sticker(sticker_id)
		for key: String in ["name", "icon", "hint", "category", "rarity", "rarity_color"]:
			assert(sticker.has(key), "%s is missing %s" % [sticker_id, key])

	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)
	var blaze_rewards: Array[String] = save_manager.record_race(7, "blaze_bolt")
	for sticker_id: String in ["first_race", "first_win", "blaze_fan", "star_collector"]:
		assert(sticker_id in blaze_rewards, "First Blaze race should unlock %s" % sticker_id)
	assert(save_manager.record_race(0, "finn_tide") == ["finn_fan"], "Second race should only unlock Finn Fan.")
	save_manager.progress = original_progress
	save_manager.save_progress()

	var book: Node = load("res://scenes/main/StickerBook.tscn").instantiate()
	root.add_child(book)
	await process_frame
	for category_path: String in ["Categories/Characters", "Categories/Racing", "Categories/Academy", "Categories/Exploration"]:
		assert(book.has_node(category_path), "Sticker Book is missing %s" % category_path)
	book._show_category("characters")
	assert(book.get_node("StickerGrid").get_child_count() == 4, "Character category needs four stickers.")
	book._show_category("exploration")
	assert(book.get_node("Empty").visible, "Exploration category needs a coming-soon state.")

	var popup: Node = load("res://scenes/ui/StickerUnlockPopup.tscn").instantiate()
	root.add_child(popup)
	await process_frame
	var popup_ids: Array[String] = ["first_win"]
	popup.show_stickers(popup_ids)
	await process_frame
	assert(popup.visible, "Sticker popup should become visible.")
	assert(popup.get_node("Card/Name").text == "First Win", "Sticker popup preview is wrong.")
	assert(popup.get_node("Confetti").emitting, "Sticker popup should play confetti.")
	assert(ResourceLoader.exists("res://assets/audio/ui/sticker_unlock.wav"), "Sticker unlock sound effect is missing.")
	await create_timer(0.8).timeout

	var hub: PackedScene = load("res://scenes/hub/HubWorld.tscn")
	var hub_instance := hub.instantiate()
	root.add_child(hub_instance)
	await process_frame
	assert(hub_instance.get_node("StickerZone").target_scene == "res://scenes/main/StickerBook.tscn", "Sticker Hall should open Sticker Book.")

	var title: Node = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(title)
	await process_frame
	for portrait_name: String in ["Blaze", "Finn", "Nova", "Dash"]:
		var portrait: Node = title.get_node("Showcase/%s" % portrait_name)
		assert(portrait.idle_animation, "%s title portrait needs idle animation." % portrait_name)
		assert(portrait.has_node("SparkleLeft") and portrait.has_node("SparkleRight"), "%s title portrait needs sparkles." % portrait_name)

	print("Sprint 7 Sticker Book progression checks passed.")
	quit()
