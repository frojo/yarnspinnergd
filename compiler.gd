class_name Compiler

var program: Program

func _init() -> void:
	program = Program.new()

func compile_node(node: Parser.YarnNode) -> void:
	if program.nodes.has(node.name):
		print('todo: handle duplicate node name: ', node.name)
		return

	var compiled_node = Program.ProgramNode.new()

	compiled_node.name = node.name

	var start_label = register_label()
	emit(compiled_node, Program.ByteCode.LABEL, start_label)


	for statement in node.statements:
		generate_code_statement(compiled_node, statement)

	# todo: implement options
	var has_remaining_options = false
	if not has_remaining_options:
		emit(compiled_node, Program.ByteCode.STOP)

	program.nodes[compiled_node.name] = compiled_node


var label_count := 0

func register_label(commentary: String = ''):
	var label := 'L%s%s' % [label_count,  commentary]
	label_count += 1
	return label

func emit(node: Program.ProgramNode, code: int, # Program.ByteCode
		operand_a = null, operand_b = null):

	var instruction := Program.Instruction.new()
	instruction.operation = code
	instruction.operand_a = operand_a
	instruction.operand_b = operand_b

	node.instructions.append(instruction)

	if (code == Program.ByteCode.LABEL):
		# add this label to the label table
		node.labels[instruction.operand_a] = node.instructions.size() - 1


func generate_code_statement(node: Program.ProgramNode, statement: Parser.Statement):
	match statement.type:
		Parser.Statement.Type.LINE:
			var num = program.register_string(
					statement.line, node.name, 
					statement.line_number)
			emit(node, Program.ByteCode.RUN_LINE, num)
		_:
			print('unimplimented statement type %s' % statement.type)

	

