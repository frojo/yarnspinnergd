
class_name Program

var strings := {} # <string, string>

var string_count := 0

func register_string(s : String, node_name: String, 
		line_number: int) -> String:
	string_count += 1
	var key := '%s-%s' % [node_name, string_count]
	strings[key] = s
	return key

var nodes := {} # <node_title, ProgramNode>

func get_string(key: String) -> String:
	return strings.get(key, '')

class ProgramNode:
	var instructions := [] # of Instructions
	var name := ''
	var labels := {} # <string, int>


class Instruction:
	var operation: int # ByteCode
	var operand_a = null
	var operand_b = null

	func to_string() -> String:
		return '%s: %s, %s' % [operation, operand_a, operand_b]

enum ByteCode {
	# opA = string: label name
	LABEL,
	# opA = string: label name
	JUMP_TO,
	# peek string from stack and jump to that label
	JUMP,
	# opA = int: string number
	RUN_LINE,
	# opA = string: command text
	RUN_COMMAND,
	# opA = int: string number for option to add
	ADDOPTION,
	# present the current list of options, then clear the list; most recently selected option will be on the top of the stack
	SHOW_OPTIONS,
	# opA = int: string number in table; push string to stack
	PUSH_STRING,
	# opA = float: number to push to stack
	PUSH_NUMBER,
	# opA = int (0 or 1): bool to push to stack
	PUSH_BOOL,
	# pushes a null value onto the stack
	PUSH_NULL,
	# opA = string: label name if top of stack is not null, zero or false, jumps to that label
	JUMP_IF_FALSE,
	# discard top of stack
	POP,
	# opA = string; looks up function, pops as many arguments as needed, result is pushed to stack
	CALL_FUNC,
	# opA = name of variable to get value of and push to stack
	PUSH_VARIABLE,
	# opA = name of variable to store top of stack in
	STORE_VARIABLE,
	# stops execution
	STOP,
	# run the node whose name is at the top of the stack
	RUN_NODE
}

