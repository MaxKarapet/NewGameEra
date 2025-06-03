extends CanvasLayer
var shotgun_sc=preload("res://Prefabs/shotgun.tscn")
var mine_sc=preload("res://Prefabs/mine.tscn")
var grenade_sc=preload("res://Prefabs/grenade.tscn")
var walkie_sc=preload("res://Prefabs/walkie_tolkie.tscn")
var camera: Camera3D
var instance: Placeble
var range = 1000
var can_place=false
@onready var item_list=$Weapons/ItemList
@onready var parent=$"../Traps"

func _ready() -> void:
	camera=get_viewport().get_camera_3d()
func _unhandled_input(event: InputEvent) -> void:
	if Globals.win!=0 and event.is_action_pressed("start"):
		get_tree().change_scene_to_file("res://Tools/menu.tscn")
	if Globals.prepare_stage:
		if Globals.placing:
			if event.is_action_pressed("right_click"):
				#item_list.modulate=Color(1,1,1,1)
				#item_list.mouse_filter=0
				instance.queue_free()
				Globals.placing=false
				item_list.deselect_all()
				$HBoxContainer/Money2.visible=false
				$HBoxContainer/Dollar2.visible=false
			if event.is_action_pressed("left_click") and can_place:
				#item_list.modulate=Color(1,1,1,1)
				#item_list.mouse_filter=0
				Globals.placing=false
				can_place=false
				instance.placed()
				
				item_list.deselect_all()
				$HBoxContainer/Money2.visible=false
				$HBoxContainer/Dollar2.visible=false
func _process(delta: float) -> void:
	if Globals.win==1:
		$GameOver/TextureRect2.visible=true
		$GameOver.visible=true
		$GameOver/Label.text="ПОБЕДА!!!"
		$GameOver/Label.label_settings.font_color=Color(0,1,0,1)
	elif Globals.win==-1:
		$GameOver/TextureRect.visible=true
		$GameOver.visible=true
		$GameOver/Label.text="ПОРАЖЕНИЕ..."
		$GameOver/Label.label_settings.font_color=Color(1,0,0,1)
	$HBoxContainer/Money.text=str(Globals.money)
	if Globals.placing:
		
		if Input.is_action_pressed("rotate_right"):
			instance.rotation_degrees.y-=delta*75
		if Input.is_action_pressed("rotate_left"):
			instance.rotation_degrees.y+=delta*75
		var mouse_pos=get_viewport().get_mouse_position()
		var ray_origin=camera.project_ray_origin(mouse_pos)
		var ray_end=ray_origin+camera.project_ray_normal(mouse_pos)*range
		var query=PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
		var collision=camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			instance.transform.origin=Vector3(snapped(collision.position.x,0.25),snapped(collision.position.y,0.25),snapped(collision.position.z,0.25))
			can_place=instance.check_placement()
func _on_item_list_item_selected(index: int) -> void:
	if Globals.prepare_stage:
		if Globals.placing:
			instance.queue_free()
		if index==0:
			instance=shotgun_sc.instantiate()
		elif index==1:
			instance=mine_sc.instantiate()
		elif index==2:
			instance=grenade_sc.instantiate()
		elif index==3:
			instance=walkie_sc.instantiate()
		$HBoxContainer/Money2.text="-"+str(instance.cost)
		$HBoxContainer/Money2.visible=true
		$HBoxContainer/Dollar2.visible=true
		#item_list.modulate=Color(1,1,1,0.3)
		#item_list.mouse_filter=2
		Globals.placing=true
		parent.add_child(instance)
