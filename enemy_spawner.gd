extends Node2D

const explodingEnemy = preload("uid://b47uj5no11yrh")



func _on_spawn_timer_timeout() -> void:
	get_parent().position.x = get_tree().get_first_node_in_group("player").position.x
	get_parent().position.y = get_tree().get_first_node_in_group("player").position.y
	if randi_range(1, 10) >= 5:
		var enemy = explodingEnemy.instantiate()
		add_child(enemy)
