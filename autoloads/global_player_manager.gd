extends Node

signal interact_pressed

var interact_handled : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	print('emitiu interact')
	interact_handled = false
	interact_pressed.emit()
