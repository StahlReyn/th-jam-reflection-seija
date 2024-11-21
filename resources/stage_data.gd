class_name StageData
extends Resource

@export var stage_number : int
@export_enum("EASY","NORMAL","HARD","LUNATIC") var stage_difficulty : int
@export var stage_actions : Array[StageAction]

#"EASY","NORMAL","HARD","LUNATIC"
