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
	
	# Inicializa a quest do barco
	inventory.required_items = 5
	set_wood_visible(false)
	
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

func set_wood_visible(visible: bool) -> void:
	for node in get_tree().get_nodes_in_group("Collectibles"):
		if node is Coletavel and node.item != null and node.item.name == "Madeira":
			node.visible = visible
			var col_area = node.get_node_or_null("CollectibleArea")
			if col_area:
				col_area.set_deferred("monitoring", visible)
				col_area.set_deferred("monitorable", visible)

func on_barqueiro_ajuda_pedida() -> void:
	print("[Mundo] Barqueiro pediu ajuda! Liberando madeiras no mapa.")
	PlayerManager.carlos_precisa_ajuda = false
	inventory.required_items = 10
	set_wood_visible(true)

func on_madeira_entregue() -> void:
	print("[Mundo] Madeiras entregues! Carlos preparando o barco.")
	if barco != null:
		barco.ativar_chamada()

func _on_all_collected() -> void:
	if barco != null and barco.current_state == NPCBarqueiro.BarqueiroState.AGUARDANDO_SUPRIMENTOS:
		print("[Mundo] 5 suprimentos coletados, aguardando madeireiro...")
	else:
		print("[Mundo] Todos os coletáveis e madeiras foram pegos!")
		var msg := DialogText.new()
		msg.text = "Carina, você coletou tudo! Volte para o barco para consertarmos e partirmos."
		msg.char_info = BARQUEIRO_DATA
		var items: Array[DialogItem] = []
		items.assign([msg])
		DialogSystem.show_dialog(items)

var _esperando_madeireiro := true

func _process(_delta: float) -> void:
	if _esperando_madeireiro and PlayerManager.quest_madeireiro_concluida:
		_esperando_madeireiro = false
		_disparar_pedido_madeira()

func _disparar_pedido_madeira() -> void:
	if barco == null or barco.current_state != NPCBarqueiro.BarqueiroState.AGUARDANDO_SUPRIMENTOS:
		return
	print("[Mundo] Quest madeireiro concluída! Iniciando evento de ajuda do Barqueiro.")
	PlayerManager.carlos_precisa_ajuda = true
	barco.current_state = NPCBarqueiro.BarqueiroState.PEDINDO_AJUDA
	var msg := DialogText.new()
	msg.text = "Karina! Volte para o barco agora, precisamos conversar."
	msg.char_info = BARQUEIRO_DATA
	var items: Array[DialogItem] = []
	items.assign([msg])
	DialogSystem.show_dialog(items)


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

	## Parte 1: Carina + Carlos conversam (linhas 0-11)
	var parte1: Array[DialogItem] = []
	parte1.assign(all_lines.slice(0, 12))
	await _play_dialog_segment(parte1)

	## Iara aparece (animação roda com game unpaused)
	if iara != null and iara.has_method("aparecer"):
		iara.aparecer()
		barco.assustar()
		if player and player.has_method("assustar"):
			player.assustar()
		await iara.apareceu

	## Parte 2: Reações "!!" + Iara fala (linhas 12-17)
	var parte2: Array[DialogItem] = []
	parte2.assign(all_lines.slice(12, 18))
	await _play_dialog_segment(parte2)

	## Iara sai (animação roda com game unpaused)
	if iara != null and iara.has_method("sair"):
		iara.sair()
		barco.acalmar()
		if player and player.has_method("acalmar"):
			player.acalmar()
		await iara.saiu

	## Parte 3: Carlos + Carina reagem, Carina decide ir (linhas 18-fim)
	var parte3: Array[DialogItem] = []
	parte3.assign(all_lines.slice(18))
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
