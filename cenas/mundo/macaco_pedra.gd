extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	anim.stop() # Começa parada para economizar recursos
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Carina":
		anim.play("animacao_pedra")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Carina":
		anim.stop()
