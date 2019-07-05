class_name Parser

# Array of Tokens
var tokens: Array


class ParseNode:
	var parent: ParseNode

	# line number that this parse node begins on
	var line_number: int

	func _init(parent: ParseNode, p: Parser):
		self.parent = parent
		if not p.tokens.empty():
			self.line_number = p.tokens.front().line_number
		else:
			self.line_number = -1

	# this is a helper function for pretty printing
	func tab(indent_level: int, input: String, new_line: bool = true) -> String:
		var s := ''
		for i in range(indent_level):
			s += '| '
		s += input
		if new_line:
			s += '\n'
		return s

	func print_tree(indent_level: int) -> String:
		return 'todo: handle pure ParseNodes printing'

class Statement extends ParseNode:
	enum Type {
		CUSTOM_COMMAND
		SHORTCUT_OPTION_GROUP,
		BLOCK,
		IF_STATEMENT,
		OPTION_STATEMENT,
		ASSIGNMENT_STATEMENT,
		LINE
	}

	var type : int # Type

	var block: int
	var if_statement: int
	var option_statement: int
	var assignment_statement: int
	var custom_command: int
	var line: String
	var shortcut_option_group: int

	func _init(parent: ParseNode, p: Parser).(parent, p):

		if not p.next_symbol_is([Lexer.TokenType.TEXT]):
			print('todo: make this accept more than just lines')
			p.tokens.pop_front()
			return

		line = p.expect_symbol(Lexer.TokenType.TEXT).value as String
		type = Type.LINE

	func print_tree(indent_level: int) -> String:
		var s := ''
		match type:
			Type.LINE:
				s += tab(indent_level, "Line: " + line)
			_:
				s += 'todo: other statement types not implemented'
		return s
			




class YarnNode extends ParseNode:
	var name: String

	var statements = [] # Statements
	
	func _init(name: String, parent: ParseNode, p: Parser).(parent, p):
		self.name = name

		while (not p.tokens.empty()) and not p.next_symbol_is([Lexer.TokenType.DEDENT, Lexer.TokenType.END_OF_INPUT]):
			statements.append(Statement.new(self, p))

	func print_tree(indent_level: int) -> String:
		var s := ''

		s += tab(indent_level, 'Node ' + name + ' {')
		for statement in statements:
			s += statement.print_tree(indent_level + 1)

		s += tab(indent_level, '}')

		return s



func _init(tokens: Array):
	self.tokens = tokens

func parse() -> YarnNode:
	return YarnNode.new('Start', null, self)

# valid_types is an Array of Lexer.TokenTypes
func next_symbol_is(valid_types: Array) -> bool:
	var t: int = tokens.front().type

	for valid_type in valid_types:
		if (t == valid_type):
			return true

	return false

# type is a TokenType
func expect_symbol(type: int):
	var t : Lexer.Token = tokens.pop_front()
	if (t.type != type):
		print('todo: handle unexpected token type')
	return t







