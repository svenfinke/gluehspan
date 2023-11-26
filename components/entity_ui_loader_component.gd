extends Node

var material_entry: PackedScene = preload("res://entities/material_entry.tscn")
var marketplace_item_slot: PackedScene = preload("res://entities/marketplace_item_slot.tscn")

var parent: Control
var current_recipe_index: int:
	set(value):
		current_recipe_index = value
		var materials_container : Node = parent.get_node("%Materials")
		var crafting_component = current_entity.find_child("CraftingComponent")
		
		for child in materials_container.get_children():
			child.queue_free()
		
		var recipe = crafting_component.recipes[current_recipe_index]
		crafting_component.produced_item = recipe.produced_item
		
		for material in recipe.materials:
			var entry = material_entry.instantiate()
			var material_item = crafting_component.inventory.get_item(material)
			
			entry.find_child("Texture").texture = material_item.texture
			entry.find_child("Label").text = str(recipe.materials[material])
			
			materials_container.add_child(entry)
		
		parent.get_node("%Products").find_child("Texture").texture = crafting_component.inventory.get_item(recipe.produced_item).texture
	
var has_crafting: bool = false:
	set(value):
		has_crafting = value
		var crafting = parent.get_node("%Crafting")
		crafting.visible = value
		
		if not value:
			return
		
		var crafting_component = current_entity.find_child("CraftingComponent")
		var level = crafting_component.upgradeable_component.level
		
		if crafting_component.base_production_per_second_per_level[level] <= 0.01:
			crafting.visible = false
			return
		
		var index = 0
		for recipe in crafting_component.recipes:
			if recipe.produced_item == crafting_component.produced_item:
				break
			index += 1
			
		current_recipe_index = index

var has_production: bool = false:
	set(value):
		has_production = value

		var production = parent.get_node("%Production")
		production.visible = value

		if not value:
			return
		
		var production_component = current_entity.find_child("ProductionComponent")
		var level = production_component.upgradeable_component.level
		
		if production_component.base_production_per_second_per_level[level] <= 0.01:
			production.visible = false
			return
		
		var production_per_minute = production_component.base_production_per_second_per_level[level] * 60
		parent.find_child("ProduceLabel").text = str(production_per_minute) + " / minute"
		
		var produce_texture = production_component.inventory.get_item(production_component.produced_item).texture
		parent.find_child("ProduceTexture").texture = produce_texture

var has_updates: bool = false:
	set(value):
		has_updates = value
		var upgrades = parent.get_node("%Upgrades")
		upgrades.visible = value
		
		if not value:
			return
		
		var upgradeable_component = current_entity.find_child("UpgradeableComponent")
		if upgradeable_component.level == upgradeable_component.max_level:
			has_updates = false
			upgrades.visible = false
			return
			
		var cost: int = upgradeable_component.upgrade_cost_per_level[upgradeable_component.level]
		upgrades.get_node("%UpgradeCost").text = str(cost)

var has_marketplace: bool = false:
	set(value):
		has_marketplace = value
		var marketplace = parent.get_node("%Marketplace")
		marketplace.visible = value
		
		if not value:
			return
		
		var merchant_component = current_entity.find_child("MerchantComponent")
		var upgradeable_component = current_entity.find_child("UpgradeableComponent")
		if merchant_component.sell_interval_in_seconds_per_level[upgradeable_component.level] <= 0.1:
			marketplace.visible = false
			return
		
		var item_slots = marketplace.find_child("ItemSlots")
		for item_slot in item_slots.get_children():
			item_slot.queue_free()
		
		var i = 0
		for sell_item_slot in merchant_component.sell_item_slots:
			var entry = marketplace_item_slot.instantiate()
			var rotate_item_component = entry.find_child("RotateItemComponent")
			rotate_item_component.slot_index = i
			rotate_item_component.merchant_component = merchant_component
			rotate_item_component.current_item = sell_item_slot
			item_slots.add_child(entry)
			i += 1

var current_entity: Node2D:
	set(value):
		current_entity = value
		parent.get_node("%EntityName").text = current_entity.get_meta("Name", "NotSet")
		has_updates = value.has_node("UpgradeableComponent")
		has_crafting = value.has_node("CraftingComponent")
		has_production = value.has_node("ProductionComponent")
		has_marketplace = value.has_node("MerchantComponent")

func _ready() -> void:
	parent = get_parent()
	parent.visible = false
	
	UiEventBus.open_entity_ui.connect(open)
	parent.get_node("%UpgradeButton").pressed.connect(upgrade)	
	parent.get_node("%RotateRecipes").pressed.connect(next_recipe)

func open(entity: Node2D) -> void:
	current_entity = entity
	parent.visible = true

func upgrade() -> void:
	var upgradeable_component = current_entity.find_child("UpgradeableComponent")
	if upgradeable_component != null:
		upgradeable_component.upgrade()
		has_updates = true # Refresh Upgrade Cost?
		has_production = has_production
		has_crafting = has_crafting

func next_recipe() -> void:
	var crafting_component = current_entity.find_child("CraftingComponent")
	if current_recipe_index == len(crafting_component.recipes) - 1:
		current_recipe_index = 0
		return
	current_recipe_index += 1

func _process(_delta) -> void:
	if not parent.visible:
		return
	
	var milestone_error := %Milestone_Error
	var milestone_error_label := %Milestone_Error_Label
	milestone_error.visible = false
	milestone_error_label.visible = false
	var upgrade_button := %UpgradeButton
	upgrade_button.disabled = false
	var upgradeable_component = current_entity.find_child("UpgradeableComponent")
	if upgradeable_component != null and upgradeable_component.is_upgrade_available():
		if upgradeable_component.is_upgrade_blocked_by_milestone():
			var milestone : Milestone = upgradeable_component.return_current_milestone()
			var milestone_name = milestone.name.replace("_", " ").capitalize()
			milestone_error.visible = true
			milestone_error_label.visible = true
			milestone_error_label.text = "Milestone '" + milestone_name + "' is required!"
			upgrade_button.disabled = true
		
		if not upgradeable_component.is_upgrade_affordable():
			upgrade_button.disabled = true
