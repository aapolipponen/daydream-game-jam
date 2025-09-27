extends CharacterBody2D

@export var speed = 500
@export var friction := 0.03
var target = position

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var desired_velocity = input_direction * speed
	velocity = velocity.move_toward(desired_velocity, speed * friction)
	target = get_global_mouse_position()

func _physics_process(delta):
	get_input()
	move_and_slide()
