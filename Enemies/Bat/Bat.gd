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
onready var soft_collision = $SoftCollision
onready var wander_controller := $WanderController

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
	
	if soft_collision.is_colliding:
		velocity += soft_collision.get_push_vector() * speed * delta
	
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		state = State.Chase

func idle_state(delta):
	seek_player()
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if wander_controller.get_time_left() == 0:
		pick_random_state()

func wander_state(delta):
	seek_player()
	var direction = global_position.direction_to(wander_controller.target_position)
	velocity = velocity.move_toward(direction * speed, ACCELERATION * delta)
	
	if wander_controller.get_time_left() == 0 or global_position.distance_to(wander_controller.target_position) <= 5:
		pick_random_state()
		
func pick_random_state():
	var rand_state = rand_range(0, 2)
	state = [State.Idle, State.Wander][rand_state]
	wander_controller.start_wander_time(rand_range(1, 3))

func chase_state(delta):
	var player = player_detection_zone.player
	if !player_detection_zone.can_see_player():
		state = State.Idle
		return

	var player_direction = global_position.direction_to(player.global_position)

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
