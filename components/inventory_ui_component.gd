extends Node

@export var inventory: InventoryResource = preload("res://resources/inventory.tres")
@export var milestones: MilestoneManager = preload("res://resources/milestone_manager.tres")
@export var inventory_item_entity: PackedScene

var parent : Node

func _ready() -> void:
	parent = get_parent()
	inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed("", 0)
	pass
	
func _on_inventory_changed(_item_name, _amount) -> void:
	for child in parent.get_children():
		if child != self:
			child.queue_free()
	
	for item in inventory.items:
		if milestones.hasMilestone(item.name + "_obtained"):
			if not milestones.isMilestoneAchieved(item.name + "_obtained"):
				continue
		elif item.in_stock == 0:
			continue
		
		var entity = inventory_item_entity.instantiate()
		entity.find_child("Texture").texture = item.texture
		entity.find_child("Label").text = str(item.in_stock)
		parent.add_child(entity)
