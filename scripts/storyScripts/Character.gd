class_name Character
extends Node

enum Name{
	DAYOFLOVE,
	DAYAFTERLOVE,
	DAYBEFORELOVE, 
	BEYONDREACH
}

const CHARACTER_DETAILS: Dictionary = {
	Name.DAYOFLOVE: {
		"name": "Day Of Love",
		"gender": "female", 
		##to be changed l8r 
		"expressions": {
				"excited": preload("res://assets/sprites/DayOfLove/excited.png"), 
				"normal": preload("res://assets/sprites/DayOfLove/normal.png")
		}
	},
	Name.DAYAFTERLOVE: {
		"name": "Day After Love",
		"gender": "female",
		##tobe changed l8r
		"expressions": {
			"normal": preload("res://assets/sprites/DayAfterLove/normal.png")
		}
	},
	Name.DAYBEFORELOVE: {
		"name": "Day Before Love",
		"gender": "female", 
		"expressions": {
			"normal": null
		}
	},
	Name.BEYONDREACH: {
		"name": "Beyond Reach", 
		"gender": "female", 
		"expressions": {
			"normal": null
		}
	}
}

static func get_enum_from_string(string_value: String) -> int: 
	var upper_string = string_value.to_upper().replace(" ", "")
	if Name.has(upper_string):
		return Name[upper_string]
	else: 
		push_error("Invalid Character Name: " + string_value)
		return -1
		

#static func preload_expressions(filePath: String) -> Dictionary: 
#	var expressions := {}
#	
	#check if the filePath is null 
#	if filePath == "": 
#		push_warning("no files provided")
#		return expressions
	#open folder at given path 
#	var dir := DirAccess.open(filePath)
#	if dir:  # Check if the folder exists
#		dir.list_dir_begin()  # Initialize reading the directory
#		var file_name = dir.get_next()  # Get the first file in the folder
#		while file_name != "":  # Loop until there are no more files
#			if not dir.current_is_dir() and file_name.get_extension() in ["png", "jpg", "webp", "tres"]:  
#				# Check if it is a file and has a valid image
#				var expression_name = file_name.get_basename()  
#				# Use the file name without extension as the key (e.g., "happy" from "happy.png")
#				var resource_path = filePath + "/" + file_name  # Full path to the file
#				expressions[expression_name] = load(resource_path)  
#				# Preload the resource and store it in the dictionary
#			file_name = dir.get_next()  # Move to the next file
#			dir.list_dir_end()  
#	return expressions

#if the expressions are few, can just preload n be done with it 
