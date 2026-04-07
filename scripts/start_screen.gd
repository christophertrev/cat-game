extends CanvasLayer

signal start_pressed

func _ready() -> void:
	show()

func _on_start_pressed() -> void:
	start_pressed.emit()
	hide()
