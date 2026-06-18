class_name ConflagrationModifier
extends Modifier

var _timer: float = 0.0
const INTERVAL := 0.8

func get_card_description() -> String:
	return "Spreading inferno.\nBurning enemies ignite nearby (aura +%.0fpx)" % rolled_value

func on_tick(delta: float, enemies_node: Node2D) -> void:
	if not enemies_node:
		return
	_timer += delta
	if _timer < INTERVAL:
		return
	_timer = 0.0
	var aura := 50.0 + rolled_value
	var children := enemies_node.get_children()
	for enemy in children:
		if not enemy.is_in_group("enemies") or enemy.get("burn_stacks") <= 0:
			continue
		for other in children:
			if other == enemy or not other.is_in_group("enemies"):
				continue
			if enemy.global_position.distance_to(other.global_position) < aura:
				if other.has_method("apply_burn"):
					other.apply_burn(1)
