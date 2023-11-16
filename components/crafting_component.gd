extends Node

@export var inventory: InventoryResource
@export var base_production_per_second_per_level: Array[float] = [ 0 ]
@export var upgradeable_component: Node
@export var recipes: Array[RecipeResource]
@export var produced_item: String:
	set(value):
		produced_item = value
		current_recipe = null
		for recipe in recipes:
			if recipe.produced_item == value:
				current_recipe = recipe

var current_recipe: RecipeResource
var progress: float = 0

func _ready() -> void:
	# Make sure setter is being called
	produced_item = produced_item

func _process(delta: float) -> void:
	if current_recipe == null:
		return
		
	progress += delta * base_production_per_second_per_level[upgradeable_component.level]
	if progress >= 1 * current_recipe.production_speed_multiplier:				
		if inventory.craft(produced_item, current_recipe.materials):
			progress = 0
			var particle : CPUParticles2D = $ProductionParticle.duplicate()
			get_tree().current_scene.add_child(particle)
			particle.global_position = $ProductionParticle.global_position
			particle.texture = inventory.get_item(produced_item).texture
			particle.emitting = true
