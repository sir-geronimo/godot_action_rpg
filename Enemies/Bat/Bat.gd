extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect/EnemyDeathEffect.tscn")
const ACCELERATION := 300
const FRICTION := ACCELERATION

export (float) var speed := 30
export var knockback_strength := 100

onready var stats := $Stats
onready var animated_sprite = $AnimatedSprite
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $HurtBox

enum State { Idle, Wander, Chase }

var state = State.Idle 
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO

func _physics_process(delta):
	match state:
		State.Idle:
			idle_state(delta)
		State.Wander:
			wander_state(delta)
		State.Chase:
			chase_state(delta)

	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	animated_sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		state = State.Chase

func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()

func wander_state(_delta):
	pass

func chase_state(delta):
	var player = player_detection_zone.player
	if !player_detection_zone.can_see_player():
		state = State.Idle
		return

	var player_direction = (player.global_position - global_position).normalized()

	velocity = velocity.move_toward(player_direction * speed, ACCELERATION * delta)

func play_death_animation():	
	var enemy_death_effect = EnemyDeathEffect.instance()
	enemy_death_effect.global_position = global_position
	
	get_parent().add_child(enemy_death_effect)

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.attack_vector * knockback_strength
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()

	play_death_animation()
