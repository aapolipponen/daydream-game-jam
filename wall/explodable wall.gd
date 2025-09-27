extends StaticBody2D

@onready var explosion_timer: Timer = $explosionTimer
@onready var explostion_particles: CPUParticles2D = $explostionParticles
@onready var sprite_2d: Sprite2D = $Sprite2D



func _ready() -> void:
	pass


func explode():
	explosion_timer.start()
	explostion_particles.emitting = true
	sprite_2d.visible = false
	queue_free()
	
func onHit():
	explode()




func _on_timer_timeout() -> void:
	explode()
