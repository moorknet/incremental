extends Node

const SAVE_PATH := "user://save.json"

var meta_currency: int = 0

# Upgrade levels (persisted)
var damage_level: int = 0
var speed_level: int = 0
var timer_level: int = 0
var luck_level: int = 0
var poison_level: int = 0
var burn_level: int = 0
var frost_level: int = 0
var shock_level: int = 0
var bleed_level: int = 0
var extra_cards: int = 0
var starting_modifier: int = 0

# Derived — computed from levels, not saved
var base_damage_bonus: float:
	get: return damage_level * 2.0
var base_cooldown_reduction: float:
	get: return speed_level * 0.08
var bonus_timer: float:
	get: return timer_level * 10.0
var poison_power: float:
	get: return poison_level * 0.25
var burn_power: float:
	get: return burn_level * 0.25
var frost_power: float:
	get: return frost_level * 0.25
var shock_power: float:
	get: return shock_level * 0.25
var bleed_power: float:
	get: return bleed_level * 0.25

func _ready() -> void:
	load_save()

func bank_meta(amount: int) -> void:
	meta_currency += amount
	save()

func spend_meta(amount: int) -> bool:
	if meta_currency < amount:
		return false
	meta_currency -= amount
	save()
	return true

func save() -> void:
	var data := {
		"meta_currency": meta_currency,
		"damage_level": damage_level,
		"speed_level": speed_level,
		"timer_level": timer_level,
		"luck_level": luck_level,
		"poison_level": poison_level,
		"burn_level": burn_level,
		"frost_level": frost_level,
		"shock_level": shock_level,
		"bleed_level": bleed_level,
		"extra_cards": extra_cards,
		"starting_modifier": starting_modifier,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var result: Variant = JSON.parse_string(file.get_as_text())
	if not result is Dictionary:
		return
	meta_currency    = result.get("meta_currency", 0)
	damage_level     = result.get("damage_level", 0)
	speed_level      = result.get("speed_level", 0)
	timer_level      = result.get("timer_level", 0)
	luck_level       = result.get("luck_level", 0)
	poison_level     = result.get("poison_level", 0)
	burn_level       = result.get("burn_level", 0)
	frost_level      = result.get("frost_level", 0)
	shock_level      = result.get("shock_level", 0)
	bleed_level      = result.get("bleed_level", 0)
	extra_cards      = result.get("extra_cards", 0)
	starting_modifier = result.get("starting_modifier", 0)

func reset_upgrades(upgrade_costs: Dictionary) -> void:
	# Refund all spent currency: for each upgrade, spent = base_cost * level*(level+1)/2
	var refund := 0
	for level_var in upgrade_costs:
		var lvl: int = get(level_var)
		var base_cost: int = upgrade_costs[level_var]
		refund += base_cost * lvl * (lvl + 1) / 2
	meta_currency += refund
	damage_level = 0; speed_level = 0; timer_level = 0; luck_level = 0
	poison_level = 0; burn_level = 0; frost_level = 0; shock_level = 0; bleed_level = 0
	extra_cards = 0; starting_modifier = 0
	save()

func reset_save() -> void:
	meta_currency = 0
	damage_level = 0; speed_level = 0; timer_level = 0; luck_level = 0
	poison_level = 0; burn_level = 0; frost_level = 0; shock_level = 0; bleed_level = 0
	extra_cards = 0; starting_modifier = 0
	save()
