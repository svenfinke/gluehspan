extends Resource
class_name MilestoneManager

signal milestone_achieved(milestone_name: String)

@export var milestones: Array[Milestone]

var signals_connected: bool = false

func connect_signals() -> void:
	if signals_connected:
		return
		
	for milestone in milestones:
		milestone.milestone_achieved.connect(_on_milestone_achieved)
		milestone.connect_signals()
	
	signals_connected = true

func isMilestoneAchieved(milestone_name: String) -> bool:
	for milestone in milestones:
		if milestone.name == milestone_name:
			return milestone.achieved
	return false

func hasMilestone(milestone_name: String) -> bool:
	for milestone in milestones:
		if milestone.name == milestone_name:
			return true
	return false

func _on_milestone_achieved(milestone_name: String) -> void:
	milestone_achieved.emit(milestone_name)
