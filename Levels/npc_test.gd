extends Node3D
var cameras: Array
var camera_count: int
var curr_camera:int=0
var enemy: CharacterBody3D
var targets={}
var current_target
func _ready() -> void:
	enemy=$NPC
	cameras=$Cameras.get_children()
	camera_count=$Cameras.get_child_count()
	cameras[curr_camera].current=true
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("swap_left"):
		curr_camera=(curr_camera-1)%camera_count
		cameras[curr_camera].current=true
		$UI.camera=get_viewport().get_camera_3d()
	if Input.is_action_just_pressed("swap_right"):
		curr_camera=(curr_camera+1)%camera_count
		cameras[curr_camera].current=true
		$UI.camera=get_viewport().get_camera_3d()
	if Input.is_action_just_pressed("start"):
		Globals.prepare_stage=false
func _physics_process(delta: float) -> void:
	if !Globals.prepare_stage:
		if current_target:
			enemy.update_target_location(current_target.global_position)
		else:
			enemy.stop_moving()

func update_targets(target,priority=0):
	
	if priority==-1:
		if target in targets.keys():
			targets.erase(target)
		current_target=null
	elif target not in targets.keys():
		targets[target]=priority
		current_target=target
	if priority!=0 or targets!={}:
		var _min
		if priority==-1:
			_min=99999
		else:
			_min=priority
		for i in targets.keys():
			if targets[i]<_min:
				_min=targets[i]
				current_target=i
	if targets=={}:
		Globals.win=-1
