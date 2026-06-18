class_name FrenzyModifier
extends Modifier

func get_card_description() -> String:
	return "Wave Frenzy.\n-%.3fs cooldown per wave (now wave %d)" % [rolled_value, GameManager.wave]

func on_compute_stats(stats: AttackStats) -> void:
	stats.cooldown = maxf(0.05, stats.cooldown - rolled_value * GameManager.wave)
