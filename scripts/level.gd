extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen

var game_over: bool = false

func _ready() -> void:
	win_screen.restart_pressed.connect(_on_restart_pressed)

func _process(_delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("p1_action") or Input.is_action_just_pressed("p2_action"):
			_on_restart_pressed()
		return

	var flies = get_tree().get_nodes_in_group("flies")
	if flies.size() == 0:
		game_over = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		win_screen.show_win()

func _on_restart_pressed() -> void:
	game_over = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
