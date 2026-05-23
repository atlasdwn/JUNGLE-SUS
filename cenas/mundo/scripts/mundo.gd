extends Node2D

@onready var inventory: InventoryData = preload("res://recursos/inventario/player_inventory.tres")

var player: Player
var barco: Node2D
var dialog_box: PanelContainer
var cutscene_started := false

func _ready() -> void:
	_find_nodes()
	print("[Mundo] player=", player, " | barco=", barco, " | dialog=", dialog_box)
	inventory.all_collected.connect(_on_all_collected)

	if barco != null:
		barco.player_arrived.connect(_on_player_at_barco)
		barco.player_embarked.connect(_on_player_embarked)
		barco.departed.connect(_on_barco_departed)
	else:
		push_warning("[Mundo] Barco nao encontrado! Verifique se o no 'Barco' esta na cena.")

func _find_nodes() -> void:
	player = _find_child_by_class("Player") as Player

	for child in get_children():
		if child.name == "Barco":
			barco = child
			break

	var dialog_layer = _find_child_by_name("DialogBoxLayer")
	if dialog_layer != null:
		dialog_box = dialog_layer.get_node_or_null("DialogBox")

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
	if dialog_box != null:
		dialog_box.show_message("Carina, está na hora de voltar pro barco!")
	if barco != null:
		barco.activate()
	print("[Mundo] Todos os coletáveis foram pegos!")

func _on_player_at_barco() -> void:
	if cutscene_started:
		return
	cutscene_started = true
	print("[Mundo] Carina chegou ao barco! Embarcando...")

	if dialog_box != null:
		dialog_box.hide_message()

	# Tira o controle do jogador
	player.is_collecting = true

	# Esconde o sprite da Carina
	var anim_sprite = player.get_node_or_null("Anim")
	if anim_sprite != null:
		anim_sprite.visible = false
	else:
		push_warning("[Mundo] Node 'Anim' nao encontrado na Carina!")

	# Parte o barco
	barco.depart()

func _on_player_embarked() -> void:
	print("[Mundo] Carina embarcou! Barco partindo...")

func _on_barco_departed() -> void:
	print("[Mundo] Barco partiu! Fase concluída!")
