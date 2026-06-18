extends Node

var rng := RandomNumberGenerator.new()
var rng_seed: int = 0

var run_timer: float = 0.0
var base_timer: float = 60.0
var run_active: bool = false

var xp: int = 0
var level: int = 1
var meta_pending: int = 0
var damage_dealt: float = 0.0
var kills: int = 0
var elapsed_time: float = 0.0
var meta_earned_last_run: int = 0

var attack: Variant = null
var damage_numbers_node: Node = null
var enemies_node: Node = null
var projectiles_node: Node = null
var wave: int = 0

signal level_up(new_level: int)
signal run_ended
signal xp_changed(current: int, needed: int)
signal timer_changed(seconds_left: float)
signal wave_changed(w: int)
signal meta_changed(total: int)
signal damage_updated(total: float)
signal kill_registered(total: int)
signal modifier_added

func _ready() -> void:
	set_process(false)

func start_run() -> void:
	rng_seed = randi()
	rng.seed = rng_seed
	print("Run seed: %d" % rng_seed)

	xp = 0
	level = 1
	wave = 0
	meta_pending = 0
	damage_dealt = 0.0
	kills = 0
	elapsed_time = 0.0
	run_timer = base_timer + MetaSave.bonus_timer
	run_active = true
	set_process(true)

func _process(delta: float) -> void:
	if not run_active:
		return
	elapsed_time += delta
	run_timer -= delta
	timer_changed.emit(run_timer)
	if run_timer <= 0.0:
		end_run()

func end_run() -> void:
	run_active = false
	set_process(false)
	meta_earned_last_run = meta_pending
	MetaSave.bank_meta(meta_pending)
	run_ended.emit()

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next(level):
		xp -= xp_to_next(level)
		level += 1
		level_up.emit(level)
	xp_changed.emit(xp, xp_to_next(level))

func add_meta(amount: int) -> void:
	meta_pending += amount
	meta_changed.emit(meta_pending)

func add_timer(seconds: float) -> void:
	run_timer += seconds

func record_damage(amount: float) -> void:
	damage_dealt += amount
	damage_updated.emit(damage_dealt)

func record_kill() -> void:
	kills += 1
	kill_registered.emit(kills)

func notify_modifier_added() -> void:
	modifier_added.emit()

func xp_to_next(lvl: int) -> int:
	return int(10 * pow(lvl, 1.5))
