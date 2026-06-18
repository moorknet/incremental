class_name Projectile
extends Area2D

var stats: AttackStats
var direction: Vector2
var distance_traveled: float = 0.0
var pierce_remaining: int = 0
var bounce_remaining: int = 0
var hit_enemies: Array[Node2D] = []
var _attack: Variant = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func init(p_stats: AttackStats, p_direction: Vector2, p_attack: Variant = null) -> void:
	stats = p_stats
	direction = p_direction.normalized()
	pierce_remaining = stats.pierce
	bounce_remaining = stats.bounce
	_attack = p_attack

func _process(delta: float) -> void:
	var move := direction * stats.speed * delta
	position += move
	distance_traveled += move.length()
	if distance_traveled >= stats.range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in hit_enemies:
		return
	hit_enemies.append(body)
	if body.has_method("take_damage"):
		var is_crit := randf() < stats.crit_chance
		var dmg := stats.damage * (stats.crit_multiplier if is_crit else 1.0)
		body.take_damage(dmg, stats, is_crit)
		if _attack:
			(_attack as Attack).hit_hooks(body, stats, is_crit)

	if pierce_remaining <= 0:
		if bounce_remaining > 0:
			_do_bounce()
		else:
			queue_free()
	else:
		pierce_remaining -= 1

func _do_bounce() -> void:
	bounce_remaining -= 1
	if not is_instance_valid(GameManager.enemies_node):
		queue_free()
		return
	var nearest: Node2D = null
	var nearest_dist := INF
	for enemy in GameManager.enemies_node.get_children():
		if not enemy.is_in_group("enemies") or enemy in hit_enemies:
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy
	if nearest:
		direction = (nearest.global_position - global_position).normalized()
		distance_traveled = 0.0
	else:
		queue_free()
