extends CharacterBody2D
class_name Player

@onready var enemy_spawner_manager: Node = $"../enemySpawnerManager"
@onready var triangle_manager: Node = $TriangleManager
const GAME_OVER_SCENE = preload("uid://cuvqcrafju4nu")

@export var speed = 500
@export var mass := 0.03
var target = position

var scoreLabel
var points

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var desired_velocity = input_direction * speed
	velocity = velocity.move_toward(desired_velocity, speed * mass)
	target = get_global_mouse_position()

func _ready() -> void:
	scoreLabel = get_tree().get_first_node_in_group("gameui").get_child(0)


func _process(delta: float) -> void:
	points = int(scoreLabel.text)
	print(points)


func _physics_process(_delta):
	get_input()
	move_and_slide()

func endGame():
	var gameOverScene = GAME_OVER_SCENE.instantiate()
	gameOverScene.gamePoints = points  # pass the actual number
	print(points)

	var old_scene = get_tree().current_scene
	get_tree().root.add_child(gameOverScene)
	get_tree().current_scene = gameOverScene
	if old_scene:
		old_scene.queue_free()
