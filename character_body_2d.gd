extends CharacterBody2D

@export var speed = 400
var target = position

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	target = get_global_mouse_position()

func _physics_process(delta):
	get_input()
	move_and_slide()
