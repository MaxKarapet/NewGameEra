extends Placeble

var damage=75
var range=4
var dmg_mult=1
var shoot_once=true
var shield_once=true
var c0=preload("res://Assets/граната/circle.tres")
var c1=preload("res://Assets/граната/circle_001.tres")
var c2=preload("res://Assets/граната/circle_002.tres")
var c3=preload("res://Assets/граната/Plane.tres")
var c4=preload("res://Assets/граната/Sphere.tres")
func _process(delta: float) -> void:
	if founded and shield_once and not shoot_once:
		npc.get_shielded($Timer.time_left+0.5)
		shield_once=false
func _unhandled_input(event: InputEvent) -> void:
	if Globals.prepare_stage:
		if not Globals.placing:
			if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed:
				Globals.money+=cost
				queue_free()
	else:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed and shoot_once:
			$Timer.start()
			$Explosion/CollisionShape3D.disabled=false
			$Trap.input_ray_pickable=false
			shoot_once=false
func shoot():
	$Trap/CollisionShape3D.disabled=true
	$Timer2.start()
	$OmniLight3D.visible=true
	var obj=null
	for particle in $ShootEff.get_children():
		particle.emitting=true
	var ray = $CheckExpl
	var overlaps=$Explosion.get_overlapping_bodies()
	for overlap in overlaps:
		
		if overlap.name=="NPC":
			var body_pos=overlap.global_transform.origin
			ray.look_at(body_pos+Vector3(0,0.5,0), Vector3.UP)
			ray.force_raycast_update()
			if ray.is_colliding():
				var collider=ray.get_collider()
				if collider.name=="NPC":
					if obj!=collider:
						obj=collider
					dmg_mult=1/max(1,(global_position-body_pos).length())
	ray.queue_free()
	$Meshes.queue_free()
	$Explosion.queue_free()
	if obj:
		obj.hit(int(damage*dmg_mult))
		
func placed() ->void:
	Globals.money-=cost
	mouse_in=false
	$Meshes/Circle.material_override=c0
	$Meshes/Circle_001.material_override=c1
	$Meshes/Circle_002.material_override=c2
	$Meshes/Plane.material_override=c3
	$Meshes/Sphere.material_override=c4
	for ray in raycasts:
		ray.queue_free()
	already_placed=true

func _on_timer_timeout() -> void:
	shoot()


func _on_timer_2_timeout() -> void:
	$OmniLight3D.visible=false
