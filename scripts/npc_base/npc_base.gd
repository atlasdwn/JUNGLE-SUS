class_name NPCBase extends Area2D

@onready var dialog_interaction: DialogInteraction = _get_dialog_interaction()

func _ready() -> void:
	if dialog_interaction:
		dialog_interaction.player_entered.connect(_on_player_entered_dialog)
		dialog_interaction.finished.connect(_on_interaction_finished)

## Método virtual: Sobrescreva no NPC para injetar o diálogo correto
func _on_player_entered_dialog() -> void:
	pass

## Método virtual: Sobrescreva no NPC para mudar o estado após o fim do diálogo
func _on_interaction_finished() -> void:
	pass

## Helper para buscar diálogos pelo nome dentro do DialogInteraction
func _find_dialog(dialog_name: String) -> DialogResource:
	if dialog_interaction:
		for dialog in dialog_interaction.dialogs:
			if dialog.dial_name == dialog_name:
				return dialog
	return null

func _get_dialog_interaction() -> DialogInteraction:
	for child in get_children():
		if child is DialogInteraction:
			return child
	return null
