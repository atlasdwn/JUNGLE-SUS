extends CharacterBody2D

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	# Pega a direção baseada nas setas/WASD (se configurado)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Aplica a velocidade na direção que o jogador está apertando
	if direction:
		velocity = direction * SPEED
	else:
		# Desacelera o personagem quando soltar os botões
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
