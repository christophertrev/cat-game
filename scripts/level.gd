extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen

func _ready() -> void:
	win_screen.hide()
	check_flies()

func fly_died() -> void:
	check_flies()

func check_flies() -> void:
	# Count remaining flies in the scene
	var flies = get_tree().get_nodes_in_group("flies")
	if flies.size() == 0:
		show_win_screen()

func show_win_screen() -> void:
	win_screen.show()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
