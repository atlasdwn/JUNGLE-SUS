@icon("res://assets/npc_and_dialog/icons/chat_bubble.svg")
class_name DialogInteraction extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal player_interacted
signal player_entered
signal player_exited
signal finished

@export var enabled : bool = true

var dialog_items : Array[DialogItem]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_body_entered)	
	body_exited.connect(_on_body_exited)	
	
		
 
func player_interact() -> void:
	#player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.show_dialog(dialog_items)
	DialogSystem.finished.connect(_on_dialog_finished)
	pass

func _on_body_entered(_body : PhysicsBody2D) -> void:
	if enabled == false || dialog_items.size() == 0:
		return
	player_entered.emit()
	animation_player.play('show')
	PlayerManager.interact_pressed.connect(player_interact)
	pass
	
func _on_body_exited(_body : PhysicsBody2D) -> void:
	player_exited.emit()
	animation_player.play('hide')
	PlayerManager.interact_pressed.disconnect(player_interact)
	
	pass

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
