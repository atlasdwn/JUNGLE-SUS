extends NPCBase

signal apareceu
signal saiu

enum IaraState { OCULTA, APARECENDO, VISIVEL, SAINDO, SUMIDA }
var current_state: IaraState = IaraState.OCULTA

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	visible = false
	# Permite animações rodarem mesmo com get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	if dialog_interaction:
		dialog_interaction.enabled = false

## Chamado pelo mundo.gd — toca "coming" → "idle" e emite sinal
func aparecer() -> void:
	if current_state != IaraState.OCULTA:
		return
	current_state = IaraState.APARECENDO
	visible = true
	anim.play(&"coming")
	await anim.animation_finished
	current_state = IaraState.VISIVEL
	anim.play(&"idle")
	apareceu.emit()

## Chamado pelo mundo.gd — toca "leaving" e emite sinal
func sair() -> void:
	if current_state != IaraState.VISIVEL:
		return
	current_state = IaraState.SAINDO
	anim.play(&"leaving")
	await anim.animation_finished
	current_state = IaraState.SUMIDA
	visible = false
	saiu.emit()

## Iara não volta mais — sem interação
func _on_player_entered_dialog() -> void:
	pass

func _on_interaction_finished() -> void:
	pass
