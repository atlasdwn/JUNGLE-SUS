extends Node2D

@onready var inventory: InventoryData = preload("res://recursos/inventario/player_inventory.tres")

var player: Player
var barco: NPCBarqueiro
var iara: Node = null
var cutscene_started := false

const BARQUEIRO_DATA = preload("res://recursos/personagens/barqueiro_data.tres")

func _ready() -> void:
	_find_nodes()
	inventory.all_collected.connect(_on_all_collected)
	
	# Efeito Iris de abertura do jogo (tela começa preta e foca na Carina)
	if player:
	
		ScreenTransition.iris_in(player, 1.5)

	if barco != null:
		barco.player_embarked.connect(_on_player_embarked)
		barco.departed.connect(_on_barco_departed)
		# Dispara o diálogo de abertura após 1 segundo
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(_iniciar_dialogo_abertura)
	else:
		push_warning("[Mundo] Barco nao encontrado! Verifique se o no 'Barco' esta na cena.")

func _find_nodes() -> void:
	player = _find_child_by_class("Player") as Player
	barco = get_node_or_null("Y-sorting/Barco") as NPCBarqueiro
	iara  = get_node_or_null("NpcIara")
	print("[Mundo] player=", player, " | barco=", barco, " | iara=", iara)
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
	var msg := DialogText.new()
	msg.text = "Carina, está na hora de voltar pro barco!"
	msg.char_info = BARQUEIRO_DATA
	var items: Array[DialogItem] = []
	items.assign([msg])
	DialogSystem.show_dialog(items)
	if barco != null:
		barco.ativar_chamada()
	else:
		push_error("[Mundo] barco é NULL!")

func _on_player_at_barco() -> void:
	pass

func _on_player_embarked() -> void:
	print("[Mundo] Carina embarcou! Barco partindo...")
	
	# Efeito Iris: Fecha na Carina no final do jogo!
	if player:
		await ScreenTransition.iris_out(player, 2.0)
	
	# Aqui você pode chamar a tela de créditos ou mudar de cena
	# get_tree().change_scene_to_file("res://cenas/creditos.tscn")

func _on_barco_departed() -> void:
	print("[Mundo] Barco partiu! Fase concluída!")

## Orquestra o diálogo de abertura em 3 partes com animações da Iara entre elas
func _iniciar_dialogo_abertura() -> void:
	if barco == null:
		return

	# Desativa a zona de interação do Barco para evitar re-trigger durante a cutscene
	var barco_dialog := barco.get_node_or_null("DialogInteraction") as DialogInteraction
	if barco_dialog:
		barco_dialog.enabled = false

	var all_lines := barco.get_dialog_lines("Inicio")
	if all_lines.is_empty():
		push_warning("[Mundo] Diálogo 'Inicio' vazio ou não encontrado.")
		barco.finalizar_inicio()
		if barco_dialog:
			barco_dialog.enabled = true
		return

	## Parte 1: Carina + Carlos conversam (linhas 0-7)
	var parte1: Array[DialogItem] = []
	parte1.assign(all_lines.slice(0, 8))
	await _play_dialog_segment(parte1)

	## Iara aparece (animação roda com game unpaused)
	if iara != null and iara.has_method("aparecer"):
		iara.aparecer()
		barco.assustar()
		if player and player.has_method("assustar"):
			player.assustar()
		await iara.apareceu

	## Parte 2: Reações "!!" + Iara fala (linhas 8-13)
	var parte2: Array[DialogItem] = []
	parte2.assign(all_lines.slice(8, 14))
	await _play_dialog_segment(parte2)

	## Iara sai (animação roda com game unpaused)
	if iara != null and iara.has_method("sair"):
		iara.sair()
		barco.acalmar()
		if player and player.has_method("acalmar"):
			player.acalmar()
		await iara.saiu

	## Parte 3: Carlos + Carina reagem, Carina decide ir (linhas 14-fim)
	var parte3: Array[DialogItem] = []
	parte3.assign(all_lines.slice(14))
	await _play_dialog_segment(parte3)

	barco.finalizar_inicio()
	print("[Mundo] Diálogo de abertura concluído.")
	
	# Garante que o jogo não fique pausado
	get_tree().paused = false
	
	# Reativa a interação do Barco agora que a cutscene terminou
	var barco_dialog_final := barco.get_node_or_null("DialogInteraction") as DialogInteraction
	if barco_dialog_final:
		barco_dialog_final.enabled = true

## Helper: dispara um segmento de diálogo e aguarda terminar
func _play_dialog_segment(lines: Array[DialogItem]) -> void:
	if lines.is_empty():
		return
	DialogSystem.show_dialog(lines)
	await DialogSystem.finished
