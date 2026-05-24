extends Node2D

@onready var camera = $Camera2D
@onready var fade_overlay = $CanvasLayer/FadeOverlay

func _ready() -> void:
	# Começa com a tela preta para o Fade-In
	fade_overlay.color.a = 1.0
	play_cutscene()

func play_cutscene() -> void:
	var tween = create_tween()
	# Transição Cubic e InOut garantem a suavidade "cinematográfica", sem solavancos
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Configuração Inicial
	camera.position = Vector2(0, 0)
	camera.zoom = Vector2(0.25, 0.25)
	
	# 1. Fade-in inicial (Fica transparente)
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.0)
	
	# 2. Quadro 1: Leve zoom in durante 3 segundos
	tween.tween_property(camera, "zoom", Vector2(0.3, 0.3), 3.0)
	
	# 3. Pan para o Quadro 2
	tween.tween_property(camera, "position", Vector2(4500, 0), 1.5)
	
	# 4. Quadro 2: Leve movimento de câmera ("Ken Burns" effect) para a direita
	tween.tween_property(camera, "position", Vector2(4700, 0), 3.0)
	
	# 5. Pan para o Quadro 3
	tween.tween_property(camera, "position", Vector2(9000, 0), 1.5)
	
	# 6. Quadro 3: Zoom out simultâneo com um pan sutil
	tween.parallel().tween_property(camera, "zoom", Vector2(0.27, 0.27), 3.0)
	tween.tween_property(camera, "position", Vector2(9100, 0), 3.0)
	
	# 7. Fade-out para preto no final
	tween.tween_property(fade_overlay, "color:a", 1.0, 1.5)
	
	# 8. Transição para o Jogo
	tween.tween_callback(go_to_game)

func go_to_game() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo/mundo.tscn")
