@tool
@icon("res://assets/npc_and_dialog/icons/star_bubble.svg")
extends CanvasLayer
class_name DialogSystemNode 

@onready var dialog_ui: Control = $DialogUI
@onready var name_label: Label = $DialogUI/NameLabel
@onready var portrait: Sprite2D = $DialogUI/Portrait
@onready var dialog_progress: PanelContainer = $DialogUI/DialogProgress
@onready var dialog_progress_button: Label = $DialogUI/DialogProgress/DialogProgressButton
@onready var content: RichTextLabel = $DialogUI/DialogBG/Content
@onready var timer: Timer = $DialogUI/Timer

# NÓS NOVOS PARA ESCOLHA (Você criará na UI)
@onready var choice_container: Control = $DialogUI/ChoiceContainer
@onready var btn_accept: Button = $DialogUI/ChoiceContainer/ButtonAccept
@onready var btn_refuse: Button = $DialogUI/ChoiceContainer/ButtonRefuse

signal finished
signal letter_added(letter : String)
signal quest_choice(choice_id: String, accepted: bool)

var is_active : bool = false
var text_in_progress : bool = false

var dialog_items : Array # Tipagem aberta para suportar Resource e DialogItem juntos
var dialog_item_index : int = 0

var text_speed : float = 0.03
var text_length : int = 0
var plain_text : String

# VARIÁVEIS DO SISTEMA DE ESCOLHA
var dialog_stack : Array[Dictionary] = []
var waiting_for_choice: bool = false
var current_choice_item: DialogChoice = null

func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	timer.timeout.connect( _on_timer_timeout )
	
	# Configurações iniciais dos botões
	if choice_container:
		choice_container.visible = false
		btn_accept.pressed.connect(_on_accept_pressed)
		btn_refuse.pressed.connect(_on_refuse_pressed)
		
	hide_dialog()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	# ---------------------------------------------------------
	# LÓGICA DE NAVEGAÇÃO DE ESCOLHA
	# ---------------------------------------------------------
	if waiting_for_choice:
		get_viewport().set_input_as_handled()
		
		# Navegação para a Esquerda
		if event.is_action_pressed("ui_left") or event.is_action_pressed("esquerda"):
			btn_accept.grab_focus()
			
		# Navegação para a Direita
		elif event.is_action_pressed("ui_right") or event.is_action_pressed("direita"):
			btn_refuse.grab_focus()
			
		# Confirmar
		elif event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
			var focused = get_viewport().gui_get_focus_owner()
			if focused == btn_accept:
				_on_accept_pressed()
			elif focused == btn_refuse:
				_on_refuse_pressed()
				
		return # Sai da função para não avançar o texto normal

	# ---------------------------------------------------------
	# LÓGICA NORMAL DE AVANÇAR TEXTO
	# ---------------------------------------------------------
	if event.is_action_pressed("interact") or event.is_action_pressed('ui_accept'):
		get_viewport().set_input_as_handled()
		
		if text_in_progress:
			# Completa o texto instantaneamente
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			_check_end_of_text()
		else:
			next_dialog()

func show_dialog(_items: Array) -> void:
	is_active = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	dialog_stack.clear() # Limpa a pilha ao iniciar uma conversa nova
	get_tree().paused = true
	await get_tree().process_frame
	start_dialog()

func hide_dialog() -> void:
	is_active = false
	dialog_ui.visible = false
	dialog_ui.process_mode= Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit() 

func start_dialog() -> void:
	dialog_ui.visible = true
	show_dialog_button(false)
	if choice_container:
		choice_container.visible = false
		
	var _d = dialog_items[dialog_item_index]
	set_dialog_data(_d)

func set_dialog_data(_d) -> void:
	# Verifica se o item é uma escolha
	if _d is DialogChoice:
		current_choice_item = _d
		btn_accept.text = _d.accept_text
		btn_refuse.text = _d.refuse_text
	else:
		current_choice_item = null
		
	content.text = _d.text
	
	# Puxa informações do personagem
	if _d.char_info:
		name_label.text = _d.char_info.name
		portrait.texture = _d.char_info.portrait
		
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()

func show_dialog_button( _is_visible: bool) -> void:
	dialog_progress.visible = _is_visible
	# Verifica se há mais texto nesta lista OU se há algo na pilha para voltar
	if dialog_item_index + 1 < dialog_items.size() or dialog_stack.size() > 0:
		dialog_progress_button.text = 'NEXT'
	else:
		dialog_progress_button.text = 'END'
	
func start_timer() -> void:
	timer.wait_time = text_speed
	var _char = plain_text[ content.visible_characters - 1 ]
	if '.!?:;'.contains( _char ):
		timer.wait_time *= 4
	elif ', '.contains( _char ):
		timer.wait_time *= 2
	timer.start()

func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters <= text_length:
		letter_added.emit( plain_text[ content.visible_characters - 1 ] )
		start_timer()
	else:
		text_in_progress = false
		_check_end_of_text()

func _check_end_of_text():
	# Se for uma pergunta, mostra os botões. Se não, mostra o NEXT/END
	if current_choice_item != null:
		show_dialog_button(false)
		choice_container.visible = true
		waiting_for_choice = true
		btn_accept.grab_focus()
	else:
		show_dialog_button(true)

# ---------------------------------------------------------
# SISTEMA DE ESCOLHA E PILHA (STACK)
# ---------------------------------------------------------
func _on_accept_pressed() -> void:
	quest_choice.emit(current_choice_item.choice_id, true) # Envia o ID e o True
	advance_choice(current_choice_item.accept_dialogs)

func _on_refuse_pressed() -> void:
	quest_choice.emit(current_choice_item.choice_id, false) # Envia o ID e o False
	advance_choice(current_choice_item.refuse_dialogs)

func advance_choice(new_dialogs: Array) -> void:
	choice_container.visible = false
	waiting_for_choice = false
	current_choice_item = null
	
	if new_dialogs and new_dialogs.size() > 0:
		# Salva o estado atual na pilha
		dialog_stack.append({
			"items": dialog_items,
			"index": dialog_item_index
		})
		# Substitui pela rota escolhida
		dialog_items = new_dialogs
		dialog_item_index = 0
		start_dialog()
	else:
		# Sem desdobramentos, apenas pula para a próxima frase original
		next_dialog()

func next_dialog() -> void:
	dialog_item_index += 1
	
	if dialog_item_index < dialog_items.size():
		start_dialog()
	else:
		# A lista atual acabou. Retorna da pilha se houver.
		if dialog_stack.size() > 0:
			var prev_state = dialog_stack.pop_back()
			dialog_items = prev_state["items"]
			dialog_item_index = prev_state["index"]
			
			# Como voltamos para a posição da Escolha, mandamos avançar +1
			next_dialog() 
		else:
			# Pilha vazia e falas acabaram = Fim do Diálogo
			hide_dialog()
