extends Node

@export var inventory: InventoryResource
@export var milestones: MilestoneManager
@export var level: int = 0
@export var max_level: int = 1
@export var upgrade_cost_per_level: Array[int] = []
@export var level_to_tier_reference: Array[int] = []
@export var milestone_required_per_level: Array[Milestone] = []

signal upgraded

func _ready():
	update_visibility()
	milestones.connect_signals()
	if inventory.milestones == null:
		inventory.milestones = milestones

func update_visibility():
	for child in get_parent().find_children("*Tier*"):
		child.visible = false
	
	for child in get_parent().find_children("*Tier" + str(level_to_tier_reference[level])):
		child.visible = true

func upgrade() -> void:
	if level >= max_level:
		# No more tiers available
		return
	
	if len(milestone_required_per_level) > level and milestone_required_per_level[level] != null:
		if not milestone_required_per_level[level].achieved:
			return
		
	
	if not inventory.canConsume("money", upgrade_cost_per_level[level]):
		# Not enough money
		return
	
	inventory.consume("money", upgrade_cost_per_level[level])
	level += 1
	$AnimationPlayer.play("upgrade")
	upgraded.emit()
	update_visibility()

func is_upgrade_available() -> bool:
	return level < max_level

func return_current_milestone() -> Milestone:
	if is_upgrade_blocked_by_milestone():
		return milestone_required_per_level[level]
	return null

func is_upgrade_blocked_by_milestone() -> bool:
	# No milestone defined for current level
	if len(milestone_required_per_level) <= level:
		return false
	elif milestone_required_per_level[level] == null:
		return false
	
	return not milestones.isMilestoneAchieved(milestone_required_per_level[level].name)

func is_upgrade_affordable() -> bool:
	return inventory.get_item("money").in_stock >= upgrade_cost_per_level[level]
