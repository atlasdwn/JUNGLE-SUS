extends Node2D

signal player_arrived
signal departed

@onready var trigger_zone: Area2D = $TriggerZone
@onready var ponto_embarque: Marker2D = $PontoEmbarque

var active := false

func activate() -> void:
	active = true

func _on_trigger_zone_body_entered(body: Node2D) -> void:
	if body.name == "Carina" and active:
		active = false
		player_arrived.emit()

func depart() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 400), 3.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): departed.emit())
