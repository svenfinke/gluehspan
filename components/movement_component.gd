extends Node2D

@export var speed: float = 200

var drag_position: Vector2 = Vector2.ZERO
var is_dragging: bool

func _process(delta: float) -> void:
	var movement: Vector2
	if is_dragging:
		movement = drag_position - get_global_mouse_position()
		get_parent().global_position += movement
		
		drag_position = get_global_mouse_position()
	else:
		var left_right = Input.get_axis("ui_left", "ui_right")
		var up_down = Input.get_axis("ui_up", "ui_down")
		
		movement = Vector2(delta * speed * left_right, delta * speed * up_down)
		
	get_parent().global_position += movement

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left_click"):
		if drag_position == Vector2.ZERO:
			drag_position = get_global_mouse_position()
		is_dragging = true
	
	if event.is_action_released("ui_left_click"):
		is_dragging = false
		drag_position = Vector2.ZERO
