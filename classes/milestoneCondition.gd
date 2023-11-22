extends Resource
class_name MilestoneCondition

signal milestone_status_changed

enum MilestoneConditionType { IN_STOCK_AT_ONCE, PRODUCED, CONSUMED }
@export var type: MilestoneConditionType
@export var item_name: String
@export var value: int
@export var state: bool = false

var inventory: InventoryResource = load("res://resources/inventory.tres")
var value_progress : int = 0

func connect_signals():
	inventory.inventory_changed.connect(_on_inventory_changed)
	pass

func _on_inventory_changed(changed_item_name: String, amount: int) -> void:
	if changed_item_name != item_name:
		return
	
	if type == MilestoneConditionType.IN_STOCK_AT_ONCE:
		value_progress = inventory.get_item(item_name).in_stock
	elif type == MilestoneConditionType.PRODUCED and amount > 0:
		value_progress += amount
	elif type == MilestoneConditionType.CONSUMED and amount < 0:
		value_progress += abs(amount)
	
	state = value <= value_progress
	
	if state:
		inventory.inventory_changed.disconnect(_on_inventory_changed)
		milestone_status_changed.emit()
