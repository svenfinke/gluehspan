extends Node2D

@export var upgradeable_component: Node
@export var inventory: InventoryResource = preload("res://resources/inventory.tres")
@export var milestones: MilestoneManager = preload("res://resources/milestone_manager.tres")
@export var flags: Array[Vector2]

const FLAG_SOURCE := 2
const FLAG_GRAY := Vector2(16,0)
const FLAG_GREEN := Vector2(16,1)
const FLAG_BLUE := Vector2(16,2)
const FLAG_RED := Vector2(16,3)
const FLAG_YELLOW := Vector2(16,4)

var cleanup = false

func _ready() -> void:
	milestones.milestone_achieved.connect(_on_milestone_achieved_or_upgraded)
	inventory.inventory_changed.connect(_on_inventory_update)
	if upgradeable_component != null:
		upgradeable_component.upgraded.connect(_on_milestone_achieved_or_upgraded)
	check_upgrades()
	
	UiEventBus.open_entity_ui.connect(_on_ui_open)
	
func _on_milestone_achieved_or_upgraded(milestone_name: String) -> void:
	check_upgrades()

func _on_inventory_update(item_name: String, _change_amount: int) -> void:
	if item_name != "money":
		return
	
	check_upgrades()

func check_upgrades() -> void:
	if upgradeable_component == null or not upgradeable_component.is_upgrade_available():
		update_flag(FLAG_GREEN)
	
	elif upgradeable_component.is_upgrade_blocked_by_milestone() or not upgradeable_component.is_upgrade_affordable():
		update_flag(FLAG_GRAY)
	
	else:
		update_flag(FLAG_BLUE)
		
func update_flag(new_flag: Vector2) -> void:
	var current_tier = 0
	if upgradeable_component != null:
		current_tier = upgradeable_component.level_to_tier_reference[upgradeable_component.level]
	
	if current_tier >= len(flags) or flags[current_tier] == null:
		return
	
	var tilemap : TileMap = get_parent().find_child("Tier" + str(current_tier))
	var layer = tilemap.get_layers_count() - 1
	if tilemap.get_cell_atlas_coords(layer, flags[current_tier]) != Vector2i(new_flag):
		if new_flag == FLAG_BLUE:
			$FlagChangedBlue.play()
			$HighlightParticles.global_position = tilemap.to_global(tilemap.map_to_local(flags[current_tier]))
			$HighlightParticles.emitting = true
	tilemap.set_cell(layer, flags[current_tier], FLAG_SOURCE, new_flag)

func _on_ui_open(caller:Node) -> void:
	if get_parent() == caller:
		$HighlightParticles.emitting = false
