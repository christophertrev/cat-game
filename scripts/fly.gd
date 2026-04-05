extends Area2D

const SPEED: float = 120.0
const WANDER_TIME_MIN: float = 0.5
const WANDER_TIME_MAX: float = 2.0
const FROZEN_DURATION: float = 3.0   # seconds before breaking free

enum State { BUZZING, FROZEN }

var state: State = State.BUZZING
var direction: Vector2 = Vector2.RIGHT
var wander_timer: float = 0.0
var frozen_timer: float = 0.0

func _ready() -> void:
	add_to_group("flies")
	_pick_new_direction()
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	match state:
		State.BUZZING:
			_process_buzzing(delta)
		State.FROZEN:
			_process_frozen(delta)

	queue_redraw()

const FLEE_RADIUS: float = 150.0   # how close before the fly panics
const FLEE_SPEED: float = 200.0    # faster when fleeing

func _process_buzzing(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_direction()

	# Check for nearby cats and flee
	var flee_vector := Vector2.ZERO
	for cat in get_tree().get_nodes_in_group("cats"):
		var to_cat: Vector2 = cat.global_position - global_position
		if to_cat.length() < FLEE_RADIUS:
			# Push away, stronger the closer they are
			flee_vector -= to_cat.normalized() * (FLEE_RADIUS - to_cat.length())

	var move_dir: Vector2
	var move_speed: float
	if flee_vector.length() > 0:
		move_dir = flee_vector.normalized()
		move_speed = FLEE_SPEED
	else:
		move_dir = direction
		move_speed = SPEED

	position += move_dir * move_speed * delta

	# Bounce off screen edges
	var vp = get_viewport_rect()
	if position.x < 32 or position.x > vp.size.x - 32:
		direction.x *= -1
		position.x = clamp(position.x, 32, vp.size.x - 32)
	if position.y < 32 or position.y > vp.size.y - 32:
		direction.y *= -1
		position.y = clamp(position.y, 32, vp.size.y - 32)

func _process_frozen(delta: float) -> void:
	frozen_timer -= delta
	if frozen_timer <= 0.0:
		# Break free — resume buzzing
		state = State.BUZZING
		_pick_new_direction()

func _pick_new_direction() -> void:
	var angle = randf() * TAU
	direction = Vector2(cos(angle), sin(angle))
	wander_timer = randf_range(WANDER_TIME_MIN, WANDER_TIME_MAX)

func freeze() -> void:
	state = State.FROZEN
	frozen_timer = FROZEN_DURATION

func _on_area_entered(area: Area2D) -> void:
	# Hit by a projectile — freeze instead of die
	if area.is_in_group("projectiles"):
		area.queue_free()
		freeze()

func _on_body_entered(body: Node) -> void:
	# Cat touches frozen fly — die
	if body.is_in_group("cats") and state == State.FROZEN:
		die()

func die() -> void:
	var level = get_parent()
	if level.has_method("fly_died"):
		queue_free()
		level.fly_died()
	else:
		queue_free()

func _draw() -> void:
	var body_color := Color(0.15, 0.1, 0.1)

	if state == State.FROZEN:
		# Icy blue tint when frozen, flashes when about to break free
		if frozen_timer > 0.8 or fmod(frozen_timer, 0.3) > 0.15:
			body_color = Color(0.4, 0.7, 1.0)
		else:
			body_color = Color(0.15, 0.1, 0.1)  # flash back to normal color

	# Body
	draw_circle(Vector2.ZERO, 8, body_color)

	# Wings (don't draw when frozen — they're stuck)
	if state == State.BUZZING:
		draw_wing(Vector2(-10, -6), Vector2(8, 4), Color(0.8, 0.9, 1.0, 0.6))
		draw_wing(Vector2(10, -6), Vector2(8, 4), Color(0.8, 0.9, 1.0, 0.6))

	# Eyes
	draw_circle(Vector2(-3, -3), 2, Color(0.9, 0.1, 0.1))
	draw_circle(Vector2(3, -3), 2, Color(0.9, 0.1, 0.1))

# Draw a wing shape using a polygon approximating an ellipse
func draw_wing(center: Vector2, size: Vector2, color: Color) -> void:
	var points = PackedVector2Array()
	var num_points = 12
	for i in range(num_points):
		var angle = (float(i) / num_points) * TAU
		points.append(center + Vector2(cos(angle) * size.x, sin(angle) * size.y))
	draw_colored_polygon(points, color)
