extends Node2D

const CAMERA_PADDING := 72.0
const TURN_NOISE := 1.15
const FLOAT_STRENGTH := 3.0

@export var camera_path: NodePath
@export_range(0, 90, 1) var firefly_count := 34
@export var min_speed := 4.0
@export var max_speed := 14.0
@export var min_radius := 0.55
@export var max_radius := 1.15
@export var glow_multiplier := 6.5

class Firefly:
	var global_position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var angle := 0.0
	var speed := 0.0
	var radius := 1.0
	var pulse_offset := 0.0
	var pulse_speed := 1.0
	var alpha := 1.0

var camera: Camera2D
var fireflies: Array[Firefly] = []
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	z_index = 60
	z_as_relative = false
	rng.randomize()
	_use_additive_unshaded_material()
	_resolve_camera()
	_spawn_fireflies()


func _process(delta: float) -> void:
	if fireflies.is_empty():
		_spawn_fireflies()
		return

	var bounds := _get_camera_bounds()
	var now := Time.get_ticks_msec() * 0.001

	for firefly in fireflies:
		firefly.angle += rng.randf_range(-TURN_NOISE, TURN_NOISE) * delta
		var target_velocity := Vector2.RIGHT.rotated(firefly.angle) * firefly.speed
		firefly.velocity = firefly.velocity.lerp(target_velocity, delta * 1.6)
		firefly.global_position += firefly.velocity * delta
		firefly.global_position.y += sin(now * firefly.pulse_speed + firefly.pulse_offset) * FLOAT_STRENGTH * delta
		_wrap_firefly(firefly, bounds)

	queue_redraw()


func _draw() -> void:
	var now := Time.get_ticks_msec() * 0.001

	for firefly in fireflies:
		var local_position := to_local(firefly.global_position)
		var pulse := 0.42 + ((sin(now * firefly.pulse_speed + firefly.pulse_offset) + 1.0) * 0.29)
		var alpha := firefly.alpha * pulse
		var glow_radius := firefly.radius * glow_multiplier

		draw_circle(local_position, glow_radius * 1.35, Color(1.0, 0.56, 0.12, alpha * 0.09))
		draw_circle(local_position, glow_radius * 0.7, Color(1.0, 0.78, 0.22, alpha * 0.20))
		draw_circle(local_position, firefly.radius, Color(1.0, 0.97, 0.58, alpha))


func _use_additive_unshaded_material() -> void:
	var firefly_material := CanvasItemMaterial.new()
	firefly_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	firefly_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = firefly_material


func _resolve_camera() -> void:
	if String(camera_path) != "":
		camera = get_node_or_null(camera_path) as Camera2D

	if camera == null:
		camera = get_viewport().get_camera_2d()


func _spawn_fireflies() -> void:
	fireflies.clear()
	var bounds := _get_camera_bounds()

	for _index in range(firefly_count):
		var firefly := Firefly.new()
		firefly.global_position = bounds.position + Vector2(
			rng.randf_range(0.0, bounds.size.x),
			rng.randf_range(0.0, bounds.size.y)
		)
		firefly.angle = rng.randf_range(0.0, TAU)
		firefly.speed = rng.randf_range(min_speed, max_speed)
		firefly.velocity = Vector2.RIGHT.rotated(firefly.angle) * firefly.speed
		firefly.radius = rng.randf_range(min_radius, max_radius)
		firefly.pulse_offset = rng.randf_range(0.0, TAU)
		firefly.pulse_speed = rng.randf_range(1.0, 2.7)
		firefly.alpha = rng.randf_range(0.45, 0.95)
		fireflies.append(firefly)


func _get_camera_bounds() -> Rect2:
	if camera == null or not is_instance_valid(camera):
		_resolve_camera()

	var center := global_position
	var viewport_size := get_viewport_rect().size
	var zoom := Vector2.ONE

	if camera != null:
		center = camera.global_position
		zoom = camera.zoom

	var view_size := Vector2(
		viewport_size.x / maxf(zoom.x, 0.001),
		viewport_size.y / maxf(zoom.y, 0.001)
	)
	var padding := Vector2.ONE * CAMERA_PADDING
	return Rect2(center - (view_size * 0.5) - padding, view_size + (padding * 2.0))


func _wrap_firefly(firefly: Firefly, bounds: Rect2) -> void:
	if firefly.global_position.x < bounds.position.x:
		firefly.global_position.x = bounds.end.x
	elif firefly.global_position.x > bounds.end.x:
		firefly.global_position.x = bounds.position.x

	if firefly.global_position.y < bounds.position.y:
		firefly.global_position.y = bounds.end.y
	elif firefly.global_position.y > bounds.end.y:
		firefly.global_position.y = bounds.position.y
