extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen
@onready var start_screen: CanvasLayer = $StartScreen

var game_over: bool = false
var game_started: bool = false

func _ready() -> void:
	win_screen.restart_pressed.connect(_on_restart_pressed)
	start_screen.start_pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	game_started = true

func _process(_delta: float) -> void:
	if not game_started:
		return

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
