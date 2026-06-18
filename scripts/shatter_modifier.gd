class_name ShatterModifier
extends Modifier

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")

func get_card_description() -> String:
	return "Ice burst.\nFrozen enemies shatter into %d shards on death" % maxi(4, int(rolled_value))

func on_kill(target: Node2D, stats: AttackStats) -> void:
	if not target.get("is_frozen"):
		return
	if not is_instance_valid(GameManager.projectiles_node):
		return
	var shard_count := maxi(4, int(rolled_value))
	var shard_stats := stats.clone()
	shard_stats.damage = maxf(3.0, 3.0 + MetaSave.frost_power * 2.0)
	shard_stats.pierce = 0
	shard_stats.bounce = 0
	for i in shard_count:
		var angle := (TAU / shard_count) * i
		var shard: Projectile = PROJECTILE_SCENE.instantiate()
		GameManager.projectiles_node.add_child(shard)
		shard.global_position = target.global_position
		shard.init(shard_stats, Vector2(cos(angle), sin(angle)))
