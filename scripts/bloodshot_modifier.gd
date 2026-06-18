class_name BloodshotModifier
extends Modifier

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const BULLET_COUNT := 4

func get_card_description() -> String:
	return "Death burst.\n%d%% chance on kill to fire %d bullets" % [int(rolled_value * 100), BULLET_COUNT]

func on_kill(target: Node2D, stats: AttackStats) -> void:
	if not is_instance_valid(GameManager.projectiles_node):
		return
	if randf() > rolled_value:
		return
	var bullet_stats := stats.clone()
	bullet_stats.damage = maxf(1.0, stats.damage * 0.1)  # 10% weapon damage
	bullet_stats.pierce = 0
	bullet_stats.bounce = 0
	# Inherit the player's attack so bullets chain elemental effects at 10% scale
	var atk: Variant = GameManager.attack
	var offset := randf() * TAU
	for i in BULLET_COUNT:
		var angle := offset + (TAU / BULLET_COUNT) * i
		var proj: Projectile = PROJECTILE_SCENE.instantiate()
		GameManager.projectiles_node.add_child(proj)
		proj.global_position = target.global_position
		proj.init(bullet_stats, Vector2(cos(angle), sin(angle)), atk)
