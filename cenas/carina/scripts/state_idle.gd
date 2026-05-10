class_name StateIdle extends State

@onready var walk: State = $"../Walk"
@onready var collect: State = $"../Collect"

## O que acontece quando o player entra no estado
func enter() -> void:
	player.update_animation("idle")
	pass

func exit() -> void:
	pass

## O que acontece durante _process
func process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	elif Input.is_action_just_pressed("interact") and player.collectible_in_area == true:
		return collect
	player.velocity = Vector2.ZERO
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	return null
