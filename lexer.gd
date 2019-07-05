# heavily copy-pasted from https://github.com/thesecretlab/YarnSpinner/blob/master/YarnSpinner/Lexer.cs

class_name Lexer

enum TokenType {
	# Special tokens
	WHITESPACE,
	INDENT,
	DEDENT,
	END_OF_LINE,
	END_OF_INPUT,

	# Numbers. Everybody loves a number
	NUMBER,

	# Strings. Everybody also loves a string
	STRING,

	# '#'
	TAG_MARKER,

	# Command syntax ("<<foo>>")
	BEGIN_COMMAND,
	END_COMMAND,

	# Variables ("$foo")
	VARIABLE,

	# Shortcut syntax ("->")
	SHORTCUT_OPTION,

	# Option syntax ("[[Let's go here|Destination]]")
	OPTION_START, # [[
	OPTION_DELIMIT, # |
	OPTION_END, # ]]

	# Command types (specially recognised command word)
	IF,
	ELSEIF,
	ELSE,
	ENDIF,
	SET,

	# Boolean values
	TRUE,
	FALSE,

	# The null value
	NULL,

	# Parentheses
	LEFT_PAREN,
	RIGHT_PAREN,

	# Parameter delimiters
	COMMA,

	# Operators
	EQUALTO, # ==, eq, is
	GREATERTHAN, # >, gt
	GREATERTHANOREQUALTO, # >=, gte
	LESSTHAN, # <, lt
	LESSTHANOREQUALTO, # <=, lte
	NOTEQUALTO, # !=, neq

	# Logical operators
	OR, # ||, or
	AND, # &&, and
	XOR, # ^, xor
	NOT, # !, not

	# this guy's special because '=' can mean either 'equal to'
	# or 'becomes' depending on context
	EQUAL_TO_OR_ASSIGN, # =, to

	UNARY_MINUS, # -; this is differentiated from Minus
		    # when parsing expressions

	ADD, # +
	MINUS, # -
	MULTIPLY, # *
	DIVIDE, # /
	MODULO, # %

	ADD_ASSIGN, # +=
	MINUS_ASSIGN, # -=
	MULTIPLY_ASSIGN, # *=
	DIVIDE_ASSIGN, # /=

	COMMENT, # a run of text that we ignore

	IDENTIFIER, # a single word (used for functions)

	TEXT # a run of text until we hit other syntax
}

class Token:
	var type: int # TokenType
	var value: String

	var line_number: int
	var col_number: int

	var context: String

	var delimits_text: bool = false

	# if this is a function in an expression, this is the number
	# of parameters that were encountered
	var parameter_count: int

	# the state that the lexer was in when this token was emitted
	var lexer_state: String

	func _init(type: int, lexer_state: LexerState, 
			line_number: int = -1, col_number: int = -1,
			value: String = '') -> void:
		self.type = type
		self.value = value
		self.line_number = line_number
		self.col_number = col_number
		self.lexer_state = lexer_state.name

	func to_str() -> String:
		if value:
			return '%s (%s) at %s:%s (state: %s)' % [type, value, 
					line_number, col_number,lexer_state]
		else:
			return '%s at %s:%s (state: %s)' % [type,
					line_number, col_number,lexer_state]


class TokenRule:
	var regex: RegEx = null
	
	var enters_state: String
	var type: int
	var delimits_text: bool
	
	func _init(type: int, regex: RegEx, enters_state: String,
			delimits_text: bool) -> void:
		self.regex = regex
		self.enters_state = enters_state
		self.type = type
		self.delimits_text = delimits_text

	
class LexerState:
	var name: String

	# TokenType -> String
	var patterns: Dictionary

	# Array of TokenRule
	var token_rules = []

	func _init(patterns: Dictionary) -> void:
		self.patterns = patterns

	func add_transition(type: int, enters_state: String,
			delimits_text: bool = false) -> TokenRule:
		# todo: make this work right
		var pattern : String = patterns[type]
		if not pattern:
			print('todo: handle pattern not being string')
			return null
	
		var regex := RegEx.new()
		print('todo: make sure this regex is being compiled correctly')
		regex.compile(pattern)
	
		var rule := TokenRule.new(type, regex, enters_state, delimits_text)
	
		token_rules.append(rule)
	
		return rule


var default_state: LexerState
var current_state: LexerState

# String -> LexerState
var states: Dictionary

func _init():
	print('new lexer')

	# TokenType -> String
	var patterns := {}

	patterns[TokenType.TEXT] = '.'
	patterns[TokenType.NUMBER] = '\\-?[0-9]+(\\.[0-9+])?'

	patterns[TokenType.BEGIN_COMMAND] = '\\<\\<'

	states = {}

	states['base'] = LexerState.new(patterns)
	states['base'].add_transition(TokenType.BEGIN_COMMAND, 'command', true)
	# states['base'].add_transition(TokenType.BEGINCOMMAND, 'command', true)
	# add_transition(states['base'], TokenType.BEGINCOMMAND, 'command', true)

	default_state = states['base']

	for name in states.keys():
		states[name].name = name

# returns Array of Tokens
# title is title of the node
# lines is an array of lines that represents the node body
func tokenize(title: String, lines: Array) -> Array:
	var tokens := []

	current_state = default_state
	var line_number := 1

	for line in lines:
		tokens += tokenize_line(line, line_number)
		line_number += 1

	return tokens


# returns Array of Tokens
func tokenize_line(line: String, line_number: int) -> Array:
	var line_tokens = []

	var fake_token = Token.new(TokenType.TEXT, current_state,
			line_number, 0, line)

	line_tokens.append(fake_token)

	return line_tokens


	# todo: handle indentations

# 	var whitespace = RegEx.new()
# 	whitespace.compile('\\s*')
# 
# 	while col_number < line.size():
# 		pass




