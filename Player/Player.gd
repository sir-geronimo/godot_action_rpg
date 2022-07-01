extends KinematicBody2D

const ACCELERATION = 500
const FRICTION = ACCELERATION

export var horizontal_speed = 50

enum State { Move, Attack, Roll }

var velocity = Vector2.ZERO
var state = State.Move

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true

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
		set_animation_position(input)

		animation_state.travel("Run")

		velocity = velocity.move_toward(input * horizontal_speed, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("attack"):
		state = State.Attack
	
func set_animation_position(input):
	animation_tree.set("parameters/Idle/blend_position", input)
	animation_tree.set("parameters/Run/blend_position", input)
	animation_tree.set("parameters/Attack/blend_position", input)

func attack_state(_delta):
	animation_state.travel("Attack")
	
func attack_animation_finished():
	state = State.Move

func roll_state(_delta):
	pass
