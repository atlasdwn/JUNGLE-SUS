extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera2D

var shake_strength: float = 0.0

func _ready() -> void:
	# Toca a animação "play" que você configurou no editor!
	animation_player.play("play")
	
	# Quando a animação acabar, roda a função para iniciar o jogo
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if shake_strength > 0:
		# Reduz a força gradativamente
		shake_strength = lerpf(shake_strength, 0, 10 * delta)
		# Aplica o tremor no "offset" para não estragar a sua animação de "position"!
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		
		# Força o tremor a zerar se ficar muito fraco
		if shake_strength < 10.0:
			shake_strength = 0.0
	else:
		camera.offset = Vector2.ZERO

# Chame esta função pelo AnimationPlayer!
func tremer_camera(intensidade: float = 650.0) -> void:
	shake_strength = intensidade

func _on_animation_finished(anim_name: String) -> void:
	# Fecha o círculo na Carina/Câmera antes de pular pro jogo!
	await ScreenTransition.iris_out(camera, 1.2)
	get_tree().change_scene_to_file("res://cenas/mundo/mundo.tscn")
