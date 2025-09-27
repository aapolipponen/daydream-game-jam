extends CharacterBody2D
class_name Player

@onready var enemy_spawner_manager: Node = $"../enemySpawnerManager"
@onready var triangle_manager: Node = $TriangleManager

@export var speed = 500
@export var mass := 0.03
var target = position

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var desired_velocity = input_direction * speed
	velocity = velocity.move_toward(desired_velocity, speed * mass)
	target = get_global_mouse_position()

func _process(delta: float) -> void:
	pass


func _physics_process(_delta):
	get_input()
	move_and_slide()
