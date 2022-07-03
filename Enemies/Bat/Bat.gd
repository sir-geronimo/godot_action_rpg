extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect/EnemyDeathEffect.tscn")

export var knockback_strength = 100

onready var stats = $Stats

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.attack_vector * knockback_strength


func _on_Stats_no_health():
	queue_free()
	
	var enemy_death_effect = EnemyDeathEffect.instance()
	enemy_death_effect.global_position = global_position
	
	get_parent().add_child(enemy_death_effect)
