class_name StateWalk extends State

@export var move_speed : float = 200.0
@onready var idle: State = $"../Idle"
@onready var collect: StateCollect = $"../Collect"

## O que acontece quando o player entra no estado
func enter() -> void:
	player.update_animation("walk")
	player.set_walk_dust(true)

func exit() -> void:
	player.set_walk_dust(false)

## O que acontece durante _process
func process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	player.velocity = player.direction.normalized() * move_speed
	
	if player.set_direction():
		player.update_animation("walk")
		
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("interact"):
		if player.collectible_in_area:
			return collect
		PlayerManager.interact()
	return null
