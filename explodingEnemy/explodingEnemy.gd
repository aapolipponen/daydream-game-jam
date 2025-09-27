extends CharacterBody2D
class_name ExplodingEnemy

# refrences to other nodes
@onready var deathTimer: Timer = $deathTimer
@onready var modulationRedTimer: Timer = $modulationRedTimer
@onready var modulationDefaultTimer: Timer = $modulationDefaultTimer
var player: Player
@onready var explosionCollision: CollisionShape2D = $explostionArea/explosionCollision
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

# movement vars
@export var moveSpeed = 10


# variables to do with the size and eventual explosion
var size = 0.5
@export var whenExplodes: float = 5
var exploding: bool = false
@export var sizeIncreaseOnHit = 0.5


# modulation vars
var defaultModulate
var deathModulate = Color(0.686, 0.0, 0.0, 1.0)

func _ready() -> void:
	# get player refrence
	player = get_tree().get_first_node_in_group("player")
	
	# set modulation to the default
	defaultModulate = modulate

# call when the entity is hit
func onHit():
	size += sizeIncreaseOnHit


func _process(_delta: float) -> void:
	if exploding == false:
		if size >= whenExplodes:
			explode()
	
	if exploding == true:
		velocity.x = 0
		velocity.y = 0
	
	scale.x = size
	scale.y = size
	
	scale = clamp(scale, Vector2(0, 0), Vector2(whenExplodes, whenExplodes))
	

func _physics_process(_delta: float) -> void:
	# Try to find the player if we didn't get it earlier or it got freed
	if player == null or not is_instance_valid(player):
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0] as Node2D  # or 'as Player' if you have that class
		else:
			return # no player found yet

	# Compute vector from this enemy to the player (difference)
	var to_player = player.global_position - global_position
	if to_player.length() > 0.001:
		var direction = to_player.normalized()
		velocity = direction * moveSpeed   # for CharacterBody2D, set velocity and call move_and_slide()
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func explode():
	exploding = true
	
	modulate = deathModulate
	modulationRedTimer.start()
	
	deathTimer.start()
	


func _on_death_timer_timeout() -> void:
	explosionCollision.disabled = false
	cpu_particles_2d.emitting = true
	var scoreLabel = get_tree().get_first_node_in_group("scoreLabel")
	scoreLabel.textInt += 1
	queue_free()


func _on_modulation_red_timer_timeout() -> void:
	modulate = defaultModulate
	modulationDefaultTimer.start()
	


func _on_modulation_default_timer_timeout() -> void:
	modulate = deathModulate
	modulationRedTimer.start()





func _on_explostion_area_body_entered(body: Node2D) -> void:
	print("_on_explostion_area_body_entered")
