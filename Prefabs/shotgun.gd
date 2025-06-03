extends Placeble

var damage=3
var spread=1
var range=30
var shoot_once=true
var bullet_count=0
@onready var special_ray=$ShootRays/RayCast3D
func _ready() -> void:
	area.emit_signal("mouse_entered")
	area.emit_signal("mouse_exited")
	area.connect("mouse_entered",Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited",Callable(self, "_on_mouse_exited"))
	randomize()
	for ray: RayCast3D in $ShootRays.get_children():
		ray.target_position.x=-range
		ray.target_position.y=randf_range(-spread,spread)
		ray.target_position.z=randf_range(-spread,spread)

func _unhandled_input(event: InputEvent) -> void:
	if Globals.prepare_stage:
		if not Globals.placing:
			if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed:
				Globals.money+=cost
				queue_free()
	else:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed and shoot_once:
			if founded:
				npc.get_shielded(1)
			$Timer.start()
			$Trap/CollisionShape3D.disabled=true
			$temp.material_overlay=null
			shoot_once=false
func shoot():
	$laser.visible=false
	$OmniLight3D.visible=true
	$OmniLight3D2.visible=true
	$Timer2.start()
	var obj=null
	for particle in $ShootEff.get_children():
		particle.emitting=true
	for particle in $ShootEff2.get_children():
		particle.emitting=true
	for ray: RayCast3D in $ShootRays.get_children():
		if ray.is_colliding():
			var collider=ray.get_collider()
			if collider.name=="NPC":
				if obj!=collider:
					obj=collider
				bullet_count+=1
		ray.queue_free()
	if obj:
		obj.hit(damage*bullet_count)
		


func _on_timer_timeout() -> void:
	shoot()


func _on_timer_2_timeout() -> void:
	$OmniLight3D.visible=false
	$OmniLight3D2.visible=false
