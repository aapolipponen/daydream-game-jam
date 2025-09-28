extends CharacterBody2D
class_name Player

@onready var enemy_spawner_manager: Node = $"../enemySpawnerManager"
@onready var triangle_manager: Node = $TriangleManager
const GAME_OVER_SCENE = preload("uid://cuvqcrafju4nu")

@export var speed = 500
@export var mass := 0.03
@export var damage_cooldown: float = 0.5  # seconds between taking damage
var target = position

# Internal timer tracking remaining invulnerability after taking damage
var _damage_timer: float = 0.0

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
	# Handle damage cooldown timer
	if _damage_timer > 0.0:
		_damage_timer -= delta
		if _damage_timer < 0.0:
			_damage_timer = 0.0

	points = int(scoreLabel.text)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("explodingEnemy"):
			if _damage_timer == 0.0:
				var newTriangleCount = triangle_manager.triangle_count - 15
				triangle_manager.set_triangle_count(newTriangleCount)
				_damage_timer = damage_cooldown
				if triangle_manager.has_method("trigger_damage_effect"):
					triangle_manager.trigger_damage_effect()

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
