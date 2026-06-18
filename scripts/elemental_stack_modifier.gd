class_name ElementalStackModifier
extends Modifier

@export var element: String = "poison"

func get_card_description() -> String:
	if description_template.is_empty():
		return display_name
	return description_template.replace("{v}", "%d" % maxi(1, int(rolled_value)))

func on_hit(target: Node2D, _stats: AttackStats, _is_crit: bool = false) -> void:
	var stacks := maxi(1, int(rolled_value))
	match element:
		"poison": if target.has_method("apply_poison"): target.apply_poison(stacks)
		"burn":   if target.has_method("apply_burn"):   target.apply_burn(stacks)
		"cold":   if target.has_method("apply_cold"):   target.apply_cold(stacks)
		"bleed":  if target.has_method("apply_bleed"):  target.apply_bleed(stacks)
