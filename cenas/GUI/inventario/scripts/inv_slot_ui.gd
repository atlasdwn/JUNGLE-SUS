extends Button

@onready var item_display: TextureRect = $ItemDisplay
@onready var amount_display: Label = $AmountDisplay
@onready var tooltip: PanelContainer = $Tooltip

var item: ItemData

func _ready() -> void:
	item_display.visible = false
	amount_display.visible = false 
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update(slot: SlotData):
	if !slot.item:	
		item_display.visible = false
		amount_display.visible = false 
	else:
		item = slot.item
		item_display.visible = true
		item_display.texture = item.texture
		if slot.amount > 1:
			amount_display.visible = true
		amount_display.text = str(slot.amount)
		
func _on_mouse_entered():
	if item:
		tooltip.toggle(true)

func _on_mouse_exited():
		tooltip.toggle(false)
