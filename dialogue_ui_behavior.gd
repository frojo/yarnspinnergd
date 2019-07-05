extends Node

# subclass this in your game
class_name DialogueUIBehavior


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func dialogue_started() -> void:
	pass

# display a line
# todo: static type line: Dialogue.Line once weird bug is fixed
func run_line(line) -> void:
	pass
