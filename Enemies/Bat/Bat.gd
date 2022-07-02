extends KinematicBody2D

export var knockback_strength = 100

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

func _on_HurtBox_area_entered(area):
	knockback = area.attack_vector * knockback_strength
