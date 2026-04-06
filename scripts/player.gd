extends CharacterBody2D

@export var player_id: int = 1

const SPEED: float = 200.0
const SHOOT_COOLDOWN: float = 0.3

var facing: Vector2 = Vector2.UP
var shoot_timer: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

func _ready() -> void:
	add_to_group("cats")
	anim.play("default")

func _physics_process(delta: float) -> void:
	shoot_timer -= delta

	var direction := Vector2(
		Input.get_axis("p%d_left" % player_id, "p%d_right" % player_id),
		Input.get_axis("p%d_up" % player_id, "p%d_down" % player_id)
	).normalized()

	velocity = direction * SPEED
	move_and_slide()

	if direction != Vector2.ZERO:
		facing = direction
		anim.rotation = facing.angle() + (PI / 2)

	if Input.is_action_just_pressed("p%d_action" % player_id) and shoot_timer <= 0.0:
		shoot()
		shoot_timer = SHOOT_COOLDOWN

func shoot() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.direction = facing
	projectile.position = global_position
	get_parent().add_child(projectile)
