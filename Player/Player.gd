extends KinematicBody2D

const ACCELERATION := 500
const FRICTION := ACCELERATION

export var moving_speed := 60
export var rolling_speed := 85

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var sword_hitbox = $SwordPivot/HitBox
onready var hurtbox = $HurtBox
onready var blink_animation_player := $BlinkAnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")

enum State { Move, Attack, Roll }

var stats = PlayerStats
var state = State.Move
var velocity := Vector2.ZERO
var roll_vector = Vector2.DOWN

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.attack_vector = Vector2.DOWN

func _process(delta):
	match state:
		State.Move:
			move_state(delta)
		State.Attack:
			attack_state()
		State.Roll:
			roll_state()

func set_animation_position(input):
	animation_tree.set("parameters/Idle/blend_position", input)
	animation_tree.set("parameters/Roll/blend_position", input)
	animation_tree.set("parameters/Run/blend_position", input)
	animation_tree.set("parameters/Attack/blend_position", input)

func move():
	velocity = move_and_slide(velocity, Vector2.UP)

func move_state(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	if input != Vector2.ZERO:
		sword_hitbox.attack_vector = input
		roll_vector = input
		set_animation_position(input)
		animation_state.travel("Run")

		velocity = velocity.move_toward(input * moving_speed, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")

		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("roll"):
		state = State.Roll
	
	if Input.is_action_just_pressed("attack"):
		state = State.Attack

func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func roll_state():
	velocity = roll_vector * rolling_speed
	animation_state.travel("Roll")
	
	move()

func attack_animation_finished():
	velocity = Vector2.ZERO
	state = State.Move

func roll_animation_finished():
	velocity -= velocity / 2
	state = State.Move

func _on_HurtBox_area_entered(area: Area2D):
	if !hurtbox.invincible:
		stats.health -= area.damage
		hurtbox.start_invincibility(0.8)
		hurtbox.create_hit_effect()

func _on_HurtBox_start_invincibility():
	blink_animation_player.play("Start")

func _on_HurtBox_stop_invincibility():
	blink_animation_player.play("Stop")
