
class_name VirtualMachine

class State:
	# name of the node that we're currently in
	var current_node_name: String

	# instruction number in the current node
	var program_counter: int = 0

	# used as a stack of Values
	var stack = [] # of Values

# 	# methods for working with the stack
# 	func push_value(o) -> void:
# 		if o is Value:
# 			stack.push_front(o as Value)
# 		else:
# 			stack.push_front(Value.new(o))
# 
# 	# pop a value from the stack
# 	func pop_value() -> Value:
# 		return stack.pop_front()
# 
# 	# peek at a value from the stack
# 	func peek_value() -> Value:
# 		return stack.front()
# 
# 	# clear the stack
# 	func clear() -> void:
# 		return stack.clear()


func reset_state() -> void:
	state = State.new()

var line_handler: FuncRef # (Dialogue.LineResult)
var command_handler: FuncRef # (Dialogue.CommandResult)
var node_complete_handler: FuncRef # (Dialogue.NodeCompleteResul)

var program: Program
var state = State.new()

var current_node: Program.ProgramNode

enum ExecutionState {
	STOPPED,
	WAITING_ON_OPTION_SELECTION,
	RUNNING
}

var execution_state: int # ExecutionState

# todo: fix once bug is fixed
# https://github.com/godotengine/godot/issues/28010
var Dialogue = load('res://addons/yarnspinner/dialogue.gd')

func _init(program: Program) -> void:
	self.program = program

	execution_state = ExecutionState.RUNNING

func set_node(node_name: String) -> bool:
	if not program.nodes.has(node_name):
		print('todo: handle no node named %s' % node_name)
		return false

	current_node = program.nodes[node_name]
	reset_state()
	state.current_node_name = node_name

	return true


func run_next() -> void:
	if execution_state == ExecutionState.STOPPED:
		execution_state = ExecutionState.RUNNING

	var current_instruction : Program.Instruction = current_node.instructions[state.program_counter]

	run_instruction(current_instruction)
	state.program_counter += 1

	if (state.program_counter >= current_node.instructions.size()):
		execution_state = ExecutionState.STOPPED
		node_complete_handler.call_func(Dialogue.NodeCompleteResult.new(''))
		print('todo: log run complete')	


func run_instruction(i: Program.Instruction) -> void:
	match i.operation:
		Program.ByteCode.LABEL:
			# no-op - used as a destination for JUMP_TO and JUMP
			pass
		Program.ByteCode.RUN_LINE:
			# looks up a string from the string table and
			# passes it to the client as a line
			var line_str := i.operand_a as String
			var line_text := program.get_string(line_str)
			if not line_text:
				print('(vm) todo: handle line_text null')
				return
			line_handler.call_func(Dialogue.LineResult.new(line_text))
		Program.ByteCode.STOP:
			# immediately stop execution, and report it
			node_complete_handler.call_func(Dialogue.NodeCompleteResult.new(''))
			execution_state = ExecutionState.STOPPED
		_:
			execution_state = ExecutionState.STOPPED
			print('ByteCode %s not currently handled' % i.operation)

