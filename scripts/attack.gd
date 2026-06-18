class_name Attack
extends Resource

var base: AttackStats = AttackStats.new()
var modifiers: Array[Modifier] = []

func add_modifier(mod: Modifier) -> void:
	modifiers.append(mod)

func compute_stats() -> AttackStats:
	var stats := base.clone()
	stats.damage += MetaSave.base_damage_bonus
	stats.cooldown = max(0.05, stats.cooldown - MetaSave.base_cooldown_reduction)
	for mod in modifiers:
		_apply_stat_mod(stats, mod)
		mod.on_compute_stats(stats)
	return stats

func _apply_stat_mod(stats: AttackStats, mod: Modifier) -> void:
	for stat_name in mod.stat_mods:
		var entry = mod.stat_mods[stat_name]
		var op := "add"
		var value := mod.rolled_value
		if entry is Dictionary:
			op = entry.get("op", "add")
			# "value" key overrides; omit it to use rolled_value
			value = entry.get("value", mod.rolled_value)
		else:
			value = mod.rolled_value * float(entry)
		_apply_op(stats, stat_name, op, value)

func _apply_op(stats: AttackStats, prop: String, op: String, value: float) -> void:
	var current: Variant = stats.get(prop)
	var result: float
	match op:
		"add": result = float(current) + value
		"sub": result = float(current) - value
		"mul": result = float(current) * value
		_:     result = float(current) + value
	# Preserve int type for count/pierce/bounce/chain
	if current is int:
		stats.set(prop, roundi(result))
	else:
		stats.set(prop, result)

func fire_hooks(final_stats: AttackStats) -> void:
	for mod in modifiers:
		mod.on_fire(final_stats)

func hit_hooks(target: Node2D, stats: AttackStats, is_crit: bool) -> void:
	for mod in modifiers:
		mod.on_hit(target, stats, is_crit)

func kill_hooks(target: Node2D, stats: AttackStats) -> void:
	for mod in modifiers:
		mod.on_kill(target, stats)

func tick_hooks(delta: float, enemies_node: Node2D) -> void:
	for mod in modifiers:
		mod.on_tick(delta, enemies_node)
