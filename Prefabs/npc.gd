extends CharacterBody3D
@onready var shield_mat=preload("res://Prefabs/shield.tres")
@onready var hit_eff=preload("res://Tools/hit_effect.tscn")
var nav_agent: NavigationAgent3D
var current_pos=Vector3.ZERO
var next_location=Vector3.ZERO
var new_velocity=Vector3.ZERO
var SPEED = 2.0
var HEALTH = 200.0
var SANITY = 100.0
var can_hit:bool=true
var shielding:bool=false
var interacting:bool=false
var stunned:bool=false
var dead:bool=false
var die_once:bool=true
var founded_traps:Array
var moving=true
var interactable=null
var int_time=5
func _ready() -> void:
	nav_agent=$NavigationAgent3D

func _physics_process(delta: float) -> void:
	if dead and die_once:
		die_once=false
		$CollisionShape3D.disabled=true
		$DeathTime.start()
		$robots/AnimationPlayer.play("Armature|death")
		velocity=Vector3(0,-0.5,0)
	if dead:
		move_and_slide()
		return
	if not shielding and not stunned:
		if moving and can_hit:
			current_pos=global_transform.origin
			next_location=nav_agent.get_next_path_position()
			new_velocity=(next_location-current_pos).normalized()*SPEED
			velocity=velocity.move_toward(new_velocity,0.15)
			rotation.y = atan2(velocity.x,velocity.z)
			move_and_slide()
		elif interacting:
			$robots/AnimationPlayer.play("Armature|repair")
		elif can_hit:
			$robots/AnimationPlayer.play("Armature|idol")
	
func update_target_location(target_pos):
	if dead:
		return
	if not shielding and not interacting and can_hit and not stunned:
		$robots/AnimationPlayer.play("Armature|WALK_2")
		moving=true
		nav_agent.target_position=target_pos

func hit(damage):
	if dead:
		return
	interacting=false
	if interactable:
		interactable.particles.emitting=false
	$InteractTimer.stop()
	var eff=hit_eff.instantiate()
	$Effects.add_child(eff)
	if not can_hit:
		get_shielded(1)
	if shielding:
		HEALTH-=damage/2
		eff.amount_ratio=float(damage/2)/100.0
	else:
		HEALTH-=damage
		if not stunned:
			$robots/AnimationPlayer.play("Armature|damadge")
		eff.amount_ratio=float(damage)/100.0
		
	eff.emitting=true
	can_hit=false
	moving=false
	if HEALTH<0:
		dead=true
	$HitTimer.start()
func stop_moving():
	moving=false
	



func _on_vision_timer_timeout() -> void:
	if dead:
		return
	var overlaps = $Vision.get_overlapping_areas()
	if overlaps.size()>0:
		for overlap in overlaps:
			var area_pos=overlap.global_transform.origin
			$VisionRay.look_at(area_pos, Vector3.UP)
			$VisionRay.force_raycast_update()
			if $VisionRay.is_colliding():
				var colliding=$VisionRay.get_collider()
				if colliding.name=="Trap":
					if colliding not in founded_traps:
						founded_traps.append(colliding)
						$Label3D.text="!"
						$Label3D.visible=true
						$TextTimer.start()
					colliding.get_parent().remember_me($".")
func get_shielded(time):
	if dead:
		return
	interacting=false
	$InteractTimer.stop()
	if interactable:
		interactable.particles.emitting=false
	if not shielding and not stunned:
		$robots/AnimationPlayer.play("Armature|defance",-1,2)
	shielding=true
	stop_moving()
	$robots/Armature/Skeleton3D/ROBOT.material_overlay=shield_mat
	$ShieldTimer.wait_time=time
	$ShieldTimer.start()
	
func start_interacting(thing,time):
	if dead:
		return
	interacting=true
	thing.particles.emitting=true
	moving=false
	interactable=thing
	int_time=time
	$InteractTimer.wait_time=time
	$InteractTimer.start()
func stun(time):
	if dead:
		return
	$robots/AnimationPlayer.stop()
	stunned=true
	$Stun.wait_time=time
	$Stun.start()
func _on_shield_timer_timeout() -> void:
	if dead:
		return
	shielding=false
	$robots/Armature/Skeleton3D/ROBOT.material_overlay=null
	if interactable!=null:
		look_at(-interactable.position)
		start_interacting(interactable,int_time)
	else:
	
		moving=true
	


func _on_text_timer_timeout() -> void:
	$Label3D.visible=false


func _on_hit_timer_timeout() -> void:
	if dead:
		return
	if interactable!=null:
		look_at(-interactable.position)
		start_interacting(interactable,int_time)
	can_hit=true


func _on_interact_timer_timeout() -> void:
	if dead:
		return
	interacting=false
	interactable.interaction_complete()
	interactable=null


func _on_stun_timeout() -> void:
	stunned=false


func _on_death_time_timeout() -> void:
	Globals.win=1
	velocity=Vector3.ZERO
	
