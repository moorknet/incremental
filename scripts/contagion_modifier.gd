class_name ContagionModifier
extends Modifier

var _timer: float = 0.0
const INTERVAL := 1.0

func get_card_description() -> String:
	return "The plague spreads.\nPoison spreads to nearby enemies (%.0f range)" % rolled_value

func on_tick(delta: float, enemies_node: Node2D) -> void:
	if not enemies_node:
		return
	_timer += delta
	if _timer < INTERVAL:
		return
	_timer = 0.0
	var spread_range: float = rolled_value
	var children := enemies_node.get_children()
	for enemy in children:
		if not enemy.is_in_group("enemies") or enemy.get("poison_stacks") <= 0:
			continue
		for other in children:
			if other == enemy or not other.is_in_group("enemies"):
				continue
			if enemy.global_position.distance_to(other.global_position) < spread_range:
				if other.has_method("apply_poison"):
					other.apply_poison(1)
