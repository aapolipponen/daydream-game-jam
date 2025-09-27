extends StaticBody2D

@onready var explosion_timer: Timer = $explosionTimer
@onready var explostion_particles: CPUParticles2D = $explostionParticles
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.start()


func explode():
	explosion_timer.start()
	explostion_particles.emitting = true
	sprite_2d.visible = false
	
	


func _on_explosion_timer_timeout() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	explode()
