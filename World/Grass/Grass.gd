extends Node2D

func create_grass_effect():
	var GrassEffect = load("res://Effects/GrassEffect/GrassEffect.tscn")
	var grass_effect = GrassEffect.instance()
	var world = get_tree().get_root()
	
	world.add_child(grass_effect)
	grass_effect.global_position = global_position

func _on_HurtBox_area_entered(_area):
	create_grass_effect()
	queue_free()
