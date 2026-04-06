extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen

var game_over: bool = false

func _ready() -> void:
	win_screen.hide()

func _process(_delta: float) -> void:
	if game_over:
		# Allow restart with Enter or Space when win screen is showing
		if Input.is_action_just_pressed("p1_action") or Input.is_action_just_pressed("p2_action"):
			restart()
		return

	var flies = get_tree().get_nodes_in_group("flies")
	if flies.size() == 0:
		game_over = true
		win_screen.show()
		# Release mouse focus so the button is clickable
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_pressed() -> void:
	restart()

func restart() -> void:
	game_over = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
