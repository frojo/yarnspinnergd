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

	TEXT # (49) a run of text until we hit other syntax 
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
	var type: int # TokenType
	var is_text_rule: bool
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

	var set_track_next_indentation = false

	func _init(patterns: Dictionary) -> void:
		self.patterns = patterns

	func add_transition(type: int, enters_state: String = '',
			delimits_text: bool = false) -> TokenRule:
		var pattern : String = patterns[type]
		if not pattern:
			print('todo: handle pattern not being string')
			return null
	
		# todo: make this work right
		var regex := RegEx.new()
		regex.compile(pattern)
	
		var rule := TokenRule.new(type, regex, enters_state, delimits_text)
	
		token_rules.append(rule)
	
		return rule

	func add_text_rule(type: int, enters_state: String = '') -> TokenRule:
		if contains_text_rule():
			print('(lexer.gd): ERROR!: State already contains a text rule')

		var delim_rules = []

		print('debug: adding text rule')
		for other_rule in token_rules:
			if other_rule.delimits_text:
				print('debug: THIS IS UNTESTED CODE. NEVER HAD DELIMIT THING')
				var pattern = other_rule.regex.get_pattern()
				pattern = pattern.substr(2, pattern.length() - 2)
				print('debug: formatted pattern : %s' % '({0})'.format([pattern]))
				delim_rules.append('({0})'.format([pattern]))

				# CONTINUE HERE

		var joined_delim_rules := ''
		for i in range(delim_rules.size()):
			joined_delim_rules += delim_rules[i]
			if i < delim_rules.size():
				joined_delim_rules += '|'

		# create a regex that matches all text up to but not including
		# any of the delimiter rules
		print('debug: joined delim rules: %s' % joined_delim_rules)
		var pattern := '\\G((?!{0}).)*'.format([joined_delim_rules])
		print('debug: final text rule pattern: %s' % pattern)
		var rule := add_transition(type, enters_state)
		rule.regex = RegEx.new()
		rule.regex.compile(pattern)
		rule.is_text_rule = true

		return rule

	func contains_text_rule() -> bool:
		for rule in token_rules:
			if rule.is_text_rule:
				return true
		return false

# single-line comments. if this is encountered at any point, the rest of the
# the line is skipepd
const LINE_COMMENT := '//'

# String -> LexerState
var states: Dictionary

var default_state: LexerState
var current_state: LexerState

# tracks indentation levels and whether an 
# indent token was emitted for each level
# note: use push_back instead of push_front() since push_front() is O(n)
var indentation_stack := [] # stack of [int, bool] pairs
var should_track_next_indentation := false

func _init():
	print('new lexer')

	# TokenType -> String
	var patterns := {}

	patterns[TokenType.TEXT] = '.'
	patterns[TokenType.NUMBER] = '\\-?[0-9]+(\\.[0-9+])?'

	# patterns[TokenType.BEGIN_COMMAND] = '\\<\\<'
	patterns[TokenType.SHORTCUT_OPTION] = '\\-\\>'

	states = {}

	states['base'] = LexerState.new(patterns)
	# states['base'].add_transition(TokenType.BEGINCOMMAND, 'command', true)
	states['base'].add_transition(TokenType.SHORTCUT_OPTION, 'shortcut-option')
	states['base'].add_text_rule(TokenType.TEXT)
	states['shortcut-option'] = LexerState.new(patterns)

	# states['shortcut-option'].add_transition(SHORTCUT_OPTION, 'shortcut-option')



	default_state = states['base']

	for name in states.keys():
		states[name].name = name

# returns Array of Tokens
# title is title of the node
# lines is an array of lines that represents the node body
func tokenize(title: String, lines: Array) -> Array:
	print('tokenizing')

	indentation_stack = [] # stack of <int, bool> 
	indentation_stack.push_back([0, false])
	should_track_next_indentation = false

	var tokens := []

	current_state = default_state

	# add a blank line to ensure that we end with zero indentation
	lines.append('')

	var line_number := 1

	for line in lines:
		tokens += tokenize_line(line, line_number)
		line_number += 1

	var end_of_input = Token.new(TokenType.END_OF_INPUT, current_state,
				line_number, 0)
	tokens.append(end_of_input)

	return tokens


# returns Array of Tokens
func tokenize_line(line: String, line_number: int) -> Array:
	var line_tokens := [] # stack of Tokens

	print('tokenizing line %s' % line)

	# replace tabs with four spaces
	line = line.replace('\t', '    ')

	# strip out \r's
	line = line.replace('\r', '')

	# record the indentation level if the previous state wants us to
	var this_indentation := line_indentation(line)
	print('debug: indentation for line (%s) = %s' % [line, this_indentation])
	var prev_indentation = indentation_stack.back()
	print('debug: prev indentation is %s' % prev_indentation[0])


	if (should_track_next_indentation and 
			this_indentation > prev_indentation[0]):
		indentation_stack.push_back([this_indentation, true])
		var indent := Token.new(TokenType.Indent, current_state,
				line_number, prev_indentation[0])

		# this string magic is making a string of spaces
		# the author of this code is mostly just coping the
		# implementation of C# YarnSpinner circa 2019.
		# i don't know why we're doing this
		var indent_diff = this_indentation - prev_indentation[0]
		var spaces := ''
		for i in indent_diff:
			spaces += ' '
		indent.value = spaces

		should_track_next_indentation = false
		line_tokens.push_back(indent)

	elif this_indentation < prev_indentation[0]:
		# if we are less indented, emit a dedent key for every
		# indentation level that we passed on the way back to 0 that
		# also emitted an indentation token.
		# at the same time, remove thos indent levels from the stack

		while (this_indentation < indentation_stack.back()[0]):
			var top_level = indentation_stack.pop_back()
			if (top_level[1]):
				var dedent := Token.new(TokenType.DETENT,
						current_state, line_number, 0)
				line_tokens.push_back(dedent)


	# now that we're past any initial indentation, start finding tokens
	var col_number := this_indentation
	var whitespace := RegEx.new()
	whitespace.compile('\\s*')

	# debug
	var fake_token = Token.new(TokenType.TEXT, current_state,
			line_number, 0, line)
	line_tokens.append(fake_token)

	while col_number < line.length():
		# if we're about to hit a line comment, abort processing
		# line immediately
		if (line.substr(col_number, 
			line.length() - col_number).begins_with(LINE_COMMENT)):
			break
		
		var matched = false

		# debug
		print('bout to go through rules of state: %s' % current_state.name)
		for rule in current_state.token_rules:
			print('trying to match rule %s' % rule.type)
			var regex_match = rule.regex.search(line, col_number)
			if not regex_match:
				continue
			
			var token_text: String

			if (rule.type == TokenType.TEXT):
				# if this is text, then back up to the most
				# recent text delimitting token, and treat
				# everything from there as text.
				# we do this because we don't want this:
				#    <<flip Harley3 +1>>
				# to get matched as this:
				# BEGIN_COMMAND IDENTIFIER('flip') TEXT('Harley3 +1') END_COMMAND
				# instead, we want to match it as this
				# BEGIN_COMMAND TEXT('flip Harley3 +1') END_COMMAND


				var text_start_idx := this_indentation
				if not line_tokens.empty():
					while (line_tokens.back().type ==
						TokenType.IDENTIFIER):
						line_tokens.pop_back()
					var start_delimiter_token = line_tokens.back()
					text_start_idx = start_delimiter_token.col_number
					if (start_delimiter_token.type == 
						TokenType.INDENT):
						text_start_idx += start_delimiter_token.value.length()
					elif (start_delimiter_token.type ==
						TokenType.DEDENT):
						text_start_idx = this_indentation

				col_number = text_start_idx

				var text_end_idx = regex_match.get_end()
				
				token_text = line.substr(text_start_idx,
						text_end_idx - text_start_idx)
			else:
				token_text = regex_match.get_string()

			col_number += token_text.length()

			# if this was a string, lop off the quotes at the
			# start and end, and un-escape the quotes and slashes
			if (rule.type == TokenType.STRING):
				token_text = token_text.substr(1,
						token_text.length() - 1)
				token_text = token_text.replace('\\\\', '\\')
				token_text = token_text.replace('\\""', '""')

			var token = Token.new(rule.type, current_state,
					line_number, col_number, token_text)

			token.delimits_text = rule.delimits_text

			line_tokens.push_back(token)

			if rule.enters_state:
				if not states.has(rule.enters_state):
					print('(lexer.gd): ERROR: Unknown tokenizer state %s' % rule.enters_state)
				enter_state(states[rule.enters_state])

				if should_track_next_indentation:
					if (indentation_stack.back()[0] <
						this_indentation):
						indentation_stack.push_back(
							[this_indentation, false])

			matched = true
			break

		print('debug: okay done matching rules')
		return line_tokens

		if not matched:
			print('(lexer.gd): ERROR: Didn\'t get expected tokens')


		# consume any lingering whitespace before the next token
		var last_whitespace = whitespace.search(line, col_number)
		if last_whitespace != null:
			col_number += (last_whitespace.get_end() - 
				last_whitespace.get_start())
			
	line_tokens.invert()
	return line_tokens


func line_indentation(line: String) -> int:
	var initial_indent_regex = RegEx.new()
	initial_indent_regex.compile('^(\\s*)')
	var regex_match = initial_indent_regex.search(line)

	if not regex_match:
		return 0

	return regex_match.get_end(0) - regex_match.get_start(0)

func enter_state(state: LexerState):
	current_state = state

	if (current_state.set_track_next_indentation):
		should_track_next_indentation = true



