@tool
@icon("res://assets/npc_and_dialog/icons/chat_bubble.svg")
class_name DialogItem extends Resource

@export var char_info: CharacterResource

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	check_npc_data()
	pass
	
func check_npc_data():
	if char_info == null:
		var p = self
		var _checking : bool = true
		while  _checking == true:
			p = p.get_parent()
			if p:
				if p is NPCBase and p.char_info:
					char_info = p.char_info
					_checking = false
			else:
				_checking = false
	pass
	
