extends KinematicBody2D

const ACCELERATION := 500
const FRICTION := ACCELERATION

export var moving_speed := 50
export var rolling_speed := 80

enum State { Move, Attack, Roll }

var state = State.Move
var velocity := Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var sword_hitbox = $SwordPivot/HitBox
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true
	sword_hitbox.attack_vector = Vector2.DOWN

func _process(delta):
	match state:
		State.Move:
			move_state(delta)
		State.Attack:
			attack_state(delta)
		State.Roll:
			roll_state(delta)

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

		velocity = velocity.move_toward(input * rolling_speed, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")

		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("roll"):
		state = State.Roll
	
	if Input.is_action_just_pressed("attack"):
		state = State.Attack

func move():
	velocity = move_and_slide(velocity, Vector2.UP)

func set_animation_position(input):
	animation_tree.set("parameters/Idle/blend_position", input)
	animation_tree.set("parameters/Roll/blend_position", input)
	animation_tree.set("parameters/Run/blend_position", input)
	animation_tree.set("parameters/Attack/blend_position", input)

func attack_state(_delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func roll_state(_delta):
	velocity = roll_vector * rolling_speed
	animation_state.travel("Roll")
	
	move()

func attack_animation_finished():
	velocity = Vector2.ZERO
	state = State.Move

func roll_animation_finished():
	velocity -= velocity / 2
	state = State.Move
