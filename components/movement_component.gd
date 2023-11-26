extends Node2D

@export var speed: float = 400

var drag_position: Vector2 = Vector2.ZERO
var is_dragging: bool

func _process(delta: float) -> void:
	var movement: Vector2
	if is_dragging:
		movement = drag_position - get_global_mouse_position()
		drag_position = get_global_mouse_position()
	else:
		var left_right = Input.get_axis("ui_left", "ui_right")
		var up_down = Input.get_axis("ui_up", "ui_down")
		
		movement = Vector2(floor(delta * speed * left_right), floor(delta * speed * up_down))
		
	get_parent().global_position = Vector2(
		clamp(get_parent().global_position.x + movement.x, -500 * get_parent().zoom.x, 950 * get_parent().zoom.x), 
		clamp(get_parent().global_position.y + movement.y, -500 * get_parent().zoom.x, 500 * get_parent().zoom.x))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left_click"):
		if drag_position == Vector2.ZERO:
			drag_position = get_global_mouse_position()
		is_dragging = true
	
	if event.is_action_released("ui_left_click"):
		is_dragging = false
		drag_position = Vector2.ZERO

	if event.is_action_released("ui_zoom_in"):
		get_parent().zoom = clamp(get_parent().zoom * 1.2, Vector2(.75,.75), Vector2(2.5,2.5))
	
	if event.is_action_released("ui_zoom_out"):
		get_parent().zoom = clamp(get_parent().zoom * .8, Vector2(.75,.75), Vector2(2.5,2.5))
