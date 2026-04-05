extends Area2D

const SPEED: float = 400.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("projectiles")
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_screen_exited() -> void:
	queue_free()
