class_name ChainModifier
extends Modifier

func get_card_description() -> String:
	return "Chain hit.\nHit chains to 1 nearby enemy for %d%% damage" % int(rolled_value * 100)

func on_hit(target: Node2D, stats: AttackStats, _is_crit: bool = false) -> void:
	if not is_instance_valid(GameManager.enemies_node):
		return
	# Find nearest enemy that isn't the one we just hit
	var nearest: Node2D = null
	var nearest_dist := INF
	for enemy in GameManager.enemies_node.get_children():
		if not enemy.is_in_group("enemies") or enemy == target:
			continue
		var d := target.global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy
	if nearest and nearest.has_method("take_damage"):
		nearest.take_damage(stats.damage * rolled_value, stats, false)
