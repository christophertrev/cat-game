extends Control

var selected: int = 0

@onready var cards: Array[Control] = [$HBox/ZukoCard, $HBox/TophCard]

func _ready() -> void:
	_update_highlight()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("p1_left"):
		selected = 0
		_update_highlight()
	elif Input.is_action_just_pressed("p1_right"):
		selected = 1
		_update_highlight()
	if Input.is_action_just_pressed("p1_action"):
		_confirm()

func _update_highlight() -> void:
	for i in cards.size():
		cards[i].modulate = Color.WHITE if i == selected else Color(0.35, 0.35, 0.35)

func _confirm() -> void:
	GameState.character = "zuko" if selected == 0 else "toph"
	get_tree().change_scene_to_file("res://scenes/level_test.tscn")
