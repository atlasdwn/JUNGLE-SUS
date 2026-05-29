class_name StateIdle extends State

@onready var walk: State = $"../Walk"
@onready var collect: State = $"../Collect"

## O que acontece quando o player entra no estado
func enter() -> void:
	player.update_animation("idle")
	player.set_walk_dust(false)

func exit() -> void:
	pass

## O que acontece durante _process
func process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
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
