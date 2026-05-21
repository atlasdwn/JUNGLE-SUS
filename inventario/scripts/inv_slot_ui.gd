extends Button

@onready var item_display: TextureRect = $ItemDisplay
@onready var amount_display: Label = $AmountDisplay

func _ready() -> void:
	item_display.visible = false
	amount_display.visible = false 

func update(slot: SlotData):
	if !slot.item:	
		item_display.visible = false
		amount_display.visible = false 
	else:
		item_display.visible = true
		item_display.texture = slot.item.texture
		if slot.amount > 1:
			amount_display.visible = true
		amount_display.text = str(slot.amount)
		
