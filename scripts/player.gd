extends CharacterBody2D

@export var player_id: int = 1
@export var body_color: Color = Color(0.1, 0.1, 0.1)  # black cat

const SPEED: float = 200.0
const SHOOT_COOLDOWN: float = 0.3

var facing: Vector2 = Vector2.UP
var shoot_timer: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

@onready var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

func _ready() -> void:
	add_to_group("cats")

func _physics_process(delta: float) -> void:
	shoot_timer -= delta

	var direction := Vector2(
		Input.get_axis("p%d_left" % player_id, "p%d_right" % player_id),
		Input.get_axis("p%d_up" % player_id, "p%d_down" % player_id)
	).normalized()

	velocity = direction * SPEED
	move_and_slide()

	if direction != Vector2.ZERO:
		var old_facing = facing
		facing = direction
		if facing != old_facing:
			sprite.rotation = facing.angle() + (PI/2)

	if Input.is_action_just_pressed("p%d_action" % player_id) and shoot_timer <= 0.0:
		shoot()
		shoot_timer = SHOOT_COOLDOWN

func shoot() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.direction = facing
	projectile.position = global_position
	get_parent().add_child(projectile)

func ___draw() -> void:
	var f := facing.normalized()
	var perp := Vector2(-f.y, f.x)  # perpendicular to facing

	# --- Body ---
	draw_circle(Vector2.ZERO, 14, body_color)

	# --- Head --- (offset in facing direction)
	var head_center := f * 14
	draw_circle(head_center, 10, body_color)

	# --- Ears --- (triangles on top of head, angled outward)
	var ear_size := 7.0
	for side in [-1, 1]:
		var s := float(side)
		var ear_base_center: Vector2 = head_center + perp * s * 7
		var ear_tip: Vector2 = ear_base_center + f * ear_size + perp * s * 3
		var ear_left: Vector2 = ear_base_center + perp * s * 4
		var ear_right: Vector2 = ear_base_center - perp * s * 2
		draw_colored_polygon(
			PackedVector2Array([ear_left, ear_right, ear_tip]),
			body_color
		)
		# Inner ear — pink
		var inner_tip: Vector2 = ear_base_center + f * (ear_size * 0.6) + perp * s * 2
		var inner_left: Vector2 = ear_base_center + perp * s * 2.5
		var inner_right: Vector2 = ear_base_center - perp * s * 0.5
		draw_colored_polygon(
			PackedVector2Array([inner_left, inner_right, inner_tip]),
			Color(1.0, 0.6, 0.7)
		)

	# --- Eyes ---
	var eye_offset := 4.0
	var eye_pos_l := head_center + perp * eye_offset + f * 2
	var eye_pos_r := head_center - perp * eye_offset + f * 2
	draw_circle(eye_pos_l, 2.5, Color(0.1, 0.8, 0.1))  # green eyes
	draw_circle(eye_pos_r, 2.5, Color(0.1, 0.8, 0.1))
	# Pupils
	draw_circle(eye_pos_l, 1.0, Color(0, 0, 0))
	draw_circle(eye_pos_r, 1.0, Color(0, 0, 0))

	# --- Nose ---
	var nose_pos := head_center + f * 8
	draw_circle(nose_pos, 2.0, Color(1.0, 0.5, 0.6))

	# --- Whiskers ---
	var whisker_color := Color(1, 1, 1, 0.8)
	for side in [-1, 1]:
		var s := float(side)
		var base: Vector2 = head_center + perp * s * 3 + f * 5
		for i in range(3):
			var angle_offset := (i - 1) * 0.3
			var whisker_dir: Vector2 = (perp * s).rotated(angle_offset)
			draw_line(base, base + whisker_dir * 12, whisker_color, 0.8)

	# --- Red collar ---
	# Arc around the neck between body and head
	var collar_center := f * 6
	var collar_radius := 10.0
	var arc_start := atan2(-f.x, f.y) - PI * 0.6
	var arc_end := atan2(-f.x, f.y) + PI * 0.6
	var steps := 12
	for i in range(steps):
		var a1 := arc_start + (arc_end - arc_start) * i / steps
		var a2 := arc_start + (arc_end - arc_start) * (i + 1) / steps
		var p1 := collar_center + Vector2(cos(a1), sin(a1)) * collar_radius
		var p2 := collar_center + Vector2(cos(a2), sin(a2)) * collar_radius
		draw_line(p1, p2, Color(0.9, 0.1, 0.1), 3.0)
	# Collar tag — small yellow circle
	var tag_angle := atan2(-f.x, f.y)
	var tag_pos := collar_center + Vector2(cos(tag_angle), sin(tag_angle)) * collar_radius
	draw_circle(tag_pos, 3.0, Color(1.0, 0.85, 0.0))

func colllar_points_add(_arr: PackedVector2Array, _c: Vector2, _r: float, _a: float) -> void:
	pass  # helper stub, actual drawing done inline above
