class_name StateCollect extends State

@onready var idle: StateIdle = $"../Idle"
var final_dir: Vector2
var finished = false
var original_dir: Vector2 
## O que acontece quando o player entra no estado
func enter() -> void:
	var item = player.collectible
	var item_distance = item.global_position - player.global_position
	
	player.velocity = Vector2.ZERO
	player.set_walk_dust(false)
	
	if item == null:
		return
	if abs(item_distance.x) > abs(item_distance.y):
		final_dir = Vector2.LEFT if item_distance.x < 0 else Vector2.RIGHT
	else:
		final_dir = Vector2.UP if item_distance.y < 0 else Vector2.DOWN 

	original_dir = player.cardinal_direction
	player.cardinal_direction = final_dir
	player.anim.scale.x = -1 if final_dir == Vector2.LEFT else 1
	player.update_animation("collect")
	player.cardinal_direction = original_dir
	
func exit() -> void:
		player.anim.scale.x = -1 if original_dir == Vector2.LEFT else 1

func collect():
	var inventory = player.inventory
	inventory.add_item(player.collectible.item)
	player.collectible_in_area = false
	player.collectible.queue_free()
	player.collectible = null

## O que acontece durante _process
func process(_delta: float) -> State:
	player.is_collecting = true
	if finished:	
		finished = false
		player.is_collecting = false
		return idle
	return null
	
## O que acontece durante _physics_process
func physics(_delta: float) -> State:
	return null

## O que acontece com os inputs do estado
func handle_input(_event: InputEvent) -> State:
	return null


func _on_anim_player_animation_finished(_anim_name: StringName) -> void:
	finished = true
