extends CharacterBody2D


# refrences to other nodes
@onready var deathTimer: Timer = $deathTimer
@onready var modulationRedTimer: Timer = $modulationRedTimer
@onready var modulationDefaultTimer: Timer = $modulationDefaultTimer

# variables to do with the size and eventual explosion
var size = 1
@export var whenExplodes: float = 5
var exploding: bool = false
@export var sizeIncreaseOnHit = 0.5


# modulation vars
var defaultModulate
var deathModulate = Color(0.686, 0.0, 0.0, 1.0)

func _ready() -> void:
	defaultModulate = modulate
	


func onHit():
	size += sizeIncreaseOnHit



func _process(_delta: float) -> void:
	if exploding == false:
		if size >= whenExplodes:
			explode()
	
	scale.x = size
	scale.y = size
	
	scale = clamp(scale, Vector2(1, 1), Vector2(whenExplodes, whenExplodes))

func explode():
	exploding = true
	
	modulate = deathModulate
	modulationRedTimer.start()
	print("redtimer started")
	
	deathTimer.start()
	


func _on_death_timer_timeout() -> void:
	queue_free()


func _on_modulation_red_timer_timeout() -> void:
	modulate = defaultModulate
	modulationDefaultTimer.start()
	print("default triggered")
	


func _on_modulation_default_timer_timeout() -> void:
	modulate = deathModulate
	modulationRedTimer.start()
	print("red triggered")
