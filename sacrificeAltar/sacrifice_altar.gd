extends Area2D

@onready var sacrificeparticles: CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("sacrifisable"):
		sacrifice(body)

func sacrifice(objectToSacrifice):
	objectToSacrifice.queue_free()
	sacrificeparticles.emitting = true
