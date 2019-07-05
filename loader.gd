
class_name Loader

var Dialogue = load('res://addons/yarnspinner/dialogue.gd')

var dialogue
var lexer: Lexer

class NodeInfo:
	# the node's title
	var title: String

	# list of tags (optional)
	var tags: Array

	# an array of strings where each string is a line from the node
	var lines: Array


	func _init(title: String, tags: Array, lines: Array) -> void:
		self.title = title
		self.tags = tags
		self.lines = lines


# todo: make this static typing when they resolve
# https://github.com/godotengine/godot/issues/28010
func _init(dialogue) -> void:
	if not dialogue:
		print('todo: handle not providing dialogue')

	self.dialogue = dialogue

func print_tokens(tokens: Array) -> void:
	for token in tokens:
		print(token.to_str())

func print_parse_tree(root: Parser.ParseNode) -> void:
	print('parse tree:')
	print(root.print_tree(0))

# builds a NodeInfo from a file that should currently be reading from the
# beginning of a node in a .yarn.txt file
# returns false if node parsed unsucessfully
func parse_node(file : File) -> NodeInfo:
	var title := ''
	var tags := []
	var lines := []

	# parse metadata
	var line := ''
	while not file.eof_reached():
		line = file.get_line()
		if line == '---':
			break
		elif line.begins_with('title: '):
			title = line.split(': ')[1]
		elif line.begins_with('tags: '):
			# this is not right
			tags = line.split(' ')
			print('unimplemented: tags')

	if not title:
		print('error: all nodes must have a title')
		return null

	# parse body
	while not file.eof_reached():
		line = file.get_line()
		if line == '===':
			break
		lines.append(line)
	
	return NodeInfo.new(title, tags, lines)

# returns Array of NodeInfos
func get_nodes_from_text(text: String) -> Array: # NodeInfos
	var nodes := [] # NodeInfos
	var lines := text.split('\n')
	
	# temp vars for things were parsing from the node
	var title: String
	var tags := [] # Strings
	var statements := [] # Strings

	var in_header = true
	for line in lines:
		if in_header:
			if line == '---':
				# reached end of header
				in_header = false
			elif line.begins_with('title: '):
				title = line.split(': ')[1]
			elif line.begins_with('tags: '):
				# this is not right
				tags = line.split(' ')
				print('unimplemented: tags')
		else: # in body
			if line == '===':
				# reached end of body
				in_header = true
				nodes.append(NodeInfo.new(
					title, tags, statements))
				title = ''
				tags = []
				statements = []
			else:
				statements.append(line)
	return nodes



func load(file_name: String) -> Program:
	# String -> Parser.YarnNode
	var nodes := {}	

	var file := File.new()
	file.open(file_name, file.READ)
	if not file.is_open():
		print('todo: handle error parsing file')

	# var node_infos := get_nodes_from_file(file_name)
	var node_infos := get_nodes_from_text(file.get_as_text())
	var nodes_loaded := 0

	lexer = Lexer.new()
	var tokens: Array

	for node_info in node_infos:
		tokens = lexer.tokenize(node_info.title, node_info.lines)
		print_tokens(tokens)
		var node := Parser.new(tokens).parse()
		node.name = node_info.title

		print_parse_tree(node)

		nodes[node_info.title] = node
		nodes_loaded += 1

	var compiler = Compiler.new()

	for node in nodes.values():
		compiler.compile_node(node)


	return compiler.program
