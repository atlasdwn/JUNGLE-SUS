extends PanelContainer

@onready var message_label: Label = $MarginContainer/MessageLabel

var is_showing := false

func _ready() -> void:
	visible = false
	modulate.a = 0.0

func show_message(text: String) -> void:
	if is_showing:
		return

	is_showing = true
	message_label.text = text
	visible = true

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func hide_message() -> void:
	if not is_showing:
		return

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		visible = false
		is_showing = false
	)
