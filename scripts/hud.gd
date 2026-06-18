extends CanvasLayer

@onready var timer_label: Label = $Control/TimerLabel
@onready var wave_label: Label = $Control/WaveLabel
@onready var level_label: Label = $Control/LeftStats/LevelLabel
@onready var xp_bar: ProgressBar = $Control/LeftStats/XPBar
@onready var meta_label: Label = $Control/RightStats/MetaLabel
@onready var kills_label: Label = $Control/RightStats/KillsLabel
@onready var damage_label: Label = $Control/RightStats/DamageLabel
@onready var mod_list_label: Label = $Control/ModListLabel
@onready var pause_button: Button = $Control/PauseButton

signal pause_requested

func _ready() -> void:
	pause_button.pressed.connect(func(): pause_requested.emit())
	GameManager.timer_changed.connect(_on_timer_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.meta_changed.connect(_on_meta_changed)
	GameManager.kill_registered.connect(_on_kill_registered)
	GameManager.damage_updated.connect(_on_damage_updated)
	GameManager.modifier_added.connect(_refresh_mod_list)

func _on_wave_changed(w: int) -> void:
	wave_label.text = "WAVE %d" % w

func _on_timer_changed(seconds: float) -> void:
	var s := maxf(seconds, 0.0)
	timer_label.text = "%d.%d" % [int(s), int(fmod(s, 1.0) * 10)]
	if s < 10.0:
		timer_label.modulate = Color(1.0, 0.2, 0.2)
	elif s < 20.0:
		timer_label.modulate = Color(1.0, 0.8, 0.1)
	else:
		timer_label.modulate = Color.WHITE

func _on_xp_changed(current: int, needed: int) -> void:
	xp_bar.max_value = needed
	xp_bar.value = current

func _on_level_up(new_level: int) -> void:
	level_label.text = "Lv. %d" % new_level
	xp_bar.value = 0

func _on_meta_changed(total: int) -> void:
	meta_label.text = "META  %d" % total

func _on_kill_registered(total: int) -> void:
	kills_label.text = "KILLS  %d" % total

func _on_damage_updated(total: float) -> void:
	damage_label.text = "DMG  %d" % int(total)

func _refresh_mod_list() -> void:
	if not GameManager.attack:
		mod_list_label.text = ""
		return
	var atk := GameManager.attack as Attack
	var counts: Dictionary = {}
	for mod in atk.modifiers:
		counts[mod.display_name] = counts.get(mod.display_name, 0) + 1
	var parts: Array[String] = []
	for name in counts:
		if counts[name] > 1:
			parts.append("%s x%d" % [name, counts[name]])
		else:
			parts.append(name)
	mod_list_label.text = "  ·  ".join(parts)
