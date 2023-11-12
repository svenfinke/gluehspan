extends Node

@export var inventory: InventoryResource
@export var item: String
@export var label: Label

func _ready() -> void:
	inventory.inventory_changed.connect(update)

func update() -> void:
	var item_obj = inventory.get_item(item)
	if item_obj != null:
		label.text = str(item_obj.in_stock)
	else:
		label.text = "0"
