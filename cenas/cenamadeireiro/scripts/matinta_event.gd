extends Node2D

@onready var parede_matinta: CollisionShape2D = $"../Ambiente/Passagens/ParedeMatinta/Collision"
@onready var gatilho_evento = $GatilhoEvento
@onready var zonas_esconderijo = $ZonasDeEsconderijo.get_children()
@onready var sombra_matinta = $CanvasLayer/SombraMatinta
@onready var audio_passaro = $AudioPassaro
@onready var timer_evento = $TimerEvento
@onready var timer_sombra = $TimerSombra
@onready var animation_player = $CanvasLayer/SombraMatinta/AnimationPlayer
@onready var matinta: Matinta = $"../Ambiente/Matinta"
@onready var carina : Player
@onready var tela_dica: PanelContainer = $CanvasLayer/TelaDica

var evento_ativo = false
var esperando_input_dica = false

func _ready():
	# Permite que este script gerencie inputs mesmo com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	parede_matinta.set_deferred("disabled", true)
	sombra_matinta.visible = false
	tela_dica.visible = false
	
	gatilho_evento.body_entered.connect(_on_gatilho_entered)
	timer_evento.timeout.connect(_on_timer_evento_timeout)
	timer_sombra.timeout.connect(_on_timer_sombra_timeout)
	
	if animation_player:
		animation_player.animation_finished.connect(_on_sombra_animation_finished)

func _process(_delta):
	if evento_ativo and carina and matinta:
		# Finaliza quando Carina esta a 300 pixels (ou menos) de distancia a esquerda da Matinta
		if carina.global_position.x > (matinta.global_position.x - 300):
			finalizar_evento()
			

func _on_gatilho_entered(body):
	if body.name == 'Carina':
		if not evento_ativo:
			carina = body
			iniciar_evento()
			gatilho_evento.set_deferred("monitoring", false)

func iniciar_evento():
	evento_ativo = true
	parede_matinta.set_deferred("disabled", false)
	
	# Exibe a dica e pausa o jogo para o jogador ler
	tela_dica.visible = true
	get_tree().paused = true
	esperando_input_dica = true

func _unhandled_input(event: InputEvent) -> void:
	# Só processa se a tela da dica estiver visível e esperando
	if esperando_input_dica:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			# Marca o input como consumido para não acionar outras coisas (ex: falar com NPC)
			get_viewport().set_input_as_handled()
			
			esperando_input_dica = false
			tela_dica.visible = false
			get_tree().paused = false
			
			# Agora que o jogador fechou a dica, o evento realmente começa a rodar
			agendar_proximo_ataque()

func finalizar_evento():
	evento_ativo = false
	timer_evento.stop()
	timer_sombra.stop()
	sombra_matinta.visible = false
	parede_matinta.set_deferred("disabled", true)


func agendar_proximo_ataque():
	if not evento_ativo: return
	timer_evento.start(randf_range(5.0, 10.0))

func _on_timer_evento_timeout():
	if not evento_ativo: return
	# Toca o som do passaro
	if audio_passaro:
		audio_passaro.play()
	
	# Aguarda um tempo para a sombra aparecer (tempo de reacao do jogador)
	timer_sombra.start(2.0)

func _on_timer_sombra_timeout():
	if not evento_ativo: return
	
	sombra_matinta.visible = true
	# Inicia a animacao da sombra cruzando a tela
	if animation_player and animation_player.has_animation("cruzar_tela"):
		animation_player.play("cruzar_tela")
	else:
		# Fallback simples caso a animação nao rode
		_on_sombra_animation_finished("cruzar_tela")

func _on_sombra_animation_finished(_anim_name):
	sombra_matinta.visible = false
	
	if not evento_ativo: return
	
	# Verifica se a Carina esta escondida
	var esta_escondida = false
	for esconderijo in zonas_esconderijo:
		if esconderijo is Area2D and esconderijo.overlaps_body(carina):
			esta_escondida = true
			break
	
	if not esta_escondida:
		# Game Over: Matinta pegou a Carina
		get_tree().change_scene_to_file("res://cenas/cutscenes/game_over.tscn")
	else:
		# Sobreviveu, agenda proximo
		agendar_proximo_ataque()
