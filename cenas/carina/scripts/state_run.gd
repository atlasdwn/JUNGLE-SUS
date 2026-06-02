extends State

@onready var idle: StateIdle = $"../Idle"
@onready var collect: StateCollect = $"../Collect"
@onready var walk: StateWalk = $"../Walk"

@export var move_speed: float = 120.0

func enter() -> void:
	player.update_animation("run")
	player.set_walk_dust(true)

func exit() -> void:
	player.set_walk_dust(false)

## O que acontece durante _process
func process(_delta: float) -> State:
	player.velocity = player.direction.normalized() * move_speed
	if player.direction == Vector2.ZERO:
		return idle
		pass
	if player.set_direction():
		player.update_animation("run")
		
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_released('correr'):
		return walk
	if _event.is_action_pressed("interact"):
		if player.collectible_in_area:
			return collect
		PlayerManager.interact()
	return null
