class_name NPC extends Area2D

@onready var label_interacao: Label = $LabelInteracao

@onready var caixa_dialogo: Label = $CanvasLayer/CaixaDialogo
@onready var texto_dialogo: Label = $CanvasLayer/TextoDialogo

var player_in_area = false
var falando = false
var pode_avancar = false
var fala_index = 0
var falas = [
	"Ola, voce esta perdida? vc eh do ibama?"
]


func _ready() -> void:
	gather_interactables()
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false

func _process(_delta: float) -> void:
	#if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		#iniciar_dialogo()
	#elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		#proxima_fala()
	pass
func gather_interactables() -> void:
	for c in get_children():
		if c is DialogInteraction:
			c.player_interacted.connect(_on_player_interacted)
			c.finished.connect(_on_interaction_finished)
	pass

func _on_player_interacted() -> void:
	#update_direction(PlayerManager.player.global_position)
	#state = idle
	#velocity = Vector2.ZERO
	#update_animation()
	#do_behavior = false
	pass

func _on_interaction_finished() -> void:	
	#state = idle
	#update_animation()
	#do_behavior = true
	#do_behavior.enabled.emit()
	pass

func _on_body_entered(body) -> void:
	if body.name == "Carina":
		player_in_area = true
		#label_interacao.text = "Pressione 'E' para interagir"
		#label_interacao.visible = true

func _on_body_exited(body) -> void:
	if body.name == "Carina":
		player_in_area = false
		#label_interacao.visible = false
		#if falando:
			#encerrar_dialogo()


#func iniciar_dialogo():
	#falando = true
	#label_interacao.visible = false
	#caixa_dialogo.visible = true
	#texto_dialogo.visible = true
	#fala_index = 0
	#proxima_fala()
#
#func proxima_fala():
	#if fala_index < falas.size():
		#pode_avancar = false
		#texto_dialogo.text = ""
		#var texto = falas[fala_index]
		#fala_index += 1
		#mostrar_texto_com_efeito(texto)
	#else:
		#encerrar_dialogo()
#
#
#func mostrar_texto_com_efeito(texto: String):
	#await get_tree().create_timer(0.1).timeout
	#for letra in texto:
		#texto_dialogo.text += letra
		#await get_tree().create_timer(0.02).timeout
	#pode_avancar = true
#
#func encerrar_dialogo():
	#falando = false
	#pode_avancar = false
	#texto_dialogo.visible = false
	#caixa_dialogo.visible = false
