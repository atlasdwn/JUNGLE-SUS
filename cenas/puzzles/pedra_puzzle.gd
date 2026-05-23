extends Node2D

@export var item_escondido_path: NodePath
var hidden_item: Node2D
var initial_pos: Vector2
@onready var pedra: RigidBody2D = $Pedra

func _ready() -> void:
	initial_pos = pedra.global_position
	
	if not item_escondido_path.is_empty():
		hidden_item = get_node_or_null(item_escondido_path)
		
	if hidden_item:
		hidden_item.hide()
		hidden_item.process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(_delta: float) -> void:
	if hidden_item and hidden_item.process_mode == Node.PROCESS_MODE_DISABLED:
		if pedra.global_position.distance_to(initial_pos) > 16.0:
			hidden_item.show()
			hidden_item.process_mode = Node.PROCESS_MODE_INHERIT
			set_physics_process(false)
