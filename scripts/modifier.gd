class_name Modifier
extends Resource

enum RollCurve { LINEAR, WEIGHTED_HIGH }

@export var id: StringName = &""
@export var display_name: String = ""
@export var description_template: String = ""
@export var tier: int = 1
@export var roll_min: float = 0.0
@export var roll_max: float = 0.0
@export var roll_curve: RollCurve = RollCurve.LINEAR
@export var stat_mods: Dictionary = {}
@export var tags: Array[StringName] = []

# On-kill flat effects (no hook subclass needed for simple cases)
@export var meta_per_kill: int = 0
@export var timer_per_kill: float = 0.0

# Baked in at offer time
var rolled_value: float = 0.0

func roll(rng: RandomNumberGenerator, luck_level: int) -> void:
	var n := 1 + int(luck_level / 5.0)
	var best := 0.0
	for i in n:
		best = max(best, rng.randf())
	rolled_value = lerpf(roll_min, roll_max, best)

func get_card_description() -> String:
	if description_template.is_empty():
		return display_name
	return description_template.replace("{v}", "%.2f" % rolled_value)

func has_tag(tag: StringName) -> bool:
	return tags.has(tag)

func on_compute_stats(_stats: AttackStats) -> void:
	pass

func on_fire(_stats: AttackStats) -> void:
	pass

func on_hit(_target: Node2D, _stats: AttackStats, _is_crit: bool = false) -> void:
	pass

func on_kill(_target: Node2D, _stats: AttackStats) -> void:
	pass

func on_tick(_delta: float, _enemies_node: Node2D) -> void:
	pass
