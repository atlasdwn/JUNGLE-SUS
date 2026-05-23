class_name InventoryData extends Resource

@export var slots : Array[SlotData]
@export var required_items: int = 4

signal update
signal all_collected

func add_item(item: ItemData) -> void:
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()
	_check_completion()

func _check_completion() -> void:
	var total := 0
	for slot in slots:
		if slot.item != null:
			total += slot.amount
	if total >= required_items:
		all_collected.emit()
