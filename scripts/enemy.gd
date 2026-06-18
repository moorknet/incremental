class_name Enemy
extends CharacterBody2D

const DAMAGE_NUMBER_SCENE := preload("res://scenes/damage_number.tscn")
const DOT_INTERVAL := 0.5

var hp: float = 30.0
var move_speed: float = 60.0
var _base_move_speed: float = 60.0
var xp_value: int = 5
var meta_value: int = 1
var contact_damage: float = 5.0
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

# ── Drawing constants — Frostlight Shard (enemy rose triad) ───────────
const _C_BASE   := Color("#DA5168")
const _C_LIGHT  := Color("#ED8497")
const _C_DARK   := Color("#A8324A")
const _SHADOW_C := Color(0.110, 0.165, 0.243, 0.18)

# Shard facet vertices (32w × 33h) offset -8 up to match old rect centering
const _SHARD_TOP   := Vector2(0.0,  -25.0)
const _SHARD_LEFT  := Vector2(-12.0, -9.0)
const _SHARD_RIGHT := Vector2(12.0,  -9.0)
const _SHARD_BOT   := Vector2(0.0,    8.0)
const _SY_TOP      := -25.0
const _SY_BOT      :=   8.0

func _ready() -> void:
	add_to_group("enemies")
	_base_move_speed = move_speed

func init(target_position: Vector2) -> void:
	_target_pos = target_position

func _physics_process(delta: float) -> void:
	if not GameManager.run_active:
		return
	if is_frozen:
		velocity = Vector2.ZERO
	else:
		var dir := (_target_pos - global_position).normalized()
		velocity = dir * move_speed
	move_and_slide()
	if global_position.distance_to(_target_pos) < 30.0:
		GameManager.damage_player(contact_damage * delta)

func _process(delta: float) -> void:
	if not GameManager.run_active or hp <= 0.0:
		return
	_tick_dots(delta)
	queue_redraw()

# ── Elemental DoT ──────────────────────────────────────────────────────

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
			var burn_mult := 2.0 if poison_stacks > 0 else 1.0
			take_dot_damage(burn_stacks * (1.5 + MetaSave.burn_power) * burn_mult, "burn")
			burn_stacks = max(0, burn_stacks - 1)

	if bleed_stacks > 0:
		bleed_time_elapsed += delta
		_bleed_timer += delta
		if _bleed_timer >= DOT_INTERVAL:
			_bleed_timer = 0.0
			var ramp := 1.0 + bleed_time_elapsed * 0.25
			take_dot_damage(bleed_stacks * (1.5 + MetaSave.bleed_power) * ramp, "bleed")

func apply_poison(stacks: int) -> void:
	var mult := 1.5 if bleed_stacks > 0 else 1.0
	poison_stacks += int(stacks * mult)

func apply_burn(stacks: int) -> void:
	var mult := 2 if poison_stacks > 0 else 1
	burn_stacks += stacks * mult

func apply_cold(stacks: int) -> void:
	cold_stacks += stacks
	var slow := minf(cold_stacks * 0.20, 0.9)
	move_speed = _base_move_speed * (1.0 - slow)
	if cold_stacks >= 3 and not is_frozen:
		is_frozen = true
		move_speed = 0.0

func apply_bleed(stacks: int) -> void:
	if is_frozen:
		bleed_stacks += stacks * 3
	elif cold_stacks > 0:
		bleed_stacks += stacks * 2
	else:
		bleed_stacks += stacks

# ── Damage & death ────────────────────────────────────────────────────

func take_damage(amount: float, _stats: AttackStats, is_crit: bool = false) -> void:
	if hp <= 0.0:
		return
	GameManager.record_damage(amount)
	_spawn_damage_number(amount, is_crit, "")
	hp -= amount
	# Hit flash
	modulate = Color(2.4, 2.4, 2.4)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.09)
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

# ── Frostlight entity drawing ─────────────────────────────────────────

func _draw() -> void:
	# Ground shadow ellipse
	var sh_pts := PackedVector2Array()
	var sh_cols := PackedColorArray()
	for i in 14:
		var a := i * TAU / 14.0
		sh_pts.append(Vector2(cos(a) * 10.0, 10.0 + sin(a) * 2.5))
		sh_cols.append(_SHADOW_C)
	draw_polygon(sh_pts, sh_cols)

	# Gradient values for each facet
	var g_dt := _C_BASE.lerp(_C_DARK, 0.45)   # dark facet top

	# Dark facet (left)
	var pts_d := PackedVector2Array([_SHARD_TOP, _SHARD_LEFT, _SHARD_BOT])
	draw_polygon(pts_d, _sfc(pts_d, g_dt, _C_DARK))

	# Light facet (right)
	var pts_l := PackedVector2Array([_SHARD_TOP, _SHARD_RIGHT, _SHARD_BOT])
	draw_polygon(pts_l, _sfc(pts_l, _C_LIGHT, _C_BASE))

	# Element aura (soft halo ring)
	var aura := _aura_color()
	if aura.a > 0.0:
		var aura_fill := aura
		aura_fill.a = 0.18
		var ap := PackedVector2Array()
		var ac := PackedColorArray()
		for i in 18:
			var angle := i * TAU / 18.0
			ap.append(Vector2(cos(angle) * 19.0, -8.0 + sin(angle) * 23.0))
			ac.append(aura_fill)
		draw_polygon(ap, ac)
		# Facet outline
		draw_polyline(PackedVector2Array([
			_SHARD_TOP, _SHARD_LEFT, _SHARD_BOT, _SHARD_RIGHT, _SHARD_TOP
		]), aura, 1.4, true)

	# Core gem
	var core_pts := PackedVector2Array([
		Vector2(0.0, -13.0), Vector2(4.0, -8.0), Vector2(0.0, -3.0), Vector2(-4.0, -8.0)
	])
	var core_cols := PackedColorArray()
	for i in 4:
		core_cols.append(Color(1.0, 1.0, 1.0, 0.75))
	draw_polygon(core_pts, core_cols)

	# Status pips
	_draw_pips()

func _sfc(pts: PackedVector2Array, c_top: Color, c_bot: Color) -> PackedColorArray:
	var cols := PackedColorArray()
	for v in pts:
		var t := clampf((v.y - _SY_TOP) / (_SY_BOT - _SY_TOP), 0.0, 1.0)
		cols.append(c_top.lerp(c_bot, t))
	return cols

func _aura_color() -> Color:
	if is_frozen:
		return Color("#9AD6EE")
	if cold_stacks > 0:
		return Color("#3F9BD6")
	if poison_stacks > 0 and burn_stacks > 0:
		return Color("#BBC04A")
	if burn_stacks > 0:
		return Color("#E8784E")
	if poison_stacks > 0:
		return Color("#66A83F")
	if bleed_stacks > 0:
		return Color("#D94F6E")
	return Color(0.0, 0.0, 0.0, 0.0)

func _draw_pips() -> void:
	var pip_col := _aura_color()
	if pip_col.a == 0.0:
		return
	var count := 0
	if is_frozen:
		count = mini(cold_stacks, 6)
	elif cold_stacks > 0:
		count = mini(cold_stacks, 6)
	elif burn_stacks > 0 and poison_stacks > 0:
		count = mini(burn_stacks + poison_stacks, 6)
	elif burn_stacks > 0:
		count = mini(burn_stacks, 6)
	elif poison_stacks > 0:
		count = mini(poison_stacks, 6)
	elif bleed_stacks > 0:
		count = mini(bleed_stacks, 6)
	if count == 0:
		return
	pip_col.a = 1.0
	var start_x := -(count - 1) * 3.0
	for i in count:
		draw_circle(Vector2(start_x + i * 6.0, -29.0), 2.5, pip_col)
