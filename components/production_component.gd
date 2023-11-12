extends Node2D

@export var inventory: InventoryResource
@export var produced_item: String
@export var base_production_per_second_per_level: Array[float] = [ 0 ]
@export var upgradeable_component: Node

var progress: float = 0

func _process(delta: float) -> void:
	progress += delta * base_production_per_second_per_level[upgradeable_component.level]
	if progress >= 1:
		progress = 0
		inventory.produce(produced_item)
		var particle : CPUParticles2D = $ProductionParticle.duplicate()
		get_tree().current_scene.add_child(particle)
		particle.global_position = $ProductionParticle.global_position
		particle.texture = inventory.get_item(produced_item).texture
		particle.emitting = true
