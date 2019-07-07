extends Node

class_name DialogueRunner

# currently just the path to the .yarn.txt file
export var source_text := 'res://yarns/main.yarn.txt'

# var variable_storage : VariableStorageBehavior
var dialogue_ui: DialogueUIBehavior

var is_dialogue_running: bool = false

var dialogue: Dialogue

func _ready() -> void:
	dialogue = Dialogue.new()

	if source_text:
		dialogue.load_file(source_text)

func _process(delta: float) -> void:
	pass

func start_dialogue(start_node: String = 'Start') -> void:
	# todo: package this pattern into a function
	# but also need to like loop on this or something
	var ret = dialogue_ui.dialogue_started()
	if ret:
		yield(ret, 'completed')
		
	for step in dialogue.run(start_node):
		if step is Dialogue.LineResult:
			yield(dialogue_ui.run_line(step.line), 
					'completed')
		elif step is Dialogue.OptionSetResult:
			print('(dr) todo: handle option sets')
		elif step is Dialogue.CommandResult:
			print('(dr) todo: handle command result')
		elif step is Dialogue.NodeCompleteResult:
			print('(dr) todo: handle node copmlete')

	# todo: make this yield-able?
	dialogue_ui.dialogue_complete()


