extends Node

@export var triangle_count: int = 10
@export var follow_distance: float = 100.0
@export var follow_speed: float = 100.0
@export var follow_smoothing: float = 100.0

var triangle_scene: PackedScene = preload("res://Triangle/triangle.tscn")
var triangles: Array = []
var player: Node2D = null

func _ready() -> void:
	# Get player reference once
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("No player found in 'player' group!")
		return
	
	
	spawn_triangles(triangle_count)


func set_triangle_count(new_count: int) -> void:
	if new_count == triangle_count:
		return
	triangle_count = new_count
	update_triangles()

func spawn_triangles(count: int) -> void:
	for t in triangles:
		if is_instance_valid(t):
			t.queue_free()
	triangles.clear()
	for i in range(count):
		var triangle = triangle_scene.instantiate()
		add_child(triangle)
		triangle.position = Vector2(50 * i, 0)
		
		triangles.append(triangle)

func update_triangles() -> void:
	var current = triangles.size()
	if triangle_count > current:
		for i in range(triangle_count - current):
			var triangle = triangle_scene.instantiate()
			add_child(triangle)
			triangle.position = Vector2(50 * (current + i), 0)
			
			triangles.append(triangle)
	elif triangle_count < current:
		for i in range(current - triangle_count):
			var triangle = triangles.pop_back()
			if is_instance_valid(triangle):
				triangle.queue_free()

func update_triangle_following(delta: float) -> void:
	for triangle in triangles:
		if not is_instance_valid(triangle):
			continue
		
		var distance_to_player = player.global_position.distance_to(triangle.global_position)
		
		# Only follow if beyond the follow distance
		if distance_to_player > follow_distance:
			var direction = (player.global_position - triangle.global_position).normalized()

			# Retrieve current velocity stored in metadata (default to zero)
			var vel: Vector2 = triangle.get_meta("vel") if triangle.has_meta("vel") else Vector2.ZERO

			# Compute target velocity toward the player
			var target_velocity: Vector2 = direction * follow_speed

			# Smoothly interpolate velocity
			vel = vel.move_toward(target_velocity, follow_smoothing * delta)

			# Store updated velocity
			triangle.set_meta("vel", vel)

			# Move triangle manually (Area2D has no built-in physics movement)
			triangle.position += vel * delta

		else:
			# Gradually slow down when within follow distance
			var vel: Vector2 = triangle.get_meta("vel") if triangle.has_meta("vel") else Vector2.ZERO
			vel = vel.move_toward(Vector2.ZERO, follow_smoothing * delta)
			triangle.set_meta("vel", vel)
			triangle.position += vel * delta

	# --- Helper to make triangles avoid overlapping with each other ---
const SEPARATION_DISTANCE: float = 200.0
const SEPARATION_FORCE: float = 2000.0

func _apply_separation(delta: float) -> void:
	for i in range(triangles.size()):
		var a: Node2D = triangles[i]
		if not is_instance_valid(a):
			continue
		var a_vel: Vector2 = a.get_meta("vel") if a.has_meta("vel") else Vector2.ZERO
		for j in range(i + 1, triangles.size()):
			var b: Node2D = triangles[j]
			if not is_instance_valid(b):
				continue
			var diff: Vector2 = a.global_position - b.global_position
			var dist_sq: float = diff.length_squared()
			if dist_sq == 0 or dist_sq > SEPARATION_DISTANCE * SEPARATION_DISTANCE:
				continue
			var dir: Vector2 = diff.normalized()
			var push: Vector2 = dir * SEPARATION_FORCE * delta / max(dist_sq, 1)
			a_vel += push
			var b_vel: Vector2 = b.get_meta("vel") if b.has_meta("vel") else Vector2.ZERO
			b_vel -= push
			a.set_meta("vel", a_vel)
			b.set_meta("vel", b_vel)

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	update_triangle_following(delta)
	_apply_separation(delta)
