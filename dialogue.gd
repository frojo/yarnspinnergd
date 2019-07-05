#
# A YARN Importer for Godot
#
# Credits: 
# - Dave Kerr (http://www.naturallyintelligent.com)
# 
# Latest: https://github.com/naturally-intelligent/godot-yarn-importer
# 
# Yarn: https://github.com/InfiniteAmmoInc/Yarn
# Twine: http://twinery.org

class_name Dialogue

const DEFAULT_START := 'Start'

var loader: Loader

var program: Program


func OptionChooser(selected_option_index: int):
	pass

# information about stuff that the client should handle
# currently just wraps a single field, but doing it like this gives us the
# option to add more stuff later without breaking the API
class Line:
	var text: String
class Command:
	var text: String
class Options:
	# Array of Strings
	var options: Array


# this is an abstract class
class RunnerResult:
	var foo

class LineResult extends RunnerResult:
	var line: Line

	func _init(text: String):
		var line: = Line.new()
		line.text = text
		self.line = line

class CommandResult extends RunnerResult:
	var command: Command

	func _init(text: String):
		var command := Command.new()
		command.text = text
		self.command = command

class OptionSetResult extends RunnerResult:
	# Array of Options
	var options: Options
	var set_selected_option_delegate: FuncRef

	func _init(option_strings: Array,
			set_selected_option: FuncRef):
		var options := Options.new()
		options.options = option_strings
		self.options = options
		self.set_selected_option_delegate = set_selected_option

class NodeCompleteResult extends RunnerResult:
	var next_node: String

	func _init(next_node: String):
		self.next_node = next_node

# an iterator for iterating over an array
class RunnerResultIterator:
	# holds the yarn program
	var program: Program
	var start_node: String

	var vm: VirtualMachine
	var latest_result: RunnerResult

	func line_handler(result: LineResult):
		latest_result = result

	func command_handler(result: LineResult):
		latest_result = result

	func node_complete_handler(result: LineResult):
		latest_result = result

	func _init(program: Program, start_node: String) -> void:
		vm = VirtualMachine.new(program)
		vm.line_handler = funcref(self, 'line_handler')
		vm.command_handler = funcref(self, 'command_handler')
		vm.node_complete_handler = funcref(self, 'command_handler')

		self.program = program
		self.start_node = start_node

	# we don't ever want to return a null result. this function runs the
	# vm until it emits a non-null result or it stops
	# returns true if it finds a result, false if the vm has stopeed
	func step_until_result() -> bool:
		latest_result = null
		while vm.execution_state != VirtualMachine.ExecutionState.STOPPED:
			vm.run_next()
			if latest_result:
				return true
		return false

	func _iter_init(arg) -> bool:
		vm.set_node(start_node)
		return step_until_result()

	func _iter_next(arg) -> bool:
		return step_until_result()

	func _iter_get(arg) -> RunnerResult:
		if not latest_result:
			print('(dialogue) todo: handle result null. should "never" happen')
		return latest_result


# todo: make func signature run(start_node: String) -> ResultEnumerable:
func run(start_node: String = DEFAULT_START) -> RunnerResultIterator:
	if not program:
		print('todo: handle no program')
		return null
	return RunnerResultIterator.new(program, start_node)


# Create Yarn data structure from file (must be *.yarn.txt Yarn format)
# returns false if there was a problem
func load_file(path: String) -> bool:
	# Array of NodeInfos
	var nodes := []

	loader = Loader.new(self)
	program = loader.load(path)

	return true
