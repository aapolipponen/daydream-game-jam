extends Node2D

const explodingEnemy = preload("uid://b47uj5no11yrh")

func _ready() -> void:
	if randi_range(1, 10) >= 5:
		var enemy = explodingEnemy.instantiate()
		add_child(enemy)
