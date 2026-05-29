class_name StateCutscene extends State

signal arrived_at_target

var target_position: Vector2
var move_speed: float = 60.0
var arrival_threshold: float = 4.0
var has_arrived := false
var original_mask: int = 0

func enter() -> void:
	has_arrived = false
	player.is_collecting = true
	player.set_walk_dust(true)
	
	# Salva a mascara e desativa colisoes fisicas
	# Isso permite que ela ande por cima da agua/barreiras ate o barco
	original_mask = player.collision_mask
	player.collision_mask = 0

func exit() -> void:
	player.is_collecting = false
	player.velocity = Vector2.ZERO
	player.set_walk_dust(false)
	player.collision_mask = original_mask

func process(_delta: float) -> State:
	if has_arrived:
		return null

	var to_target := target_position - player.global_position

	if to_target.length() <= arrival_threshold:
		has_arrived = true
		player.velocity = Vector2.ZERO
		player.set_walk_dust(false)
		player.update_animation("idle")
		arrived_at_target.emit()
		return null

	player.direction = to_target.normalized()
	player.set_direction()
	player.velocity = player.direction.normalized() * move_speed
	player.update_animation("walk")
	return null

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null
