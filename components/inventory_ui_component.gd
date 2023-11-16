extends Node

@export var inventory: InventoryResource
@export var inventory_item_entity: PackedScene

var parent : Node

func _ready() -> void:
	parent = get_parent()
	inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed()
	pass
	
func _on_inventory_changed() -> void:
	for child in parent.get_children():
		if child != self:
			child.queue_free()
	
	for item in inventory.items:
		if item.in_stock == 0:
			continue
		
		var entity = inventory_item_entity.instantiate()
		entity.find_child("Texture").texture = item.texture
		entity.find_child("Label").text = str(item.in_stock)
		parent.add_child(entity)
