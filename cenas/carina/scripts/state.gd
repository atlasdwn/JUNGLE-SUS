class_name State extends Node

static var player: Player 
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## O que acontece quando o player entra no estado
func enter() -> void:
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
