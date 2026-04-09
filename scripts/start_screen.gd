extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("p1_action"):
		_go()

func _on_play_pressed() -> void:
	_go()

func _go() -> void:
	get_tree().change_scene_to_file("res://scenes/char_select.tscn")
