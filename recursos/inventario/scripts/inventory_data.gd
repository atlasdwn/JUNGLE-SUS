class_name InventoryData extends Resource

@export var slots : Array[SlotData]
@export var required_items: int = 5

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

func has_item(item: ItemData) -> bool:
	var itemslots = slots.filter(func(slot): return slot.item == item)
	return not itemslots.is_empty() and itemslots[0].amount > 0

func get_item_count(item: ItemData) -> int:
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if not itemslots.is_empty():
		return itemslots[0].amount
	return 0

func remove_item(item: ItemData) -> void:
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if not itemslots.is_empty():
		itemslots[0].amount -= 1
		if itemslots[0].amount <= 0:
			itemslots[0].item = null
			itemslots[0].amount = 0
		update.emit()

func _check_completion() -> void:
	var total := 0
	for slot in slots:
		if slot.item != null:
			total += slot.amount
	if total >= required_items:
		all_collected.emit()
