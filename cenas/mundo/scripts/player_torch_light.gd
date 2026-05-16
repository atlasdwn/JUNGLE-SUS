extends PointLight2D

@export var target_path: NodePath
@export var follow_offset := Vector2(0.0, -12.0)
@export var base_energy := 0.88
@export var flicker_strength := 0.12
@export var flicker_speed := 5.5
@export var base_texture_scale := 1.05
@export var scale_flicker := 0.05
@export var position_flicker := 0.35

var target: Node2D
var flicker_offset := 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	_resolve_target()
	flicker_offset = rng.randf_range(0.0, TAU)
	energy = base_energy
	texture_scale = base_texture_scale


func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_resolve_target()

	var time := Time.get_ticks_msec() * 0.001 + flicker_offset
	var pulse := sin(time * flicker_speed) * 0.55
	pulse += sin(time * flicker_speed * 1.73) * 0.32
	pulse += sin(time * flicker_speed * 2.41) * 0.13
	pulse = clampf(pulse, -1.0, 1.0)

	energy = maxf(0.0, base_energy + (pulse * flicker_strength))
	texture_scale = base_texture_scale + (pulse * scale_flicker)

	var flicker_position := Vector2(
		sin(time * 2.3),
		cos(time * 2.9)
	) * position_flicker

	if target != null:
		global_position = target.global_position + follow_offset + flicker_position
	else:
		position = follow_offset + flicker_position


func _resolve_target() -> void:
	if String(target_path) == "":
		return

	target = get_node_or_null(target_path) as Node2D

	if target == null and get_parent() != null:
		target = get_parent().get_node_or_null(target_path) as Node2D
