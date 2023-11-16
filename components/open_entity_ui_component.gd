extends Node

func _ready() -> void:
	for child in get_parent().find_children("AreaTier*"):
		child.input_event.connect(_on_area_click)

func _on_area_click(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("ui_left_click"):
		UiEventBus.open_entity_ui.emit(get_parent())
