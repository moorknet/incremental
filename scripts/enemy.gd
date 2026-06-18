class_name Enemy
extends CharacterBody2D

const DAMAGE_NUMBER_SCENE := preload("res://scenes/damage_number.tscn")
const DOT_INTERVAL := 0.5

var hp: float = 30.0
var move_speed: float = 60.0
var _base_move_speed: float = 60.0
var xp_value: int = 5
var meta_value: int = 1
var _target_pos: Vector2

# Elemental state
var poison_stacks: int = 0
var _poison_timer: float = 0.0

var burn_stacks: int = 0
var _burn_timer: float = 0.0

var cold_stacks: int = 0
var is_frozen: bool = false

var bleed_stacks: int = 0
var bleed_time_elapsed: float = 0.0
var _bleed_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_base_move_speed = move_speed

func init(target_position: Vector2) -> void:
	_target_pos = target_position

func _physics_process(_delta: float) -> void:
	if not GameManager.run_active:
		return
	if is_frozen:
		velocity = Vector2.ZERO
	else:
		var dir := (_target_pos - global_position).normalized()
		velocity = dir * move_speed
	move_and_slide()

func _process(delta: float) -> void:
	if not GameManager.run_active or hp <= 0.0:
		return
	_tick_dots(delta)
	_update_visual()

func _tick_dots(delta: float) -> void:
	if poison_stacks > 0:
		_poison_timer += delta
		if _poison_timer >= DOT_INTERVAL:
			_poison_timer = 0.0
			take_dot_damage(poison_stacks * (0.5 + MetaSave.poison_power), "poison")

	if burn_stacks > 0:
		_burn_timer += delta
		if _burn_timer >= DOT_INTERVAL:
			_burn_timer = 0.0
			# Burning Venom: fire deals 2× to poisoned enemies
			var burn_mult := 2.0 if poison_stacks > 0 else 1.0
			take_dot_damage(burn_stacks * (1.5 + MetaSave.burn_power) * burn_mult, "burn")
			burn_stacks = max(0, burn_stacks - 1)  # fire fades — reapply to sustain

	if bleed_stacks > 0:
		bleed_time_elapsed += delta
		_bleed_timer += delta
		if _bleed_timer >= DOT_INTERVAL:
			_bleed_timer = 0.0
			var ramp := 1.0 + bleed_time_elapsed * 0.25
			take_dot_damage(bleed_stacks * (1.5 + MetaSave.bleed_power) * ramp, "bleed")

func apply_poison(stacks: int) -> void:
	# Septic: bleeding targets absorb more poison
	var mult := 1.5 if bleed_stacks > 0 else 1.0
	poison_stacks += int(stacks * mult)

func apply_burn(stacks: int) -> void:
	# Burning Venom: poisoned targets ignite harder
	var mult := 2 if poison_stacks > 0 else 1
	burn_stacks += stacks * mult

func apply_cold(stacks: int) -> void:
	cold_stacks += stacks
	# 20% slow per stack, capped at 90%; freeze at 3 stacks
	var slow := minf(cold_stacks * 0.20, 0.9)
	move_speed = _base_move_speed * (1.0 - slow)
	if cold_stacks >= 3 and not is_frozen:
		is_frozen = true
		move_speed = 0.0

func apply_bleed(stacks: int) -> void:
	# Frostbleed: cold/frozen targets bleed much harder
	if is_frozen:
		bleed_stacks += stacks * 3
	elif cold_stacks > 0:
		bleed_stacks += stacks * 2
	else:
		bleed_stacks += stacks

func take_damage(amount: float, _stats: AttackStats, is_crit: bool = false) -> void:
	if hp <= 0.0:
		return
	GameManager.record_damage(amount)
	_spawn_damage_number(amount, is_crit, "")
	hp -= amount
	if hp <= 0.0:
		_die()

func take_dot_damage(amount: float, element: String) -> void:
	if hp <= 0.0:
		return
	GameManager.record_damage(amount)
	_spawn_damage_number(amount, false, element)
	hp -= amount
	if hp <= 0.0:
		_die()

func _spawn_damage_number(amount: float, is_crit: bool, element: String) -> void:
	if not GameManager.damage_numbers_node:
		return
	var dn: DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	GameManager.damage_numbers_node.add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-10.0, 10.0), -14.0)
	dn.init(amount, is_crit, element)

func _update_visual() -> void:
	if is_frozen:
		modulate = Color(0.55, 0.88, 1.0)
	elif cold_stacks > 0:
		modulate = Color(0.72, 0.88, 1.0)
	elif poison_stacks > 0 and burn_stacks > 0:
		modulate = Color(0.78, 0.88, 0.25)
	elif poison_stacks > 0:
		modulate = Color(0.5, 1.0, 0.45)
	elif burn_stacks > 0:
		modulate = Color(1.0, 0.52, 0.15)
	elif bleed_stacks > 0:
		modulate = Color(1.0, 0.28, 0.28)
	else:
		modulate = Color.WHITE

func _die() -> void:
	GameManager.record_kill()
	GameManager.add_xp(xp_value)
	GameManager.add_meta(meta_value)
	if GameManager.attack:
		var atk := GameManager.attack as Attack
		var final_stats := atk.compute_stats()
		for mod in atk.modifiers:
			if mod.meta_per_kill > 0:
				GameManager.add_meta(mod.meta_per_kill)
			if mod.timer_per_kill < 0.0:
				GameManager.add_timer(mod.rolled_value)
			elif mod.timer_per_kill > 0.0:
				GameManager.add_timer(mod.timer_per_kill)
		atk.kill_hooks(self, final_stats)
	queue_free()
