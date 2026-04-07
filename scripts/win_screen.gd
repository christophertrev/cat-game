extends CanvasLayer

signal restart_pressed

func _ready() -> void:
	hide()

func show_win() -> void:
	show()

func _on_restart_pressed() -> void:
	restart_pressed.emit()
