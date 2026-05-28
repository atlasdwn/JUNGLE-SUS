extends Control

const EDGE_PADDING := 12.0
const TURN_NOISE := 1.4
const FLOAT_STRENGTH := 4.0

@export_range(0, 80, 1) var firefly_count := 80
@export var min_speed := 5.0
@export var max_speed := 16.0
@export var min_radius := 0.75
@export var max_radius := 2.00
@export var glow_multiplier := 5.0

class Firefly:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var angle := 0.0
	var speed := 0.0
	var radius := 1.0
	var pulse_offset := 0.0
	var pulse_speed := 1.0
	var alpha := 1.0

var rng := RandomNumberGenerator.new()
var fireflies: Array[Firefly] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	_spawn_fireflies()
	resized.connect(_keep_fireflies_inside)


func _process(delta: float) -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var now := Time.get_ticks_msec() * 0.001

	for firefly in fireflies:
		firefly.angle += rng.randf_range(-TURN_NOISE, TURN_NOISE) * delta
		var target_velocity := Vector2.RIGHT.rotated(firefly.angle) * firefly.speed
		firefly.velocity = firefly.velocity.lerp(target_velocity, delta * 1.8)
		firefly.position += firefly.velocity * delta
		firefly.position.y += sin(now * firefly.pulse_speed + firefly.pulse_offset) * FLOAT_STRENGTH * delta
		_wrap_firefly(firefly)

	queue_redraw()


func _draw() -> void:
	var now := Time.get_ticks_msec() * 0.001

	for firefly in fireflies:
		var pulse := 0.45 + ((sin(now * firefly.pulse_speed + firefly.pulse_offset) + 1.0) * 0.275)
		var alpha := firefly.alpha * pulse
		var glow_radius := firefly.radius * glow_multiplier

		draw_circle(firefly.position, glow_radius, Color(1.0, 0.66, 0.18, alpha * 0.10))
		draw_circle(firefly.position, glow_radius * 0.55, Color(1.0, 0.82, 0.28, alpha * 0.22))
		draw_circle(firefly.position, firefly.radius, Color(1.0, 0.98, 0.62, alpha))


func _spawn_fireflies() -> void:
	fireflies.clear()

	var spawn_size := size
	if spawn_size.x <= 0.0 or spawn_size.y <= 0.0:
		spawn_size = get_viewport_rect().size

	for index in range(firefly_count):
		var firefly := Firefly.new()
		firefly.position = Vector2(
			rng.randf_range(EDGE_PADDING, max(EDGE_PADDING, spawn_size.x - EDGE_PADDING)),
			rng.randf_range(EDGE_PADDING, max(EDGE_PADDING, spawn_size.y - EDGE_PADDING))
		)
		firefly.angle = rng.randf_range(0.0, TAU)
		firefly.speed = rng.randf_range(min_speed, max_speed)
		firefly.velocity = Vector2.RIGHT.rotated(firefly.angle) * firefly.speed
		firefly.radius = rng.randf_range(min_radius, max_radius)
		firefly.pulse_offset = rng.randf_range(0.0, TAU)
		firefly.pulse_speed = rng.randf_range(1.0, 2.4)
		firefly.alpha = rng.randf_range(0.45, 0.95)
		fireflies.append(firefly)


func _wrap_firefly(firefly: Firefly) -> void:
	if firefly.position.x < -EDGE_PADDING:
		firefly.position.x = size.x + EDGE_PADDING
	elif firefly.position.x > size.x + EDGE_PADDING:
		firefly.position.x = -EDGE_PADDING

	if firefly.position.y < -EDGE_PADDING:
		firefly.position.y = size.y + EDGE_PADDING
	elif firefly.position.y > size.y + EDGE_PADDING:
		firefly.position.y = -EDGE_PADDING


func _keep_fireflies_inside() -> void:
	for firefly in fireflies:
		firefly.position.x = clampf(firefly.position.x, 0.0, size.x)
		firefly.position.y = clampf(firefly.position.y, 0.0, size.y)

	queue_redraw()
