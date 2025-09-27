extends RigidBody2D

var is_shot: bool = false

# Enable contact monitoring so that `body_entered` signal is emitted.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10  # any positive value enables the signal

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
	if body.has_method("onHit"):
		body.onHit()
		queue_free()
