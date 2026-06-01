extends Node2D

@onready var inventory: InventoryData = preload("res://recursos/inventario/player_inventory.tres")

var player: Player
var barco: NPCBarqueiro
var iara: Node = null
var cutscene_started := false

const BARQUEIRO_DATA = preload("res://recursos/personagens/barqueiro_data.tres")
const QUEST_SUPRIMENTOS = preload("res://recursos/quests/quest_suprimentos.tres")
const QUEST_VOLTAR_BARCO = preload("res://recursos/quests/quest_voltar_barco.tres")
const QUEST_MADEIRAS = preload("res://recursos/quests/quest_madeiras.tres")

func _ready() -> void:
	_find_nodes()
	inventory.all_collected.connect(_on_all_collected)
	
	# Inicializa a quest do barco
	inventory.required_items = 5
	set_wood_visible(false)
	set_boto_visible(false)
	
	# Efeito Iris de abertura do jogo (tela começa preta e foca na Carina)
	if player:
		PlayerManager.in_cutscene = true
		player.bloquear_movimento()
		ScreenTransition.iris_in(player, 1.5)

	if barco != null:
		await get_tree().create_timer(1.0).timeout
		barco.player_embarked.connect(_on_player_embarked)
		barco.departed.connect(_on_barco_departed)
		if barco.dialog_interaction:
			barco.dialog_interaction.player_entered.connect(_on_barco_player_entered)
		# Dispara o diálogo de abertura após 1 segundo
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(_iniciar_dialogo_abertura)
	else:
		push_warning("[Mundo] Barco nao encontrado! Verifique se o no 'Barco' esta na cena.")

var _cutscene_final_ativa := false

## Detecta quando o player entra na zona do barco — se for CHAMANDO, orquestra o diálogo final
func _on_barco_player_entered() -> void:
	if barco == null or barco.current_state != NPCBarqueiro.BarqueiroState.CHAMANDO:
		return
	if _cutscene_final_ativa:
		return
	_cutscene_final_ativa = true
	_iniciar_dialogo_final()

## Orquestra o diálogo final em 3 partes com animações da Iara (igual ao início)
func _iniciar_dialogo_final() -> void:
	# Desativa a zona de interação do Barco
	var barco_dialog := barco.get_node_or_null("DialogInteraction") as DialogInteraction
	if barco_dialog:
		barco_dialog.enabled = false

	if player:
		PlayerManager.in_cutscene = true
		player.bloquear_movimento()

	var all_lines := barco.get_dialog_lines("Chamada")
	if all_lines.is_empty():
		push_warning("[Mundo] Diálogo 'Chamada' vazio ou não encontrado.")
		barco.depart()
		return

	## Parte 1: Carlos grita socorro + Karina reage (linhas 0-2)
	var parte1: Array[DialogItem] = []
	parte1.assign(all_lines.slice(0, 3))
	await _play_dialog_segment(parte1)

	## Iara aparece (reseta do estado SUMIDA e toca coming → idle)
	if iara != null:
		if iara.has_method("resetar"):
			iara.resetar()
		if iara.has_method("aparecer"):
			iara.aparecer()
			barco.assustar()
			if player and player.has_method("assustar"):
				player.assustar()
			await iara.apareceu
			await get_tree().create_timer(1.0).timeout

	## Parte 2: Iara fala com todos (linhas 3-42)
	var parte2: Array[DialogItem] = []
	parte2.assign(all_lines.slice(3, 43))
	await _play_dialog_segment(parte2)

	## Iara sai
	if iara != null and iara.has_method("sair"):
		iara.sair()
		barco.acalmar()
		if player and player.has_method("acalmar"):
			player.acalmar()
		await iara.saiu
		await get_tree().create_timer(1.0).timeout

	## Parte 3: Carlos e Karina reagem (linhas 43-fim)
	var parte3: Array[DialogItem] = []
	parte3.assign(all_lines.slice(43))
	await _play_dialog_segment(parte3)

	get_tree().paused = false
	print("[Mundo] Diálogo final concluído. Barco partindo!")

	barco.current_state = NPCBarqueiro.BarqueiroState.POS_JOGO
	barco.depart()

	# Efeito Iris: Fecha na Carina no pier IMEDIATAMENTE após o fim da fala
	if player:
		await ScreenTransition.iris_out(player, 2.0)
	
	# Transição para a cena de FIM
	get_tree().change_scene_to_file("res://cenas/cutscenes/cutscene_fim.tscn")

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

func set_wood_visible(_visible: bool) -> void:
	for node in get_tree().get_nodes_in_group("Collectibles"):
		if node is Coletavel and node.item != null and node.item.name == "Madeira":
			node.visible = _visible
			var col_area = node.get_node_or_null("CollectibleArea")
			if col_area:
				col_area.set_deferred("monitoring", _visible)
				col_area.set_deferred("monitorable", _visible)

func set_boto_visible(vis: bool) -> void:
	for node in get_tree().get_nodes_in_group("NPCBoto"):
		node.set_deferred("monitoring", vis)
		node.set_deferred("monitorable", vis)
		
		if vis:
			node.modulate.a = 0.0
			node.visible = true
			var tween = create_tween()
			tween.tween_property(node, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			node.visible = false

func on_barqueiro_ajuda_pedida() -> void:
	print("[Mundo] Barqueiro pediu ajuda! Liberando madeiras no mapa.")
	PlayerManager.carlos_precisa_ajuda = false
	inventory.required_items = 10
	set_wood_visible(true)
	QuestManager.start_quest(QUEST_MADEIRAS)


func on_madeira_entregue() -> void:
	print("[Mundo] Madeiras entregues! Carlos preparando o barco.")
	QuestManager.complete_quest("quest_madeiras")
	set_boto_visible(true) # Faz o boto aparecer depois de entregar a madeira
	inventory.required_items = 5
	# Se já tiver os 5 suprimentos, dispara o evento de todos coletados!
	if inventory.get_item_count(preload("res://recursos/itens/suprimento.tres")) >= 5:
		_on_all_collected()

func _on_all_collected() -> void:
	if barco != null and barco.current_state == NPCBarqueiro.BarqueiroState.AGUARDANDO_SUPRIMENTOS:
		print("[Mundo] 5 suprimentos coletados, aguardando madeireiro...")
		QuestManager.complete_quest("quest_suprimentos")
		
		# Toca o diálogo de socorro quando encontra o último suprimento
		var socorro_dialog = preload("res://recursos/dialogs/barqueiro/socorro.tres")
		DialogSystem.show_dialog(socorro_dialog.lines)
		
		# Atualiza o barqueiro para o estado CHAMANDO para tocar chamada.tres na próxima vez que ela falar com ele!
		barco.current_state = NPCBarqueiro.BarqueiroState.CHAMANDO
		barco._on_player_entered_dialog()
		
		QuestManager.start_quest(QUEST_VOLTAR_BARCO)
	else:
		print("[Mundo] Todas as madeiras foram pegas!")
		var msg := DialogText.new()
		msg.text = "Carina, você coletou toda a madeira! Volte para o barco para consertarmos e partirmos."
		msg.char_info = BARQUEIRO_DATA
		var items: Array[DialogItem] = []
		items.assign([msg])
		DialogSystem.show_dialog(items)	
		QuestManager.start_quest(QUEST_VOLTAR_BARCO)

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
	pass

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
		
		await get_tree().create_timer(1.5).timeout

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
	
		await get_tree().create_timer(1.5).timeout

	## Parte 3: Carlos + Carina reagem, Carina decide ir (linhas 18-fim)
	var parte3: Array[DialogItem] = []
	parte3.assign(all_lines.slice(18))
	await _play_dialog_segment(parte3)

	barco.finalizar_inicio()
	print("[Mundo] Diálogo de abertura concluído.")
	QuestManager.start_quest(QUEST_SUPRIMENTOS)
	PlayerManager.in_cutscene = false
	# Garante que o jogo não fique pausado
	get_tree().paused = false
	player.liberar_movimento()
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
