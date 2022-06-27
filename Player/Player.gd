extends KinematicBody2D

const ACCELERATION = 500
const FRICTION = ACCELERATION

export var horizontal_speed = 50

var velocity = Vector2.ZERO

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	if input != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input)
		animation_tree.set("parameters/Run/blend_position", input)
		animation_state.travel("Run")

		velocity = velocity.move_toward(input * horizontal_speed, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
