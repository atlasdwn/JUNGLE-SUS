extends Node2D

@onready var inventory: InventoryData = preload("res://recursos/inventario/player_inventory.tres")

var player: Player
var barco: NPCBarqueiro
var cutscene_started := false

const BARQUEIRO_DATA = preload("res://recursos/personagens/barqueiro_data.tres")

func _ready() -> void:
	_find_nodes()
	print("[Mundo] player=", player, " | barco=", barco)
	inventory.all_collected.connect(_on_all_collected)

	if barco != null:
		barco.player_embarked.connect(_on_player_embarked)
		barco.departed.connect(_on_barco_departed)
	else:
		push_warning("[Mundo] Barco nao encontrado! Verifique se o no 'Barco' esta na cena.")

func _find_nodes() -> void:
	player = _find_child_by_class("Player") as Player

	for child in get_children():
		if child.name == "Barco":
			barco = child as NPCBarqueiro
			break

	pass

func _find_child_by_class(class_name_str: String) -> Node:
	for child in get_children():
		if child.get_class() == class_name_str or child is Player:
			return child
		for grandchild in child.get_children():
			if grandchild is Player:
				return grandchild
	return null

func _find_child_by_name(node_name: String) -> Node:
	for child in get_children():
		if child.name == node_name:
			return child
		var found := child.find_child(node_name, true, false)
		if found != null:
			return found
	return null

func _on_all_collected() -> void:
	print("[Mundo] Todos os coletáveis foram pegos!")
	print("[Mundo] barco ref: ", barco)
	# Mostra notificação no sistema de diálogo padrão (com portrait)
	var msg := DialogText.new()
	msg.text = "Carina, está na hora de voltar pro barco!"
	msg.char_info = BARQUEIRO_DATA
	DialogSystem.show_dialog([msg])
	if barco != null:
		barco.ativar_chamada()
	else:
		push_error("[Mundo] barco é NULL!")

func _on_player_at_barco() -> void:
	pass # Lógica de embarque agora é controlada diretamente pelo NPCBarqueiro/EmbarkZone

func _on_player_embarked() -> void:
	print("[Mundo] Carina embarcou! Barco partindo...")

func _on_barco_departed() -> void:
	print("[Mundo] Barco partiu! Fase concluída!")
