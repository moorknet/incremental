extends CanvasLayer

@onready var currency_label: Label = $MainPanel/VBox/Header/CurrencyLabel
@onready var upgrade_list: VBoxContainer = $MainPanel/VBox/Scroll/UpgradeList
@onready var reset_btn: Button = $MainPanel/VBox/ResetButton
@onready var start_run_btn: Button = $MainPanel/VBox/StartRunButton

var _rows: Array = []

func _ready() -> void:
	visible = false
	start_run_btn.pressed.connect(_on_start_run)
	reset_btn.pressed.connect(_on_reset)
	_build_upgrade_list()

func open() -> void:
	_refresh()
	visible = true

func _build_upgrade_list() -> void:
	for upgrade in _get_upgrades():
		_make_row(upgrade)

func _make_row(upgrade: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = upgrade.name
	name_lbl.add_theme_font_size_override("font_size", 15)

	var desc_lbl := Label.new()
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.modulate = Color(0.72, 0.72, 0.72)

	info.add_child(name_lbl)
	info.add_child(desc_lbl)

	var level_lbl := Label.new()
	level_lbl.custom_minimum_size = Vector2(60, 0)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 13)

	var buy_btn := Button.new()
	buy_btn.custom_minimum_size = Vector2(88, 32)
	buy_btn.add_theme_font_size_override("font_size", 13)
	buy_btn.pressed.connect(_on_buy.bind(upgrade))

	hbox.add_child(info)
	hbox.add_child(level_lbl)
	hbox.add_child(buy_btn)
	upgrade_list.add_child(hbox)

	_rows.append({ "upgrade": upgrade, "desc_lbl": desc_lbl, "level_lbl": level_lbl, "buy_btn": buy_btn })

func _refresh() -> void:
	currency_label.text = "⬡ %d" % MetaSave.meta_currency
	for row in _rows:
		_refresh_row(row)

func _refresh_row(row: Dictionary) -> void:
	var u: Dictionary = row.upgrade
	var lvl: int = u.get_level.call() as int
	var is_maxed: bool = u.max_level > 0 and lvl >= u.max_level

	row.desc_lbl.text = u.effect.call(lvl)

	if is_maxed:
		row.level_lbl.text = "MAX"
		row.buy_btn.text = "—"
		row.buy_btn.disabled = true
	else:
		var cost: int = u.base_cost * (lvl + 1)
		row.level_lbl.text = "Lv %d" % lvl
		row.buy_btn.text = "⬡ %d" % cost
		row.buy_btn.disabled = MetaSave.meta_currency < cost

func _on_buy(upgrade: Dictionary) -> void:
	var lvl: int = upgrade.get_level.call()
	var cost: int = upgrade.base_cost * (lvl + 1)
	if not MetaSave.spend_meta(cost):
		return
	upgrade.apply.call()
	MetaSave.save()
	_refresh()

func _on_reset() -> void:
	# Build a cost map: MetaSave property name → base_cost
	var cost_map: Dictionary = {}
	for u in _get_upgrades():
		var level_prop := _level_prop_for(u)
		if level_prop != "":
			cost_map[level_prop] = u.base_cost
	MetaSave.reset_upgrades(cost_map)
	_refresh()

func _level_prop_for(upgrade: Dictionary) -> String:
	# Derive the MetaSave property name by calling get_level and finding the matching var.
	# We do this by checking which MetaSave int var has the same value as get_level returns
	# — simpler: just store the property name in the upgrade dict.
	return upgrade.get("level_prop", "")

func _on_start_run() -> void:
	visible = false
	get_tree().reload_current_scene()

func _get_upgrades() -> Array:
	return [
		{ "name": "Sharpened Steel",    "level_prop": "damage_level",   "effect": func(l): return "+%d base damage" % (l * 2) if l > 0 else "",                             "get_level": func(): return MetaSave.damage_level,   "max_level": 0, "base_cost": 5,  "apply": func(): MetaSave.damage_level   += 1 },
		{ "name": "Swift Strikes",       "level_prop": "speed_level",    "effect": func(l): return "-%.2fs base cooldown" % (l * 0.08) if l > 0 else "",                        "get_level": func(): return MetaSave.speed_level,    "max_level": 0, "base_cost": 5,  "apply": func(): MetaSave.speed_level    += 1 },
		{ "name": "Veteran Endurance",   "level_prop": "timer_level",    "effect": func(l): return "+%ds between escalations" % (l * 10) if l > 0 else "",                               "get_level": func(): return MetaSave.timer_level,    "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.timer_level    += 1 },
		{ "name": "Fortune's Eye (Luck)","level_prop": "luck_level",     "effect": func(l): return "Luck %d — better roll quality & rarity" % l if l > 0 else "",               "get_level": func(): return MetaSave.luck_level,     "max_level": 0, "base_cost": 10, "apply": func(): MetaSave.luck_level     += 1 },
		{ "name": "Broader Choices",     "level_prop": "extra_cards",    "effect": func(l): return "%d cards offered on level-up" % (3 + l) if l > 0 else "3 cards (default)",  "get_level": func(): return MetaSave.extra_cards,    "max_level": 5, "base_cost": 12, "apply": func(): MetaSave.extra_cards    += 1 },
		{ "name": "Head Start",          "level_prop": "starting_modifier","effect": func(l): return "Start with 1 random modifier" if l > 0 else "Unlocks: start with 1 random modifier", "get_level": func(): return MetaSave.starting_modifier, "max_level": 1, "base_cost": 15, "apply": func(): MetaSave.starting_modifier = 1 },
		{ "name": "Plague Mastery",      "level_prop": "poison_level",   "effect": func(l): return "+%.2f Poison Power" % (l * 0.25) if l > 0 else "",                          "get_level": func(): return MetaSave.poison_level,   "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.poison_level   += 1 },
		{ "name": "Pyre Mastery",        "level_prop": "burn_level",     "effect": func(l): return "+%.2f Burn Power" % (l * 0.25) if l > 0 else "",                            "get_level": func(): return MetaSave.burn_level,     "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.burn_level     += 1 },
		{ "name": "Frost Mastery",       "level_prop": "frost_level",    "effect": func(l): return "+%.2f Frost Power" % (l * 0.25) if l > 0 else "",                           "get_level": func(): return MetaSave.frost_level,    "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.frost_level    += 1 },
		{ "name": "Storm Mastery",       "level_prop": "shock_level",    "effect": func(l): return "+%.2f Shock Power" % (l * 0.25) if l > 0 else "",                           "get_level": func(): return MetaSave.shock_level,    "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.shock_level    += 1 },
		{ "name": "Bleed Mastery",       "level_prop": "bleed_level",    "effect": func(l): return "+%.2f Bleed Power" % (l * 0.25) if l > 0 else "",                           "get_level": func(): return MetaSave.bleed_level,    "max_level": 0, "base_cost": 8,  "apply": func(): MetaSave.bleed_level    += 1 },
	]
