extends RigidBody2D

var is_shot: bool = false

func shoot(direction: Vector2, force: float, lifetime: float) -> void:
	if is_shot:
		return
	is_shot = true
	# Apply an instantaneous impulse in the desired direction
	apply_impulse(direction.normalized() * force)
	# Schedule this triangle for deletion after its lifetime
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	print("Collided")
	body.onHit()
