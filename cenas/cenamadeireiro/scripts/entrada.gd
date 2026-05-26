extends Area2D

@export var dialog: DialogResource
@export var npc_madeireiro: NPCBase

func _ready() -> void:
	if npc_madeireiro:
		# Se o NPC ainda não rodou o _ready dele, a Entrada pausa aqui e espera ele terminar!
		if not npc_madeireiro.is_node_ready():
			await npc_madeireiro.ready
			
		if npc_madeireiro.current_state == npc_madeireiro.MadeireiroState.FIRST_MEET:
			body_entered.connect(_on_body_entered)
			npc_madeireiro.dialog_interaction.finished.connect(_on_madeireiro_finished)
		else:
			queue_free()
	else:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	if dialog:
		var items: Array[DialogItem] = []
		items.assign(dialog.lines)
		DialogSystem.show_dialog(items)
		DialogSystem.finished.connect(_on_entrada_dialog_finished)
	else:
		_on_entrada_dialog_finished()

func _on_entrada_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_entrada_dialog_finished)
	
	# A área de entrada já foi desconectada (linha 22), então ela não vai tocar de novo.
	# Nós não mudamos o estado do madeireiro e nem destruimos a área aqui.
	# A área ficará viva apenas esperando o madeireiro terminar a primeira interação dele.

func _on_madeireiro_finished() -> void:
	# Se o player falar com o NPC direto, a entrada escuta e se autodestrói
	queue_free()
