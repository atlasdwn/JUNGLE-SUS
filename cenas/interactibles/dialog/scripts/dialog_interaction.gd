@tool
@icon("res://assets/npc_and_dialog/icons/chat_bubble.svg")
class_name DialogInteraction extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal player_interacted
signal finished

@export var enabled : bool = true

var dialog_items : Array[DialogItem]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_body_entered)	
	body_exited.connect(_on_body_exited)	
		
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)
	pass
 
func player_interact() -> void:
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.showdialog(dialog_items)
	DialogSystem.finished.connect(_on_dialog_finished)
	pass

func _on_body_entered(_body : PhysicsBody2D) -> void:
	print(_body)
	if enabled == false || dialog_items.size() == 0:
		return
	animation_player.play('show')
	#PlayerManager.interact_pressed.connect(player_interact)
	
	pass
	
func _on_body_exited(_body : PhysicsBody2D) -> void:
	animation_player.play('hide')
	#PlayerManager.interact_pressed.disconnect(player_interact)
	
	pass
	
func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_items() == false:
		return ['Requires at least one DialogItem node']
	else:
		return []
	pass
	
func _check_for_dialog_items() -> bool :
	for c in get_children():
		if c is DialogItem:
			return true
	return false

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
