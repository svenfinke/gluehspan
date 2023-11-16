extends Node

func _ready():
	UiEventBus.open_panel.connect(open)
	
func open(panel: String, caller_node: Node):
	pass
