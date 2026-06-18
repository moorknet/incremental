class_name OverchargeModifier
extends Modifier

func get_card_description() -> String:
	return "Lightning arc.\nArcs to %d nearby enemies on hit (×2 on crit)" % maxi(1, int(rolled_value))

func on_hit(target: Node2D, stats: AttackStats, is_crit: bool = false) -> void:
	if not is_instance_valid(GameManager.enemies_node):
		return
	var arc_count := maxi(1, int(rolled_value))
	if is_crit:
		arc_count *= 2

	# Collect all other enemies and sort by distance from the struck target
	var candidates: Array = []
	for enemy in GameManager.enemies_node.get_children():
		if enemy.is_in_group("enemies") and enemy != target:
			candidates.append(enemy)
	candidates.sort_custom(func(a, b):
		return target.global_position.distance_to(a.global_position) \
			 < target.global_position.distance_to(b.global_position)
	)

	var base_dmg := stats.damage * 0.6 * (1.0 + MetaSave.shock_power)
	for i in mini(arc_count, candidates.size()):
		var enemy = candidates[i]
		# Superconduction: arc hits much harder on cold/frozen targets
		var cold_mult: float
		if enemy.get("is_frozen"):
			cold_mult = 2.0
		elif enemy.get("cold_stacks") > 0:
			cold_mult = 1.5
		else:
			cold_mult = 1.0
		if enemy.has_method("take_damage"):
			enemy.take_damage(base_dmg * cold_mult, stats, false)
