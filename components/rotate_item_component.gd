extends Node

@export var slot_index: int
@export var merchant_component: Node
@export var inventory: InventoryResource = preload("res://resources/inventory.tres")
@export var current_item: String:
	set(value):
		current_item = value
		var sell_item_icon = $"../RotateItemOnSale/TextureRect"
		var price_entry = $"../Price/PriceEntry"
		sell_item_icon.texture = null
		price_entry.visible = false
		merchant_component.sell_item_slots[slot_index] = ""
		
		if current_item == "":
			return
		
		var item = inventory.get_item(current_item)
		sell_item_icon.texture = item.texture
		price_entry.visible = true
		price_entry.find_child("Label").text = str(item.base_price)
		merchant_component.sell_item_slots[slot_index] = current_item
		
var parent

func _ready() -> void:
	parent = get_parent()
	$"../RotateItemOnSale".pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var next_item = inventory.get_next_item(current_item)
	current_item = "" if next_item == null else inventory.get_next_item(current_item).name
