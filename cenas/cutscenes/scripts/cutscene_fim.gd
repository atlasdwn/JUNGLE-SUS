extends Node2D

@onready var fim_label: Label = $CanvasLayer/FimLabel
@onready var inventory: InventoryData = preload("res://recursos/inventario/player_inventory.tres")

func _ready() -> void:
	var inv_panel = InventarioUi.get_node_or_null("Inventario_UI")
	if inv_panel and inv_panel.has_method("close"):
		inv_panel.close()
	else:
		InventarioUi.hide()
	inventory.clear()
	PlayerManager.reset_state()
	QuestManager.reset_quests()
	InventarioUi.process_mode = Node.PROCESS_MODE_DISABLED
	process_mode = Node.PROCESS_MODE_ALWAYS
	ScreenTransition.shader_material.set_shader_parameter("circle_size", 1.05)
	fim_label.modulate.a = 0.0
	_play_fim_sequence()

func _play_fim_sequence() -> void:
	var tween = create_tween()
	tween.tween_property(fim_label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3.0)
	tween.tween_property(fim_label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_interval(0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://cenas/GUI/menu/title_screen.tscn"))
