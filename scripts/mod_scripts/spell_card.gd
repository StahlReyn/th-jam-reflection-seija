class_name SpellCard
extends SectionScript
## Spellcard is more specific type of section script
## Non-spells are still Section script, despite boss existing

# var count_capture : int = 0
# var count_attempt : int = 0
# Duration is part of section already

func _ready() -> void:
	print_rich("[color=green]==== Spell Card Script ====[/color]")
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func start_section() -> void:
	super()
	var displayer : SpellCardDisplayer = GameUtils.get_spell_card_displayer()
	displayer.start_spellcard()

func update_displayer() -> void:
	var displayer : SpellCardDisplayer = GameUtils.get_spell_card_displayer()
	displayer.set_spellcard(self)
