extends CharacterBody2D

@export var player_id: int = 1

const SPEED: float = 200.0
const SHOOT_COOLDOWN: float = 0.3

# Toph pounce
const POUNCE_SPEED: float = 850.0
const POUNCE_DURATION: float = 0.28
const POUNCE_COOLDOWN: float = 0.3
const POUNCE_KILL_RADIUS: float = 50.0
const AIM_LINE_LENGTH: float = 80.0

@export var toph_frames: SpriteFrames

var facing: Vector2 = Vector2.UP
var shoot_timer: float = 0.0
var is_toph: bool = false

enum PounceState { IDLE, CHARGING, POUNCING, COOLDOWN }
var pounce_state: PounceState = PounceState.IDLE
var pounce_timer: float = 0.0
var pounce_direction: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

func _ready() -> void:
	add_to_group("cats")
	is_toph = GameState.character == "toph"
	if is_toph and toph_frames:
		anim.sprite_frames = toph_frames
	anim.play("default")

func _physics_process(delta: float) -> void:
	if is_toph:
		_process_toph(delta)
	else:
		_process_zuko(delta)

# ── Zuko ──────────────────────────────────────────────────────────────────────

func _process_zuko(delta: float) -> void:
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

# ── Toph ──────────────────────────────────────────────────────────────────────

func _process_toph(delta: float) -> void:
	match pounce_state:
		PounceState.IDLE:
			_toph_idle()
		PounceState.CHARGING:
			_toph_charging()
		PounceState.POUNCING:
			_toph_pouncing(delta)
		PounceState.COOLDOWN:
			_toph_cooldown(delta)

func _toph_idle() -> void:
	var dir := _move_input()
	velocity = dir * SPEED
	move_and_slide()
	_update_facing(dir)

	if Input.is_action_just_pressed("p%d_action" % player_id):
		pounce_state = PounceState.CHARGING
		queue_redraw()

func _toph_charging() -> void:
	var dir := _move_input()
	velocity = dir * (SPEED * 0.5)
	move_and_slide()
	_update_facing(dir)
	queue_redraw()

	if Input.is_action_just_released("p%d_action" % player_id):
		pounce_direction = facing
		pounce_timer = POUNCE_DURATION
		pounce_state = PounceState.POUNCING
		queue_redraw()

func _toph_pouncing(delta: float) -> void:
	pounce_timer -= delta
	velocity = pounce_direction * POUNCE_SPEED
	move_and_slide()

	for fly in get_tree().get_nodes_in_group("flies"):
		if global_position.distance_to(fly.global_position) < POUNCE_KILL_RADIUS:
			fly.die()

	if pounce_timer <= 0.0:
		velocity = Vector2.ZERO
		pounce_state = PounceState.COOLDOWN
		pounce_timer = POUNCE_COOLDOWN

func _toph_cooldown(delta: float) -> void:
	pounce_timer -= delta
	var dir := _move_input()
	velocity = dir * SPEED
	move_and_slide()
	_update_facing(dir)

	if pounce_timer <= 0.0:
		pounce_state = PounceState.IDLE

# ── Helpers ───────────────────────────────────────────────────────────────────

func _move_input() -> Vector2:
	return Vector2(
		Input.get_axis("p%d_left" % player_id, "p%d_right" % player_id),
		Input.get_axis("p%d_up" % player_id, "p%d_down" % player_id)
	).normalized()

func _update_facing(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		facing = dir
		anim.rotation = facing.angle() + (PI / 2)

func _draw() -> void:
	if not is_toph or pounce_state != PounceState.CHARGING:
		return
	var tip := facing * AIM_LINE_LENGTH
	var perp := Vector2(-facing.y, facing.x) * 10.0
	draw_line(Vector2.ZERO, tip, Color(1.0, 0.8, 0.2), 3.0)
	draw_line(tip, tip - facing * 15.0 + perp, Color(1.0, 0.8, 0.2), 3.0)
	draw_line(tip, tip - facing * 15.0 - perp, Color(1.0, 0.8, 0.2), 3.0)
