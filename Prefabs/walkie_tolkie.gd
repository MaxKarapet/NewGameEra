extends Placeble

var shoot_once=true
var inter_sc=preload("res://Prefabs/fake_inter.tscn")
func _unhandled_input(event: InputEvent) -> void:
	if Globals.prepare_stage and not Globals.placing:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed:
			Globals.money+=cost
			queue_free()
	else:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and shoot_once:
			shoot_once=false
			
			$Trappp/CollisionShape3D.disabled=true
			var inter=inter_sc.instantiate()
			$"../../Interactions".add_child(inter)
			inter.global_position=global_position
