extends Resource
class_name InventoryResource

signal inventory_changed(item_name: String, change_amount: int)

@export var items: Array[InventoryItem] = []
@export var milestones: MilestoneManager = null

func get_item(producedItem: String)	-> InventoryItem:
	for item in items:
		if item.name == producedItem:
			return item
	return null

func get_next_item(current_item: String, ignore_money: bool = true, include_empty: bool = true) -> InventoryItem:
	var i = 0
	var item_index = -1
	if current_item != "":
		for item in items:
			if item.name == current_item:
				item_index = i
			i += 1
	
	item_index += 1
	if item_index >= len(items):
		item_index = -1 if include_empty else 0
		
	if item_index == -1:
		return null
	
	if not can_display_item(items[item_index].name, ignore_money):
		return get_next_item(items[item_index].name, ignore_money)
	
	return items[item_index]

func can_display_item(current_item: String, ignore_money: bool = true) -> bool:
	if ignore_money and current_item == "money":
		return false
	
	if milestones != null:
		var milestone_name = current_item + "_obtained"
		if milestones and milestones.hasMilestone(milestone_name) and not milestones.isMilestoneAchieved(milestone_name):
			return false
	
	return true

func produce(produced_item: String, produced_amount: int = 1) -> void:
	for item in items:
		if item.name == produced_item:
			item.in_stock += produced_amount
			inventory_changed.emit(produced_item, produced_amount)
	
func craft(producedItem: String, materials: Dictionary, producedAmount: int = 1) -> bool:
	for material in materials:
		if not canConsume(material, materials[material]):
			return false
	for material in materials:
		consume(material, materials[material])
	
	produce(producedItem, producedAmount)
	return true
	
func canConsume(producedItem: String, amount: int) -> bool:
	for item in items:
		if item.name == producedItem:
			if item.in_stock >= amount:
				return true
	
	return false
	
func consume(producedItem: String, amount: int) -> bool:
	if not canConsume(producedItem, amount):
		return false
	
	for item in items:
		if item.name == producedItem:
			item.in_stock -= amount
			inventory_changed.emit(item.name, amount * -1)
			return true
	
	return false
