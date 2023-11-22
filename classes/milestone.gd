extends Resource
class_name Milestone

signal milestone_achieved(milestone_name: String)

@export var name: String
@export var conditions: Array[MilestoneCondition]
@export var achieved: bool = false

func connect_signals() -> void:
	for condition in conditions:
		condition.milestone_status_changed.connect(_on_milestone_condition_status_changed)
		condition.connect_signals()

func _on_milestone_condition_status_changed() -> void:
	for condition in conditions:
		if not condition.state:
			return
	
	achieved = true
	milestone_achieved.emit(name)
