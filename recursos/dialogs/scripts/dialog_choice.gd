@tool
@icon("res://assets/npc_and_dialog/icons/text_bubble.svg")
class_name DialogChoice extends DialogItem

@export var choice_id : String = ""
@export_multiline var text : String = "Você aceita o pedido?" 

@export_category("Opções")
@export var accept_text : String = "Aceitar"
@export var refuse_text : String = "Recusar"

@export_category("Desdobramentos")
@export var accept_dialogs : Array[DialogItem]
@export var refuse_dialogs : Array[DialogItem]
