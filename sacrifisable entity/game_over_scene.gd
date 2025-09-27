extends Node

var GAME = load("res://game/game.tscn")

func _ready():
	print("GAME is valid?", GAME is PackedScene)
	$"retry button".pressed.connect(_on_button_button_down)
	print("connected the button press")

func _on_button_button_down() -> void:
	print("reloaded game scene")
	get_tree().change_scene_to_packed(GAME)
