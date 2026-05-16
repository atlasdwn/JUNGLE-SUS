extends PointLight2D

@export var target_path: NodePath
@export var follow_offset := Vector2(0.0, -12.0)
@export var base_energy := 0.88
@export var flicker_strength := 0.12
@export var flicker_speed := 5.5
@export var base_texture_scale := 1.05
@export var scale_flicker := 0.05
@export var position_flicker := 0.35
@export var obstructed_energy := 0.85
@export var obstructed_texture_scale := 0.82
@export var obstruction_transition := 0.25

var target: Node2D
var current_base_energy := 0.0
var current_base_texture_scale := 0.0
var obstruction_count := 0
var obstruction_tween: Tween
var flicker_offset := 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("player_torch")
	rng.randomize()
	_resolve_target()
	flicker_offset = rng.randf_range(0.0, TAU)
	current_base_energy = base_energy
	current_base_texture_scale = base_texture_scale
	energy = current_base_energy
	texture_scale = current_base_texture_scale


func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_resolve_target()

	var time := Time.get_ticks_msec() * 0.001 + flicker_offset
	var pulse := sin(time * flicker_speed) * 0.55
	pulse += sin(time * flicker_speed * 1.73) * 0.32
	pulse += sin(time * flicker_speed * 2.41) * 0.13
	pulse = clampf(pulse, -1.0, 1.0)

	energy = maxf(0.0, current_base_energy + (pulse * flicker_strength))
	texture_scale = maxf(0.0, current_base_texture_scale + (pulse * scale_flicker))

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


func add_obstruction() -> void:
	obstruction_count += 1
	_update_obstruction_state()


func remove_obstruction() -> void:
	obstruction_count = max(0, obstruction_count - 1)
	_update_obstruction_state()


func clear_obstructions() -> void:
	obstruction_count = 0
	_update_obstruction_state()


func _update_obstruction_state() -> void:
	var target_energy := obstructed_energy if obstruction_count > 0 else base_energy
	var target_texture_scale := obstructed_texture_scale if obstruction_count > 0 else base_texture_scale

	if obstruction_tween != null and obstruction_tween.is_valid():
		obstruction_tween.kill()

	obstruction_tween = create_tween()
	obstruction_tween.set_parallel(true)
	obstruction_tween.tween_property(self, "current_base_energy", target_energy, obstruction_transition).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	obstruction_tween.tween_property(self, "current_base_texture_scale", target_texture_scale, obstruction_transition).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
