extends Control
var main_lvl=preload("res://Levels/npc_test.tscn")

func _on_button_pressed() -> void:
	Globals.reset()
	get_tree().change_scene_to_packed(main_lvl)

func _on_button_2_pressed() -> void:
	get_tree().quit()
