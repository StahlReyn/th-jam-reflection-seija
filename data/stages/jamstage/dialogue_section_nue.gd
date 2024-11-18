extends SectionDialogueScript

@onready var set_1 : DialogueSet = preload("dialogue_nue.tres")

func _ready() -> void:
	super()
	dialogue_set = set_1
	start_section()

func _physics_process(delta: float) -> void:
	super(delta)
