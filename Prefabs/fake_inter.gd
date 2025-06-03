extends Interactive


func _on_timer_timeout() -> void:
	$"../..".update_targets($".",-1)
