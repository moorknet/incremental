class_name AttackController
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")

var attack: Attack
var _cooldown_remaining: float = 0.0
var _enemies_node: Node2D
var _projectiles_node: Node2D
var _target: Node2D = null

func _ready() -> void:
	attack = Attack.new()
	attack.base.damage = 8.0
	attack.base.cooldown = 1.2
	GameManager.attack = attack
	if MetaSave.starting_modifier > 0:
		var starters := ModifierRegistry.pick_offers(1)
		if not starters.is_empty():
			attack.add_modifier(starters[0])
			GameManager.notify_modifier_added()

func setup(enemies_node: Node2D, projectiles_node: Node2D) -> void:
	_enemies_node = enemies_node
	_projectiles_node = projectiles_node

func _process(delta: float) -> void:
	if not GameManager.run_active:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		_fire()
	if _enemies_node:
		attack.tick_hooks(delta, _enemies_node)

func _fire() -> void:
	if not is_instance_valid(_target):
		_target = _find_nearest_enemy()
	if not _target:
		return

	var final_stats := attack.compute_stats()
	_cooldown_remaining = final_stats.cooldown
	attack.fire_hooks(final_stats)

	var dir := (_target.global_position - global_position).normalized()
	for i in final_stats.count:
		var spread := 0.0
		if final_stats.count > 1:
			spread = deg_to_rad((i - (final_stats.count - 1) * 0.5) * 8.0)
		_spawn_projectile(final_stats, dir.rotated(spread))

func _spawn_projectile(final_stats: AttackStats, dir: Vector2) -> void:
	var p: Projectile = PROJECTILE_SCENE.instantiate()
	_projectiles_node.add_child(p)
	p.global_position = global_position
	p.init(final_stats, dir, attack)

func _find_nearest_enemy() -> Node2D:
	if not _enemies_node:
		return null
	var nearest: Node2D = null
	var nearest_dist := INF
	for child in _enemies_node.get_children():
		if not child is Node2D or not (child as Node2D).is_in_group("enemies"):
			continue
		var d := global_position.distance_to((child as Node2D).global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = child
	return nearest
