extends Node

@export var triangle_count: int = 100
@export var follow_distance: float = 100.0
@export var follow_speed: float = 200.0
@export var follow_smoothing: float = 10000.0
@export var repulsion_distance: float = 100.0
@export var repulsion_strength: float = 50000.0
@export var repulsion_power: float = 2.0  # 1 = linear, 2 = quadratic, etc.
@export var shoot_force: float = 1000.0
@export var shot_lifetime: float = 1.5

var triangle_scene: PackedScene = preload("res://Triangle/triangle.tscn")
var triangles: Array = []
var player: Node2D = null
var highlighted: RigidBody2D = null
var camera: Camera2D = null

func _ready() -> void:
	# Get player reference once
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("No player found in 'player' group!")
		return
	
	# Get camera reference
	camera = get_viewport().get_camera_2d()
	
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
		if triangle.has_meta("shot") and triangle.get_meta("shot"):
			continue  # ignore shot triangles

		var distance: float = player.global_position.distance_to(triangle.global_position)
		var direction: Vector2 = (player.global_position - triangle.global_position).normalized()

		# Determine desired velocity based on distance
		var target_velocity: Vector2 = Vector2.ZERO

		# 1. Non-linear repulsion when too close
		if distance < repulsion_distance:
			var ratio: float = 1.0 - distance / repulsion_distance  # 0 at boundary, 1 at distance 0
			var strength: float = repulsion_strength * pow(ratio, repulsion_power)
			target_velocity = -direction * strength
		# 2. Otherwise follow if far enough
		elif distance > follow_distance:
			target_velocity = direction * follow_speed

		# Retrieve and smoothly interpolate current velocity
		var vel: Vector2 = triangle.get_meta("vel") if triangle.has_meta("vel") else Vector2.ZERO
		vel = vel.move_toward(target_velocity, follow_smoothing * delta)

		# Persist and apply velocity
		triangle.set_meta("vel", vel)
		triangle.linear_velocity = vel

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	update_triangle_following(delta)
	update_highlight()

func update_highlight() -> void:
	var mouse_world: Vector2 = _get_mouse_world_pos()
	var closest: RigidBody2D = null
	var best_dist: float = INF
	for t in triangles:
		if not is_instance_valid(t):
			continue
		if t.has_meta("shot") and t.get_meta("shot"):
			continue
		var d = t.global_position.distance_to(mouse_world)
		if d < best_dist:
			best_dist = d
			closest = t
	if closest == highlighted:
		return  # nothing changed
	# Clear previous highlight
	if is_instance_valid(highlighted) and highlighted.has_method("set_highlight"):
		highlighted.set_highlight(false)
	highlighted = closest
	if is_instance_valid(highlighted) and highlighted.has_method("set_highlight"):
		highlighted.set_highlight(true)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_highlighted_triangle()

func _get_mouse_world_pos() -> Vector2:
	var screen_pos: Vector2 = get_viewport().get_mouse_position()
	var xform := get_viewport().get_canvas_transform()
	return xform.affine_inverse() * screen_pos

func shoot_highlighted_triangle() -> void:
	if highlighted == null or not is_instance_valid(highlighted):
		return
	var mouse_world := _get_mouse_world_pos()
	# Mark, shoot and clear highlight
	highlighted.set_meta("shot", true)
	if highlighted.has_method("set_highlight"):
		highlighted.set_highlight(false)
	var dir := (mouse_world - highlighted.global_position).normalized()
	highlighted.call_deferred("shoot", dir, shoot_force, shot_lifetime)
	highlighted = null
