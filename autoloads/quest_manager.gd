extends Node

# Sinais para a Interface saber quando se atualizar
signal quests_updated

# Listas que guardam as Quests atuais
var active_quests: Array[QuestData] = []
var completed_quests: Array[String] = [] # Guardamos só o ID das completadas

func start_quest(quest: QuestData) -> void:
	# Verifica se já não começou ou se já não terminou
	if not has_quest(quest.id) and not is_completed(quest.id):
		active_quests.append(quest)
		quests_updated.emit()

func complete_quest(quest_id: String) -> void:
	for i in range(active_quests.size()):
		if active_quests[i].id == quest_id:
			active_quests.remove_at(i)
			completed_quests.append(quest_id)
			quests_updated.emit()
			return

# Funções auxiliares para os NPCs perguntarem o estado
func has_quest(quest_id: String) -> bool:
	for q in active_quests:
		if q.id == quest_id: return true
	return false

func is_completed(quest_id: String) -> bool:
	return quest_id in completed_quests
