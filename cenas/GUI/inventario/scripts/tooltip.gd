extends PanelContainer

@onready var inv_slot: Button = $".."
@onready var item_name: Label = $VContainer/ItemName
@onready var item_desc: RichTextLabel = $VContainer/ItemDesc

const OFFSET: Vector2 = Vector2.ONE * 10

var opacity_tween: Tween = null

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + OFFSET

func toggle(on: bool):
	if on:
		item_name.text = inv_slot.item.name
		item_desc.text = inv_slot.item.description
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
		
func tween_opacity(to: float):
	if opacity_tween: opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, 'modulate:a', to, 0.3)
	return opacity_tween
