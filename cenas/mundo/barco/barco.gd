extends Node2D

signal player_arrived
signal player_embarked
signal departed

@onready var trigger_zone: Area2D = $TriggerZone
@onready var embark_zone: Area2D = $EmbarkZone
@onready var ponto_embarque: Marker2D = $PontoEmbarque

var active := false
var embarked := false
var player_ref: Node2D = null

func activate() -> void:
	active = true
	print("[Barco] Ativado! Aguardando Carina...")

func _on_trigger_zone_body_entered(body: Node2D) -> void:
	print("[Barco] TriggerZone detectou: ", body.name, " | active=", active)
	if body.name == "Carina" and active:
		player_ref = body
		active = false
		player_arrived.emit()
		print("[Barco] player_arrived emitido!")

func _on_embark_zone_body_entered(body: Node2D) -> void:
	print("[Barco] EmbarkZone detectou: ", body.name)
	if body.name != "Carina" or embarked:
		return

	embarked = true
	print("[Barco] Carina embarcou! Escondendo sprite...")

	var anim_sprite = body.get_node_or_null("Anim")
	if anim_sprite != null:
		anim_sprite.visible = false
	else:
		push_warning("[Barco] Node 'Anim' nao encontrado na Carina!")

	player_embarked.emit()
	depart()

func depart() -> void:
	print("[Barco] Partindo!")
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 400), 7.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): departed.emit())
