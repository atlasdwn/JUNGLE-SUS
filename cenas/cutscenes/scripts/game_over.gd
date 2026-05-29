extends Node2D

@onready var game_over_label: Label = $CanvasLayer/GameOverLabel
@onready var dica_label: Label = $CanvasLayer/DicaLabel

var mensagem_game_over: String = "GAME OVER"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	ScreenTransition.shader_material.set_shader_parameter("circle_size", 1.05)
	game_over_label.modulate.a = 0.0
	dica_label.modulate.a = 0.0
	game_over_label.text = mensagem_game_over
	_play_game_over_sequence()

func _play_game_over_sequence() -> void:
	# Totalmente instantâneo
	game_over_label.modulate.a = 1.0
	dica_label.modulate.a = 1.0
	_aguardar_input()

func _aguardar_input() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		var tween = create_tween()
		tween.tween_property(game_over_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.set_parallel(true)
		tween.tween_property(dica_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_interval(0.3)
		tween.tween_callback(func(): get_tree().change_scene_to_file("res://cenas/GUI/menu/title_screen.tscn"))
