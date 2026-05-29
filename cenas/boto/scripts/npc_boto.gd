extends NPCBase

enum BotoState { FIRST_MEET, COMPLETED }

var current_state: BotoState = BotoState.FIRST_MEET
var player_in_area = false
var player: Node2D
var cantada_aceita = false
var escolha_feita = false

@export var remedio_item: ItemData

func _ready() -> void:
	super._ready()
	add_to_group("NPCBoto")
	visible = false
	monitoring = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	DialogSystem.quest_choice.connect(_on_escolha_feita)

# 💡 Sobrescreve o método virtual do NPCBase
func _on_player_entered_dialog() -> void:
	if current_state == BotoState.FIRST_MEET:
		dialog_interaction.current_dialog = _find_dialog("Primeiro Interact")
	elif current_state == BotoState.COMPLETED:
		pass

# 💡 Sobrescreve o método virtual do NPCBase
func _on_interaction_finished() -> void:
	if current_state == BotoState.FIRST_MEET:
		if escolha_feita:
			if cantada_aceita:
				print("Game Over - Karina deu bola pro Boto")
				get_tree().change_scene_to_file("res://cenas/cutscenes/game_over.tscn")
			else:
				print("Boto entregou o item")
				if player and remedio_item:
					# Necessita garantir que Player tem propriedade inventory
					var inventory = player.get("inventory")
					if inventory:
						inventory.add_item(remedio_item)
				current_state = BotoState.COMPLETED
				# Opcional: Boto desaparece após entregar o item
				queue_free()
			escolha_feita = false

func _on_body_entered(body) -> void:
	if body.name == "Carina":
		player_in_area = true
		player = body

func _on_body_exited(body) -> void:
	if body.name == "Carina":
		player_in_area = false
		player = null

func _on_escolha_feita(id: String, aceitou: bool) -> void:
	if id == "Escolha Boto":
		cantada_aceita = aceitou
		escolha_feita = true
