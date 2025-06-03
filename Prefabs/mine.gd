extends Placeble

var shoot_once=true

func shoot(obj):
	$GPUParticles3D.emitting=true
	$GPUParticles3D2.emitting=true
	obj.stun(4)
	$Timer.start()
func _on_trap_body_entered(body: Node3D) -> void:
	if body.name=="NPC" and already_placed:
		shoot(body)


func _on_timer_timeout() -> void:
	$GPUParticles3D.emitting=false
	$GPUParticles3D2.emitting=false
	$Trappp/CollisionShape3D.disabled=true
