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
	
	# the closes parent to this ParseNode that is a Node
	func node_parent() -> YarnNode:
		var node := parent

		while node:
			if node is YarnNode:
				return node as YarnNode
			node = node.parent

		return null


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
	var line := ''
	var shortcut_option_group: ShortcutOptionGroup = null

	func _init(parent: ParseNode, p: Parser).(parent, p):
		if (ShortcutOptionGroup.can_parse(p)):
			type = Type.SHORTCUT_OPTION_GROUP
			shortcut_option_group = ShortcutOptionGroup.new(self, p)
		elif (p.next_symbol_is(Lexer.TokenType.TEXT)):
			type = Type.LINE
			line = p.expect_symbol(Lexer.TokenType.TEXT).value as String
		else: 
			print('(parser.gd) ERROR: not implemented parsing %s' % p.tokens.front())
			p.tokens.pop_front()


	func print_tree(indent_level: int) -> String:
		var s := ''
		match type:
			Type.SHORTCUT_OPTION_GROUP:
				s += shortcut_option_group.print_tree(indent_level)
			Type.LINE:
				s += tab(indent_level, "Line: " + line)
			_:
				s += 'todo: other statement types not implemented'
		return s

class ShortcutOptionGroup extends ParseNode:
	static func can_parse(p: Parser) -> bool:
		return p.next_symbol_is(Lexer.TokenType.SHORTCUT_OPTION)

	var options := [] # enumerable of ShortcutOption

	func _init(parent: ParseNode, p: Parser).(parent, p):
		# keep parsing options until we can't, but expect at least one 
		# (otherwise it's not actually a list of opions)

		# give each option a number so it can name itself
		var shortcut_idx := 1 

		while (p.next_symbol_is(Lexer.TokenType.SHORTCUT_OPTION)):
			options.append(ShortcutOption.new(shortcut_idx, self, p))
			shortcut_idx += 1

	func print_tree(indent_level: int) -> String:
		var s := ''
		s += tab(indent_level, 'Shortcut option group {')
		for option in options:
			s += (option.print_tree(indent_level + 1))
		s += tab(indent_level, '}')
		return s

class ShortcutOption extends ParseNode:
	var label := ''
	var option_node: YarnNode = null # mark it with the right Node type

	func _init(option_idx: int, parent: ParseNode, p: Parser).(parent, p):
		p.expect_symbol(Lexer.TokenType.SHORTCUT_OPTION)
		label = p.expect_symbol(Lexer.TokenType.TEXT).value

		# todo: parse the conditional ("<<if $foo>>") if it's there
		
		if (p.next_symbol_is(Lexer.TokenType.INDENT)):
			p.expect_symbol(Lexer.TokenType.INDENT)
			option_node = YarnNode.new(
				'{0}.{1}'.format([node_parent().name, option_idx]),
				self, p)
			p.expect_symbol(Lexer.TokenType.DEDENT)

	func print_tree(indent_level: int) -> String:
		var s = ''
		s += tab(indent_level, 'Option "' + label + '"')

		if option_node:
			s += tab(indent_level, '{')
			s += tab(indent_level, 
				option_node.print_tree(indent_level + 1))
			s += tab(indent_level, '}')

		return s

class YarnNode extends ParseNode:
	var name: String

	var statements = [] # Statements
	
	func _init(name: String, parent: ParseNode, p: Parser).(parent, p):
		self.name = name

		while (not p.tokens.empty()) and not p.next_symbols_are([Lexer.TokenType.DEDENT, Lexer.TokenType.END_OF_INPUT]):
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
func next_symbols_are(valid_types: Array) -> bool:
	var t: int = tokens.front().type

	for valid_type in valid_types:
		if (t == valid_type):
			return true

	return false

# type is a Lexer.TokenType
func next_symbol_is(type: int) -> bool:
	return tokens.front().type == type

# type is a TokenType
func expect_symbol(type: int): # -> Lexer.Token
	var t : Lexer.Token = tokens.pop_front()
	if (t.type != type):
		print('(parser.gd): ERROR: unexpected token type')
	return t







