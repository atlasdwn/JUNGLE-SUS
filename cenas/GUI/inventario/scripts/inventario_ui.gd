extends Control

@onready var inv: InventoryData = preload("res://recursos/inventario/player_inventory.tres")
@onready var slots: Array = $GridContainer.get_children()

var is_open = false

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()

func update_slots():
	for i in range(slots.size()):
		if i < inv.slots.size():
			slots[i].update(inv.slots[i])
		else:
			slots[i].update(null)

func _process(_delta: float) -> void:
	if DialogSystem.is_active or PlayerManager.in_cutscene:
		return
		
	if Input.is_action_just_pressed("inventario"):
		if is_open:
			close()
		else:
			open()

func close():
	visible = false
	is_open = false

func open():
	visible = true
	is_open = true
