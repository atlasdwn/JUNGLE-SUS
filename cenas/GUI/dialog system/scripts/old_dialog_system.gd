@tool
@icon("res://assets/npc_and_dialog/icons/star_bubble.svg")
class_name DialogSystemNode extends CanvasLayer

@onready var dialog_ui: Control = $DialogUI
@onready var name_label: Label = $DialogUI/NameLabel
@onready var portrait: Sprite2D = $DialogUI/Portrait
@onready var dialog_progress: PanelContainer = $DialogUI/DialogProgress
@onready var dialog_progress_button: Label = $DialogUI/DialogProgress/DialogProgressButton
@onready var content: RichTextLabel = $DialogUI/DialogBG/Content

signal finished

var is_active : bool = false
var text_in_progress : bool = false

var dialog_items : Array[DialogItem]
var dialog_item_index : int = 0

var text_speed : float = 0.02
var text_length : int = 0
var plain_text : String

func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	hide_dialog()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_active == false:
			return
		#if event.is_action_pressed("teste"):
			#if is_active == false:
				#show_dialog()
			#else:
				#hide_dialog()
		if(
			event.is_action_pressed("interact") or
			event.is_action_pressed('ui_accept')
		):
			dialog_item_index += 1
			if dialog_item_index < dialog_items.size():
				print(event,'sim')
				start_dialog()
			else:
				print(event,'nao')
				hide_dialog()
		pass

func show_dialog(_items: Array[DialogItem]) -> void:
	is_active = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	start_dialog()
	pass
	
func hide_dialog() -> void:
	is_active = false
	dialog_ui.visible = false
	dialog_ui.process_mode= Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit() 
	pass

func start_dialog() -> void:
	dialog_ui.visible = true
	show_dialog_button(true)
	var _d : DialogItem = dialog_items[dialog_item_index]
	set_dialog_data(_d)
	pass
	
func set_dialog_data(_d : DialogItem) -> void:
	content.text = _d.text
	name_label.text = _d.char_info.npc_name
	portrait.texture = _d.char_info.portrait
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()
	pass
func show_dialog_button( _is_visible: bool) -> void:
	dialog_progress.visible = _is_visible
	if dialog_item_index + 1 < dialog_items.size():
		dialog_progress_button.text = 'NEXT'
	else:
		dialog_progress_button.text = 'END'
	
