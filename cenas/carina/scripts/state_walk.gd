class_name StateWalk extends State

@export var move_speed : float = 60.0
@onready var idle: State = $"../Idle"
@onready var collect: StateCollect = $"../Collect"

## O que acontece quando o player entra no estado
func enter() -> void:
	player.update_animation("walk")
	pass

func exit() -> void:
	pass

## O que acontece durante _process
func process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	elif Input.is_action_just_pressed("interact") and player.collectible_in_area == true:
		return collect
	player.velocity = player.direction.normalized() * move_speed
	
	if player.set_direction():
		player.update_animation("walk")
		
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	return null
