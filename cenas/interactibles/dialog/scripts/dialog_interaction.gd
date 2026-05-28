@icon("res://assets/npc_and_dialog/icons/chat_bubble.svg")
class_name DialogInteraction extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal player_entered
signal player_exited
signal finished

@export var enabled : bool = true
@export var dialogs: Array[DialogResource] # Usado caso nenhum diálogo seja injetado

var current_dialog: DialogResource:
	set(value):
		current_dialog = value
		if current_dialog:
			dialog_items.assign(current_dialog.lines)

var dialog_items : Array[DialogItem]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)

func player_interact() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	if PlayerManager.carlos_precisa_ajuda and not (owner is NPCBarqueiro):
		var msg := DialogText.new()
		msg.text = "Preciso voltar e falar com o Carlos no barco primeiro..."
		msg.char_info = preload("res://recursos/personagens/barqueiro_data.tres")
		var items: Array[DialogItem] = []
		items.assign([msg])
		DialogSystem.show_dialog(items)
		DialogSystem.finished.connect(_on_dialog_finished)
		return
		
	DialogSystem.show_dialog(dialog_items)
	DialogSystem.finished.connect(_on_dialog_finished)


func _on_body_entered(_body : PhysicsBody2D) -> void:
	if enabled == false:
		return
		
	# Padrão: Se ninguém escolheu um diálogo, toca o primeiro.
	if current_dialog == null and dialogs.size() > 0:
		current_dialog = dialogs[0]
		
	# Emite o sinal. O NPCBase escuta isso e altera o 'current_dialog' antes de prosseguirmos.
	player_entered.emit()
		
	if dialog_items.size() == 0:
		return
		
	animation_player.play('show')
	body_exited.connect(_on_body_exited)
	PlayerManager.interact_pressed.connect(player_interact)
	
func _on_body_exited(_body : PhysicsBody2D) -> void:
	player_exited.emit()
	dialog_items.clear()
	current_dialog = null 
	animation_player.play('hide')
	body_exited.disconnect(_on_body_exited)
	PlayerManager.interact_pressed.disconnect(player_interact)

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
