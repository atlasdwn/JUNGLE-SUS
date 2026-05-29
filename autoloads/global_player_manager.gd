extends Node

signal interact_pressed

var interact_handled : bool = true
var carlos_precisa_ajuda : bool = false
var quest_madeireiro_concluida : bool = false
var in_cutscene : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	print('emitiu interact')
	if DialogSystem.is_active:
		return
	interact_handled = false
	interact_pressed.emit()

func reset_state() -> void:
	interact_handled = true
	carlos_precisa_ajuda = false
	quest_madeireiro_concluida = false
	in_cutscene = false
