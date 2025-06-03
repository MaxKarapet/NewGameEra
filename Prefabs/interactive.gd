extends Node3D
class_name Interactive
@onready var outline=preload("res://Prefabs/outline_inter.tres")
@export var meshes: Array[MeshInstance3D]
@export var area: Area3D
@export var time_to_interact: int 
@export var particles: GPUParticles3D
@export var priority: int 
func _ready() -> void:
	area.emit_signal("body_entered")
	area.connect("body_entered",Callable(self, "_on_area_3d_body_entered"))
	for mesh in meshes:
		mesh.material_overlay=outline
	$"../..".update_targets($".",priority)
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name=="NPC":
		body.start_interacting($".",time_to_interact)
		
func interaction_complete():
	$"../..".update_targets($".",-1)
	for mesh in meshes:
		mesh.material_overlay=null
	particles.emitting=false
	area.queue_free()
