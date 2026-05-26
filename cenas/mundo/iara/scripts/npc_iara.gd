extends NPCBase

enum IaraState { PRIMEIRO_ENCONTRO, DEFAULT }

var current_state: IaraState = IaraState.PRIMEIRO_ENCONTRO

# 💡 Sobrescreve o método virtual do NPCBase
func _on_player_entered_dialog() -> void:
	match current_state:
		IaraState.PRIMEIRO_ENCONTRO:
			dialog_interaction.current_dialog = _find_dialog("Primeiro Encontro")
		IaraState.DEFAULT:
			dialog_interaction.current_dialog = _find_dialog("Default")

# 💡 Sobrescreve o método virtual do NPCBase
func _on_interaction_finished() -> void:
	if current_state == IaraState.PRIMEIRO_ENCONTRO:
		current_state = IaraState.DEFAULT
