extends Area2D

const HitEffect = preload("res://Effects/HitEffect/HitEffect.tscn")

export (bool) var show_hit = true

func _on_HurtBox_area_entered(area):
	if show_hit:
		var world = get_tree().current_scene
		var hit_effect = HitEffect.instance()
		
		hit_effect.global_position = global_position
		
		world.add_child(hit_effect)
