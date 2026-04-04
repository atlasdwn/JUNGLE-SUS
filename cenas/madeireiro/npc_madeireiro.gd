extends Area2D

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
	caixa_dialogo.visible = false
	texto_dialogo.visible = false
	label_interacao.visible = false
	
func _process(_delta: float) -> void:
	if player_in_area and not falando and Input.is_action_just_pressed("interact"):
		iniciar_dialogo()
	elif falando and pode_avancar and Input.is_action_just_pressed("interact"):
		proxima_fala()





func _on_body_entered(body) -> void:
	if body.name == "PlayerMock":
		player_in_area = true
		label_interacao.text = "Pressione 'E' para interagir"
		label_interacao.visible = true
		



func _on_body_exited(body) -> void:
	if body.name == "PlayerMock":
		player_in_area = false
		label_interacao.visible = false
		if falando:
			encerrar_dialogo()
	

func iniciar_dialogo():
	falando = true
	label_interacao.visible = false
	caixa_dialogo.visible = true
	texto_dialogo.visible = true
	fala_index = 0
	proxima_fala()
	
func proxima_fala():
	if fala_index < falas.size():
		pode_avancar = false
		texto_dialogo.text = ""
		var texto = falas[fala_index]
		fala_index += 1
		mostrar_texto_com_efeito(texto)
	else:
		encerrar_dialogo()
		
		
func mostrar_texto_com_efeito(texto: String):
	await get_tree().create_timer(0.1).timeout
	for letra in texto:
		texto_dialogo.text += letra
		await get_tree().create_timer(0.02).timeout
	pode_avancar = true
	
func encerrar_dialogo():
	falando = false
	pode_avancar = false
	texto_dialogo.visible = false
	caixa_dialogo.visible = false
