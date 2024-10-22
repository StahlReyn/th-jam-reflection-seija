extends Node

var file_score = "user://scores.save"

func test_data():
	var save_dict = {
		"name" : "Name Here",
		"score" : 1234567890,
	}
	return save_dict

func save_scores():
	var save_file = FileAccess.open(file_score, FileAccess.WRITE)
	var node_data = test_data()
	var json_string = JSON.stringify(node_data)

	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	save_file.store_line(json_string)

func load_scores():
	if not FileAccess.file_exists(file_score):
		return

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(file_score, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.data
		return node_data
		#for i in node_data.keys():
