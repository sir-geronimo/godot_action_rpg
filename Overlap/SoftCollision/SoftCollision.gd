extends Area2D

var push_vector := Vector2.ZERO
var overlapping_areas := []
var is_colliding := false

func _process(_delta):
	overlapping_areas = get_overlapping_areas()
	is_colliding = overlapping_areas.size() > 0

func get_push_vector():
	if is_colliding:
		var area: Area2D = overlapping_areas[0]
		push_vector = area.global_position.direction_to(global_position)

	return push_vector
