extends Resource
class_name InventoryResource

signal inventory_changed

@export var items: Array[InventoryItem] = []

func get_item(producedItem: String)	-> InventoryItem:
	for item in items:
		if item.name == producedItem:
			return item
	return null

func produce(producedItem: String, producedAmount: int = 1) -> void:
	for item in items:
		if item.name == producedItem:
			item.in_stock += producedAmount
			inventory_changed.emit()
	
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
			return true
	
	return false
