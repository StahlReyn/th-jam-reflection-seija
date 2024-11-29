class_name StageData
extends Resource

@export var stage_number : int
@export_enum("EASY","NORMAL","HARD","LUNATIC") var stage_difficulty : int
@export var start_index : int = 0 ## THIS IS FOR DEBUGGING PURPOSES
@export var start_power : int = 0 ## THIS IS FOR DEBUGGING PURPOSES
@export var stage_actions : Array[StageAction]
