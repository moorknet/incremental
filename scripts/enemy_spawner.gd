class_name EnemySpawner
extends Node2D

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

@export var arena_size: Vector2 = Vector2(800, 500)

var _timer: float = 0.0
var _wave: int = 0
var _player_corner: Vector2
var _enemies_node: Node2D

func setup(player_corner: Vector2, enemies_node: Node2D) -> void:
	_player_corner = player_corner
	_enemies_node = enemies_node

func _process(delta: float) -> void:
	if not GameManager.run_active:
		return
	_timer -= delta
	if _timer <= 0.0:
		_spawn_wave()
		# Spawn interval shrinks each wave: 2.0s → 0.4s floor over ~40 waves
		_timer = maxf(0.4, 2.0 - _wave * 0.04)

func _spawn_wave() -> void:
	_wave += 1
	GameManager.wave = _wave
	GameManager.wave_changed.emit(_wave)

	var count := 1 + int(_wave / 3)
	var hp_scale := 1.0 + (_wave - 1) * 0.15
	var speed_scale := 1.0 + (_wave - 1) * 0.025
	var xp_bonus := int((_wave - 1) * 0.4)      # +0.4 XP per wave
	var meta_bonus := int((_wave - 1) * 0.15)   # +0.15 meta per wave

	for i in count:
		_spawn_one(hp_scale, speed_scale, xp_bonus, meta_bonus)

func _spawn_one(hp_scale: float, speed_scale: float, xp_bonus: int, meta_bonus: int) -> void:
	var e: Enemy = ENEMY_SCENE.instantiate()
	_enemies_node.add_child(e)
	e.hp *= hp_scale
	e.move_speed *= speed_scale
	e._base_move_speed = e.move_speed
	e.xp_value += xp_bonus
	e.meta_value = max(1, e.meta_value + meta_bonus)
	e.global_position = _random_edge_position()
	e.init(_player_corner)

func _random_edge_position() -> Vector2:
	var edge := randi() % 4
	match edge:
		0: return Vector2(randf_range(0, arena_size.x), 0)
		1: return Vector2(randf_range(0, arena_size.x), arena_size.y)
		2: return Vector2(0, randf_range(0, arena_size.y))
		_: return Vector2(arena_size.x, randf_range(0, arena_size.y))
