class_name NPCBarqueiro extends NPCBase

signal player_embarked
signal departed

enum BarqueiroState { INICIO, AGUARDANDO_SUPRIMENTOS, CHAMANDO, POS_JOGO }
var current_state: BarqueiroState = BarqueiroState.INICIO

var embarked := false
var departing := false
var ponto_embarque: Marker2D

func _ready() -> void:
	super._ready()
	var anim_node = get_node_or_null("AnimatedSprite2D")
	if anim_node:
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

# 💡 Sobrescreve o método virtual do NPCBase
func _on_player_entered_dialog() -> void:
	match current_state:
		BarqueiroState.INICIO:
			pass # diálogo de início dispara via DialogSystem, não por aproximação
		BarqueiroState.AGUARDANDO_SUPRIMENTOS:
			dialog_interaction.current_dialog = _find_dialog("Aguardando")
		BarqueiroState.CHAMANDO:
			dialog_interaction.current_dialog = _find_dialog("Chamada")
		BarqueiroState.POS_JOGO:
			dialog_interaction.current_dialog = _find_dialog("Pos Jogo")

# 💡 Sobrescreve o método virtual do NPCBase
func _on_interaction_finished() -> void:
	match current_state:
		BarqueiroState.CHAMANDO:
			# Inicia a partida do barco após a conversa
			depart()
			current_state = BarqueiroState.POS_JOGO
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
	var mundo = get_parent()
	var carina = mundo.find_child("Carina", true, false) if mundo else null
	if carina:
		var anim_sprite = carina.get_node_or_null("Anim")
		if anim_sprite:
			anim_sprite.visible = false
		var shadow = carina.get_node_or_null("Sprite2D")
		if shadow:
			shadow.visible = false
		print("[Barco] Carina escondida!")
	else:
		push_warning("[Barco] Carina nao encontrada para esconder!")
	
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 400), 7.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): departed.emit())

func _on_body_entered(body) -> void:
	pass

func _on_body_exited(body) -> void:
	pass
