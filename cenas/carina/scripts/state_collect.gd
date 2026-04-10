class_name StateCollect extends State

## O que acontece quando o player entra no estado
func enter() -> void:
	player.update_animation("collect")
	pass

func exit() -> void:
	pass

## O que acontece durante _process
func process(_delta: float) -> State:
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	return null
