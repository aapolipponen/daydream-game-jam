extends CharacterBody2D
class_name Player

@onready var enemy_spawner_manager: Node = get_node_or_null("../enemySpawnerManager")
@onready var triangle_manager: Node = get_node_or_null("TriangleManager")
const GAME_OVER_SCENE = preload("uid://cuvqcrafju4nu")
@onready var damage_flash_timer: Timer = get_node_or_null("damageFlashTimer")
@onready var take_damage_sfx: AudioStreamPlayer2D = get_node_or_null("takeDamageSFX")
@onready var game_ui: Node = get_tree().get_first_node_in_group("gameui")

@export var speed = 500
@export var mass := 0.03
@export var damage_cooldown: float = 0.5  # seconds between taking damage
var target = position

var damageModulate = Color(0.63, 0.0, 0.0, 1.0)
var defaultModulate

var ui

# Internal timer tracking remaining invulnerability after taking damage
var _damage_timer: float = 0.0

var scoreLabel
var points
var _parent_canvas: CanvasItem = null

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var desired_velocity = input_direction * speed
	velocity = velocity.move_toward(desired_velocity, speed * mass)
	target = get_global_mouse_position()

func _ready() -> void:
	# Optional UI setup (stand-alone scene may not have it)
	if game_ui:
		scoreLabel = game_ui.get_child(0) if game_ui.get_child_count() > 0 else null
		if scoreLabel == null:
			push_warning("'gameui' node has no first child for score label")
	else:
		push_warning("No node in group 'gameui' found – running with minimal UI")

	# Cache parent canvas for damage flash, only if it supports modulate
	var p = get_parent()
	if p is CanvasItem:
		_parent_canvas = p
		defaultModulate = _parent_canvas.modulate
	else:
		defaultModulate = Color(1,1,1)

func _process(delta: float) -> void:
	# Handle damage cooldown timer
	if _damage_timer > 0.0:
		_damage_timer -= delta
		if _damage_timer < 0.0:
			_damage_timer = 0.0

	if scoreLabel:
		points = int(scoreLabel.text)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("explodingEnemy"):
			if _damage_timer == 0.0:
				if triangle_manager:
					var newTriangleCount = triangle_manager.triangle_count - 15
					triangle_manager.set_triangle_count(newTriangleCount)
					if _parent_canvas:
						_parent_canvas.modulate = damageModulate
				if game_ui:
					game_ui.get_child(1).visible = true
			if take_damage_sfx:
				take_damage_sfx.play()
			if damage_flash_timer:
				damage_flash_timer.start()
				_damage_timer = damage_cooldown
				if triangle_manager and triangle_manager.has_method("trigger_damage_effect"):
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


func _on_damage_flash_timer_timeout() -> void:
	if _parent_canvas:
		_parent_canvas.modulate = defaultModulate
	if game_ui and game_ui.get_child_count() > 1:
		game_ui.get_child(1).visible = false
