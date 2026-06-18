class_name OutbreakModifier
extends Modifier

const RADIUS := 100.0
const STACKS := 3

func get_card_description() -> String:
	return "On kill: spread %d poison stacks\nto enemies within %dpx" % [STACKS, int(RADIUS)]

func on_kill(target: Node2D, _stats: AttackStats) -> void:
	if not is_instance_valid(GameManager.enemies_node):
		return
	var origin := target.global_position
	for enemy in GameManager.enemies_node.get_children():
		if not is_instance_valid(enemy):
			continue
		if not enemy.is_in_group("enemies"):
			continue
		if enemy == target:
			continue
		if enemy.global_position.distance_to(origin) <= RADIUS:
			if enemy.has_method("apply_poison"):
				enemy.apply_poison(STACKS)
