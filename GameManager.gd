extends Node2D

@export var word_manager: WordManager
@export var player: Player
@export var incantation_label: RichTextLabel
@export var spell_selection_container: Container
@export var spell_selection_item_prefab: PackedScene

func _ready():
	var spells_table: Array[String] = []
	
	for spell_id in DB.spells.get_all_ids():
		spells_table.append_array(DB.spells.get_value(spell_id).keywords)
	print(spells_table)
	word_manager.init(spells_table)

func _on_typed_input_receiver_input_updated(str: String):
	incantation_label.set_text("[center]" + str)

func _on_word_manager_on_match_found(word):
	var default_color := incantation_label.modulate
	incantation_label.set_modulate(Color.WHITE)
	var tween := get_tree().create_tween()
	tween.tween_property(incantation_label, "modulate", Color(1, 1, 1, .1), 0)
	tween.tween_callback(func(): incantation_label.set_modulate(default_color))
	
	DB.spells.get_from_keyword(word).cast(player)

func _on_word_manager_word_selection_word_added(word):
	var o := spell_selection_item_prefab.instantiate()
	(o as SpellSelectionItem).spell = word
	word_manager.typed_input_updated.connect((o as SpellSelectionItem).compare_and_highlight)
	spell_selection_container.add_child(o)

func _on_word_manager_word_selection_remove_at(index):
	spell_selection_container.remove_child(spell_selection_container.get_child(index))

func _on_word_manager_word_selection_modified(index, new_word):
	(spell_selection_container.get_child(index) as SpellSelectionItem).spell = new_word
