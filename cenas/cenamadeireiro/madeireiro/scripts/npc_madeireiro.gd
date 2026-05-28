extends NPCBase

enum MadeireiroState { FIRST_MEET, WAITING_FOR_AXE, COMPLETED, DEFAULT, DEATH }
enum QuestStatus { READY, ONGOING, FINISHED }

var current_state: MadeireiroState = MadeireiroState.FIRST_MEET
var player_in_area : bool = false
var player: Player
var quest_aceita : bool = false
var current_quest_status : QuestStatus = QuestStatus.READY

@export var machado_item: ItemData
@export var suprimento_item: ItemData
@export var npc_quests: Array[QuestData]

func _ready() -> void:	
	super._ready()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	DialogSystem.quest_choice.connect(_on_escolha_feita)
# 💡 Sobrescreve o método virtual do NPCBase
func _on_player_entered_dialog() -> void:
	match current_state:
		MadeireiroState.FIRST_MEET:
			dialog_interaction.current_dialog = _find_dialog("Primeiro Interact")
		MadeireiroState.WAITING_FOR_AXE:
			if player and player.inventory.has_item(machado_item):
				dialog_interaction.current_dialog = _find_dialog("Completed")
			else:
				dialog_interaction.current_dialog = _find_dialog("Waiting Axe")
		MadeireiroState.COMPLETED, MadeireiroState.DEFAULT:
			dialog_interaction.current_dialog = _find_dialog("Default")

# 💡 Sobrescreve o método virtual do NPCBase
func _on_interaction_finished() -> void:
	if current_state == MadeireiroState.FIRST_MEET:
		if quest_aceita:
			current_state = MadeireiroState.WAITING_FOR_AXE
			_on_player_entered_dialog()
		else:
			# Se recusou, ele continua no FIRST_MEET para você falar de novo depois
			pass
		quest_aceita = false
	elif current_state == MadeireiroState.WAITING_FOR_AXE:
		if player and player.inventory.has_item(machado_item):
			player.inventory.remove_item(machado_item)
			player.inventory.add_item(suprimento_item)
			current_state = MadeireiroState.COMPLETED
			current_quest_status = QuestStatus.FINISHED
			
			# Avisa o gerenciador global que a missão acabou para atualizar a tela!
			QuestManager.complete_quest("quest_madeireiro")
			
			_on_player_entered_dialog()
	
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body) -> void:
	if body.name == "Carina":
		player_in_area = true
		player = body

func _on_body_exited(body) -> void:
	if body.name == "Carina":
		player_in_area = false
		player = null

func _on_escolha_feita(id: String, aceitou: bool) -> void:
	# O NPC procura na lista dele para ver se esse ID pertence a ele
	for quest in npc_quests:
		if quest.id == id:
			# Atualiza a variável de estado para a cena conseguir avançar!
			quest_aceita = aceitou 
			
			if aceitou:
				QuestManager.start_quest(quest)
			break
