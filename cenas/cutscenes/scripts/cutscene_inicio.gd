extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	# Toca a animação "play" que você configurou no editor!
	animation_player.play("play")
	
	# Quando a animação acabar, roda a função para iniciar o jogo
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	get_tree().change_scene_to_file("res://cenas/mundo/mundo.tscn")
