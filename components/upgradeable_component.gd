extends Node

@export var inventory: InventoryResource
@export var level: int = 0
@export var max_level: int = 1
@export var upgrade_cost_per_level: Array[int] = []
@export var level_to_tier_reference: Array[int] = []

func _ready():
	for child in get_parent().find_children("AreaTier*"):
		child.input_event.connect(_on_area_click)
	update_visibility()

func update_visibility():
	for child in get_parent().find_children("*Tier*"):
		child.visible = false
	
	for child in get_parent().find_children("*Tier" + str(level_to_tier_reference[level])):
		child.visible = true

func upgrade() -> void:
	if level >= max_level:
		# No more tiers available
		return
	
	if not inventory.canConsume("money", upgrade_cost_per_level[level]):
		# Not enough money
		return
	
	inventory.consume("money", upgrade_cost_per_level[level])
	level += 1
	update_visibility()


func _on_area_click(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("ui_left_click"):
		upgrade()
