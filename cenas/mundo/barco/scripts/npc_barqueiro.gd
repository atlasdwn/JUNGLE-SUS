class_name NPCBarqueiro extends NPCBase

signal player_embarked
signal departed

enum BarqueiroState { INICIO, AGUARDANDO_SUPRIMENTOS, PEDINDO_AJUDA, CONSERTANDO_BARCO, CHAMANDO, POS_JOGO }
var current_state: BarqueiroState = BarqueiroState.INICIO

var embarked := false
var departing := false
var ponto_embarque: Marker2D

var dialog_pedindo_ajuda = preload("res://recursos/dialogs/barqueiro/pedindo_ajuda.tres")
var dialog_consertando = preload("res://recursos/dialogs/barqueiro/consertando.tres")
var dialog_concluido = preload("res://recursos/dialogs/barqueiro/concluido.tres")

func _ready() -> void:
	super._ready()
	var anim_node = get_node_or_null("AnimatedSprite2D")
	if anim_node:
		# Garante via código que a animação de susto toque apenas UMA vez e pare no último frame
		var frames = anim_node.sprite_frames
		if frames and frames.has_animation("scared"):
			frames.set_animation_loop("scared", false)
		anim_node.play("idle")
	ponto_embarque = get_node_or_null("PontoEmbarque")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	var embark_zone = get_node_or_null("EmbarkZone")
	if embark_zone and not embark_zone.body_entered.is_connected(_on_embark_zone_body_entered):
		embark_zone.body_entered.connect(_on_embark_zone_body_entered)

## Retorna as linhas de um diálogo pelo nome (usado pelo mundo.gd para orquestrar)
func get_dialog_lines(dial_name: String) -> Array[DialogItem]:
	var dialog := _find_dialog(dial_name)
	if dialog == null:
		return []
	var items: Array[DialogItem] = []
	items.assign(dialog.lines)
	return items

func finalizar_inicio() -> void:
	current_state = BarqueiroState.AGUARDANDO_SUPRIMENTOS
	# Safety: ensure barqueiro returns to idle after cutscene
	var anim_node = get_node_or_null("AnimatedSprite2D")
	if anim_node:
		anim_node.play("idle")
		anim_node.process_mode = Node.PROCESS_MODE_INHERIT

func assustar() -> void:
	var anim_node = get_node_or_null("AnimatedSprite2D")
	if anim_node:
		anim_node.process_mode = Node.PROCESS_MODE_ALWAYS
		anim_node.play("scared")

func acalmar() -> void:
	var anim_node = get_node_or_null("AnimatedSprite2D")
	if anim_node:
		anim_node.play("idle")
		anim_node.process_mode = Node.PROCESS_MODE_INHERIT

# Chamado pelo mundo.gd quando todos os suprimentos são coletados
func ativar_chamada() -> void:
	current_state = BarqueiroState.CHAMANDO

# Chamado após o embarque
func missao_concluida() -> void:
	current_state = BarqueiroState.POS_JOGO

func _get_world_node() -> Node:
	if owner != null and (owner.has_method("on_barqueiro_ajuda_pedida") or "inventory" in owner):
		return owner
	var p = get_parent()
	while p != null:
		if p.has_method("on_barqueiro_ajuda_pedida") or "inventory" in p:
			return p
		p = p.get_parent()
	return get_parent()

# 💡 Sobrescreve o método virtual do NPCBase
func _on_player_entered_dialog() -> void:
	match current_state:
		BarqueiroState.INICIO:
			pass # diálogo de início dispara via DialogSystem, não por aproximação
		BarqueiroState.AGUARDANDO_SUPRIMENTOS:
			dialog_interaction.current_dialog = _find_dialog("Aguardando")
		BarqueiroState.PEDINDO_AJUDA:
			dialog_interaction.current_dialog = dialog_pedindo_ajuda
		BarqueiroState.CONSERTANDO_BARCO:
			var world = _get_world_node()
			var total_madeira = 0
			if world and "inventory" in world:
				var wood_item = preload("res://recursos/itens/madeira_data.tres")
				total_madeira = world.inventory.get_item_count(wood_item)
			
			if total_madeira >= 5:
				dialog_interaction.current_dialog = dialog_concluido
			else:
				dialog_interaction.current_dialog = dialog_consertando
		BarqueiroState.CHAMANDO:
			dialog_interaction.current_dialog = _find_dialog("Chamada")
		BarqueiroState.POS_JOGO:
			dialog_interaction.current_dialog = _find_dialog("Pos Jogo")

# 💡 Sobrescreve o método virtual do NPCBase
func _on_interaction_finished() -> void:
	match current_state:
		BarqueiroState.PEDINDO_AJUDA:
			current_state = BarqueiroState.CONSERTANDO_BARCO
			var world = _get_world_node()
			if world and world.has_method("on_barqueiro_ajuda_pedida"):
				world.on_barqueiro_ajuda_pedida()
			_on_player_entered_dialog()
		BarqueiroState.CONSERTANDO_BARCO:
			var world = _get_world_node()
			var total_madeira = 0
			if world and "inventory" in world:
				var wood_item = preload("res://recursos/itens/madeira_data.tres")
				total_madeira = world.inventory.get_item_count(wood_item)
			
			if total_madeira >= 5:
				current_state = BarqueiroState.AGUARDANDO_SUPRIMENTOS
				if world and "inventory" in world:
					var wood_item = preload("res://recursos/itens/madeira_data.tres")
					for i in range(5):
						world.inventory.remove_item(wood_item)
				if world and world.has_method("on_madeira_entregue"):
					world.on_madeira_entregue()
				_on_player_entered_dialog()
		BarqueiroState.CHAMANDO:
			depart()
			current_state = BarqueiroState.POS_JOGO
			_on_player_entered_dialog()
		_:
			pass # Nos outros estados apenas fecha o diálogo

func _on_embark_zone_body_entered(body: Node2D) -> void:
	if body.name != "Carina" or embarked or not departing:
		return
	embarked = true
	var anim_sprite = body.get_node_or_null("Anim")
	if anim_sprite:
		anim_sprite.visible = false
	player_embarked.emit()

func depart() -> void:
	departing = true
	print("[Barco] Partindo!")
	
	# Esconde a Carina diretamente (ela já está dentro da zona)
	var mundo = _get_world_node()
	var carina = mundo.find_child("Carina", true, false) if mundo else null
	if carina:
		if carina.has_method("bloquear_movimento"):
			carina.bloquear_movimento()
		var camera = carina.get_node_or_null("Camera2D") as Camera2D
		if camera:
			camera.reparent(self, true)
		var anim_sprite = carina.get_node_or_null("Anim")
		if anim_sprite:
			anim_sprite.visible = false
		var shadow = carina.get_node_or_null("SpriteSombra")
		if shadow:
			shadow.visible = false
		print("[Barco] Carina escondida!")
	else:
		push_warning("[Barco] Carina nao encontrada para esconder!")
	
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 400), 7.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): departed.emit())

func _on_body_entered(_body) -> void:
	pass

func _on_body_exited(_body) -> void:
	pass
