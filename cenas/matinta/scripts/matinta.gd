class_name Matinta extends NPCBase

enum MatintaState { BEFORE_GIVING, AFTER_GIVING }

var current_state: MatintaState = MatintaState.BEFORE_GIVING
var player_in_area = false
var player: Player

@export var machado_item: ItemData

func _ready() -> void:
	super._ready()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_player_entered_dialog() -> void:
	match current_state:
		MatintaState.BEFORE_GIVING:
			dialog_interaction.current_dialog = _find_dialog("Entregar Machado")
		MatintaState.AFTER_GIVING:
			dialog_interaction.current_dialog = _find_dialog("Default")

func _on_interaction_finished() -> void:
	if current_state == MatintaState.BEFORE_GIVING:
		if player and machado_item:
			player.inventory.add_item(machado_item)
		current_state = MatintaState.AFTER_GIVING
		_on_player_entered_dialog()

func _on_body_entered(body) -> void:
	if body.name == "Carina":
		player_in_area = true
		player = body

func _on_body_exited(body) -> void:
	if body.name == "Carina":
		player_in_area = false
		player = null
