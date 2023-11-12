extends Node

@export var targetNode: Node

func _ready() -> void:
	assert(get_parent().has_signal("pressed"), "ToggleNodeVisibilityComponent may only be added to Nodes with a 'pressed' signal")
	
	get_parent().pressed.connect(toggleVisibility)
	targetNode.visible = false

func toggleVisibility() -> void:
	targetNode.visible = not targetNode.visible
