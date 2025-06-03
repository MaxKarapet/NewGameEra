extends Node3D
class_name Placeble
@export var cost: int
@export var raycasts: Array[RayCast3D]
@export var meshes: Array[MeshInstance3D]
@export var area: Area3D
@onready var green_mat=preload("res://Prefabs/placement_green.tres")
@onready var red_mat=preload("res://Prefabs/placement_red.tres")
@onready var outline=preload("res://Prefabs/outline.tres")
var already_placed=false
var mouse_in=false
var founded=false
var npc=null
func _ready() -> void:
	area.emit_signal("mouse_entered")
	area.emit_signal("mouse_exited")
	area.connect("mouse_entered",Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited",Callable(self, "_on_mouse_exited"))

func _unhandled_input(event: InputEvent) -> void:
	if Globals.prepare_stage and not Globals.placing:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in and already_placed:
			Globals.money+=cost
			queue_free()
			
	else:
		if (event.is_action_pressed("left_click") or event.is_action_pressed("right_click")) and mouse_in:
			pass
func placed() ->void:
	Globals.money-=cost
	mouse_in=false
	for mesh in meshes:
		mesh.material_override=null
		if mouse_in:
			mesh.material_overlay=outline
	for ray in raycasts:
		ray.queue_free()
	already_placed=true
func check_placement() -> bool:
	if Globals.money<cost:
		placement_red()
		return false
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false
	if area.get_overlapping_bodies() or area.get_overlapping_areas():
		placement_red()
		return false
	placement_green()
	return true
func placement_red() -> void:
	for mesh in meshes:
		mesh.material_override=red_mat
func placement_green() -> void:
	for mesh in meshes:
		mesh.material_override=green_mat
func _on_mouse_entered():
	mouse_in=true
	if already_placed and not Globals.placing:
		for mesh in meshes:
			mesh.material_overlay=outline
func _on_mouse_exited():
	mouse_in=false
	if already_placed and not Globals.placing:
		for mesh in meshes:
			mesh.material_overlay=null
func remember_me(who):
	founded=true
	npc=who
