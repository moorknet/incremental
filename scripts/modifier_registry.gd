class_name ModifierRegistry

static func get_pool() -> Array[Modifier]:
	var pool: Array[Modifier] = []

	# --- Weapon modifiers ---
	pool.append(_make(&"sharpen",  "Sharpen",  "Blade sharpened.\n+{v} damage",          1, 3.0,  8.0,  {"damage": 1.0},                     [&"damage"]))
	pool.append(_make(&"swift",    "Swift",    "Faster shots.\n+{v} projectile speed",    1, 60.0, 150.0, {"speed": 1.0},                      [&"speed"]))
	pool.append(_make(&"split",    "Split",    "Fire one more projectile.",                2, 1.0,  1.0,  {"count": 1.0},                      [&"count"]))
	pool.append(_make(&"pierce",   "Pierce",   "Pass through one enemy.",                 2, 1.0,  1.0,  {"pierce": 1.0},                     [&"pierce"]))
	pool.append(_make(&"crit",     "Crit",     "Lucky strike.\n+{v} crit chance",         2, 0.01, 0.15, {"crit_chance": 1.0},                 [&"crit"]))
	pool.append(_make(&"savagery", "Savagery", "Crits hit harder.\n+{v}x crit damage",    2, 0.2,  0.8,  {"crit_multiplier": 1.0},            [&"crit", &"damage"]))
	pool.append(_make(&"bounce",   "Bounce",   "Ricochet.\nProjectile bounces to next enemy.", 2, 1.0,  1.0,  {"bounce": 1.0},                     [&"count"]))
	pool.append(_make_chain())
	pool.append(_make(&"greed",    "Greed",    "More spoils.\n+1 meta per kill",          1, 0.0,  0.0,  {},                                  [&"economy"], 1, 0.0))
	pool.append(_make(&"overtime", "Overtime", "Kills delay escalation.\n+{v}s per kill",  2, 2.0,  5.0,  {},                                  [&"economy", &"timer"], 0, -1.0))
	pool.append(_make_frenzy())

	# --- Poison ---
	pool.append(_make_es(&"plague",     "Plague",     "Infectious bite.\nApply {v} poison stacks on hit",     2, 1.0, 3.0, "poison", [&"poison", &"archetype"]))
	pool.append(_make_contagion())
	pool.append(_make_outbreak())

	# --- Fire ---
	pool.append(_make_es(&"ignite",        "Ignite",        "Burning touch.\nApply {v} burn stacks on hit",         2, 1.0, 3.0, "burn", [&"fire", &"archetype"]))
	pool.append(_make_conflagration())

	# --- Cold ---
	pool.append(_make_es(&"frostbite",  "Frostbite",  "Chilling bite.\nApply {v} cold stacks on hit (6=freeze)", 2, 1.0, 2.0, "cold", [&"cold", &"archetype"]))
	pool.append(_make_shatter())

	# --- Lightning ---
	pool.append(_make_overcharge())

	# --- Bleed ---
	pool.append(_make_es(&"hemorrhage", "Hemorrhage", "Open wound.\nApply {v} bleed stacks on hit",            2, 2.0, 4.0, "bleed", [&"bleed", &"archetype"]))

	# --- On-kill spawner ---
	pool.append(_make_bloodshot())

	return pool

# ── factories ──────────────────────────────────────────────────────────────

static func _make(
		id: StringName, name: String, desc: String,
		tier: int, rmin: float, rmax: float,
		mods: Dictionary, tags: Array[StringName],
		meta_kill: int = 0, timer_kill: float = 0.0
	) -> Modifier:
	var m := Modifier.new()
	m.id = id; m.display_name = name; m.description_template = desc
	m.tier = tier; m.roll_min = rmin; m.roll_max = rmax
	m.stat_mods = mods; m.tags = tags
	m.meta_per_kill = meta_kill; m.timer_per_kill = timer_kill
	return m

static func _make_es(id: StringName, name: String, desc: String, tier: int, rmin: float, rmax: float, element: String, tags: Array[StringName]) -> ElementalStackModifier:
	var m := ElementalStackModifier.new()
	m.id = id; m.display_name = name; m.description_template = desc
	m.tier = tier; m.roll_min = rmin; m.roll_max = rmax
	m.element = element; m.tags = tags
	return m

static func _make_contagion() -> ContagionModifier:
	var m := ContagionModifier.new()
	m.id = &"contagion"; m.display_name = "Contagion"
	m.tier = 2; m.roll_min = 70.0; m.roll_max = 120.0
	m.tags = [&"poison"]
	return m

static func _make_conflagration() -> ConflagrationModifier:
	var m := ConflagrationModifier.new()
	m.id = &"conflagration"; m.display_name = "Conflagration"
	m.tier = 3; m.roll_min = 10.0; m.roll_max = 30.0
	m.tags = [&"fire"]
	return m

static func _make_shatter() -> ShatterModifier:
	var m := ShatterModifier.new()
	m.id = &"shatter"; m.display_name = "Shatter"
	m.tier = 3; m.roll_min = 4.0; m.roll_max = 8.0
	m.tags = [&"cold"]
	return m

static func _make_overcharge() -> OverchargeModifier:
	var m := OverchargeModifier.new()
	m.id = &"overcharge"; m.display_name = "Overcharge"
	m.tier = 2; m.roll_min = 1.0; m.roll_max = 3.0
	m.tags = [&"lightning", &"archetype", &"crit"]
	return m

static func _make_chain() -> ChainModifier:
	var m := ChainModifier.new()
	m.id = &"chain"; m.display_name = "Chain"
	m.tier = 2; m.roll_min = 0.4; m.roll_max = 0.7
	m.tags = [&"chain", &"count"]
	return m

static func _make_frenzy() -> FrenzyModifier:
	var m := FrenzyModifier.new()
	m.id = &"frenzy"; m.display_name = "Frenzy"
	m.tier = 3; m.roll_min = 0.01; m.roll_max = 0.03
	m.tags = [&"speed", &"scaling"]
	return m

static func _make_outbreak() -> OutbreakModifier:
	var m := OutbreakModifier.new()
	m.id = &"outbreak"; m.display_name = "Outbreak"
	m.tier = 3; m.roll_min = 0.0; m.roll_max = 0.0
	m.tags = [&"poison", &"onkill"]
	return m

static func _make_bloodshot() -> BloodshotModifier:
	var m := BloodshotModifier.new()
	m.id = &"bloodshot"; m.display_name = "Bloodshot"
	m.tier = 3; m.roll_min = 0.15; m.roll_max = 0.50
	m.tags = [&"onkill", &"archetype"]
	return m

# ── offer picker ───────────────────────────────────────────────────────────

static func pick_offers(count: int) -> Array[Modifier]:
	var pool := get_pool()
	var result: Array[Modifier] = []
	var used_ids: Array[StringName] = []

	var attempts := 0
	while result.size() < count and attempts < 200:
		attempts += 1
		var picked := _weighted_pick(pool, used_ids)
		if picked == null:
			break
		var instance := picked.duplicate() as Modifier
		instance.roll(GameManager.rng, MetaSave.luck_level)
		result.append(instance)
		used_ids.append(instance.id)

	return result

static func _weighted_pick(pool: Array[Modifier], exclude_ids: Array[StringName]) -> Modifier:
	var available: Array[Modifier] = []
	for m in pool:
		if not exclude_ids.has(m.id):
			available.append(m)
	if available.is_empty():
		return null

	var total := 0.0
	for m in available:
		total += _tier_weight(m.tier)

	var roll := GameManager.rng.randf() * total
	var acc := 0.0
	for m in available:
		acc += _tier_weight(m.tier)
		if roll < acc:
			return m
	return available[-1]

static func _tier_weight(tier: int) -> float:
	match tier:
		1: return 10.0
		2: return 5.0
		3: return 2.0
		_: return 1.0
