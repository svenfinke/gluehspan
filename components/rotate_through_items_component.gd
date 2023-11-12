extends Node

@export var inventory: InventoryResource
@export var sprite_target: TextureRect
@export var marketplace: Node
@export var merchant_component_slot: int

var current_item: InventoryItem
var current_index: int = -1
var merchant_component: Node

func _ready() -> void:
	assert(get_parent().has_signal("pressed"), "RotateThroughItemsComponent may only be added to Nodes with a 'pressed' signal")
	get_parent().pressed.connect(rotate)
	
	merchant_component = marketplace.find_child("MerchantComponent")

func _process(delta):
	if current_index != -1:
		sprite_target.texture = current_item.texture
	else:
		sprite_target.texture = null

func rotate() -> void:
	current_index += 1
	if current_index >= len(inventory.items):
		current_index = -1
		current_item = null
		merchant_component.sell_item_slots[merchant_component_slot] = ""
	else:
		current_item = inventory.items[current_index]
		merchant_component.sell_item_slots[merchant_component_slot] = current_item.name
