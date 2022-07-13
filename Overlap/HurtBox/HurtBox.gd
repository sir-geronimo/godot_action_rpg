extends Area2D

const HitEffect = preload("res://Effects/HitEffect/HitEffect.tscn")

signal start_invincibility
signal stop_invincibility

onready var timer = $Timer

var invincible = false

func start_invincibility(duration):
	self.invincible = true
	set_deferred("monitoring", false)
	emit_signal('start_invincibility')

	timer.start(duration)

func create_hit_effect():
	var world = get_tree().current_scene
	var hit_effect = HitEffect.instance()
	
	hit_effect.global_position = global_position

	world.add_child(hit_effect)

func _on_Timer_timeout():
	self.invincible = false
	monitoring = true
	emit_signal('stop_invincibility')
