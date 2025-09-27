extends Node

var GAME = load("res://game/game.tscn")
@onready var label: Label = $Label

var gamePoints = 0

func _ready():
	print("GAME is valid?", GAME is PackedScene)
	$"retry button".pressed.connect(_on_button_button_down)
	print("connected the button press")
	label.text = "You finished the game with " + str(gamePoints) + " points!\n＼（〇_ｏ）／"


func _on_button_button_down() -> void:
	print("reloaded game scene")
	get_tree().change_scene_to_packed(GAME)
