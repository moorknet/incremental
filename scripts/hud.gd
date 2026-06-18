extends CanvasLayer

@onready var timer_label: Label    = $Control/TimerLabel
@onready var wave_label: Label     = $Control/WaveLabel
@onready var level_label: Label    = $Control/LeftPanel/LeftStats/LevelLabel
@onready var xp_bar: ProgressBar   = $Control/LeftPanel/LeftStats/XPBar
@onready var hp_bar: ProgressBar   = $Control/LeftPanel/LeftStats/HPBar
@onready var meta_label: Label     = $Control/RightPanel/RightStats/MetaLabel
@onready var kills_label: Label    = $Control/RightPanel/RightStats/KillsLabel
@onready var damage_label: Label   = $Control/RightPanel/RightStats/DamageLabel
@onready var mod_list_label: Label = $Control/ModListLabel
@onready var pause_button: Button  = $Control/PauseButton
@onready var left_panel: PanelContainer  = $Control/LeftPanel
@onready var right_panel: PanelContainer = $Control/RightPanel

signal pause_requested

func _ready() -> void:
	_apply_frostlight_styles()
	pause_button.pressed.connect(func(): pause_requested.emit())
	GameManager.timer_changed.connect(_on_timer_changed)
	GameManager.mob_level_changed.connect(_on_mob_level_changed)
	GameManager.player_hp_changed.connect(_on_player_hp_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.meta_changed.connect(_on_meta_changed)
	GameManager.kill_registered.connect(_on_kill_registered)
	GameManager.damage_updated.connect(_on_damage_updated)
	GameManager.modifier_added.connect(_refresh_mod_list)

func _apply_frostlight_styles() -> void:
	# Frosted white chip for stat panels
	var chip := _make_frosted_sb(10)
	left_panel.add_theme_stylebox_override("panel", chip)
	right_panel.add_theme_stylebox_override("panel", chip)

	# XP bar — teal fill, light track
	_style_bar(xp_bar, Color("#1E9E84"), Color("#E6EDF4"), 4)
	# HP bar — rose fill, light track
	_style_bar(hp_bar, Color("#D94F6E"), Color("#E6EDF4"), 4)

	# Timer: start in safe color
	timer_label.add_theme_color_override("font_color", Color("#28313B"))

	# Wave label (mob level): muted
	wave_label.add_theme_color_override("font_color", Color("#7E8C9A"))

	# Stat labels
	for lbl in [meta_label, kills_label, damage_label, level_label]:
		lbl.add_theme_color_override("font_color", Color("#28313B"))

	# Mod list
	mod_list_label.add_theme_color_override("font_color", Color("#4F5E6C"))

	# Pause button: secondary style
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color(1.0, 1.0, 1.0, 0.80)
	btn_sb.set_corner_radius_all(8)
	btn_sb.shadow_color = Color(0.16, 0.22, 0.29, 0.10)
	btn_sb.shadow_size = 6
	pause_button.add_theme_stylebox_override("normal", btn_sb)
	var btn_hover := btn_sb.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.945, 0.965, 0.980, 1.0)
	pause_button.add_theme_stylebox_override("hover", btn_hover)
	pause_button.add_theme_color_override("font_color", Color("#28313B"))

func _make_frosted_sb(radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 1.0, 1.0, 0.78)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left   = 10.0
	sb.content_margin_right  = 10.0
	sb.content_margin_top    = 8.0
	sb.content_margin_bottom = 8.0
	sb.shadow_color = Color(0.16, 0.22, 0.29, 0.11)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 4)
	return sb

func _style_bar(bar: ProgressBar, fill: Color, track: Color, radius: int) -> void:
	var fill_sb := StyleBoxFlat.new()
	fill_sb.bg_color = fill
	fill_sb.set_corner_radius_all(radius)
	bar.add_theme_stylebox_override("fill", fill_sb)

	var track_sb := StyleBoxFlat.new()
	track_sb.bg_color = track
	track_sb.set_corner_radius_all(radius)
	bar.add_theme_stylebox_override("background", track_sb)

func _on_mob_level_changed(lvl: int) -> void:
	wave_label.text = "MOB LV. %d" % lvl

func _on_timer_changed(seconds: float) -> void:
	var s := maxf(seconds, 0.0)
	timer_label.text = "%d.%d" % [int(s), int(fmod(s, 1.0) * 10)]
	if s < 8.0:
		timer_label.add_theme_color_override("font_color", Color("#D94F6E"))
	elif s < 15.0:
		timer_label.add_theme_color_override("font_color", Color("#E0A43C"))
	else:
		timer_label.add_theme_color_override("font_color", Color("#28313B"))

func _on_player_hp_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

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
			parts.append("%s ×%d" % [name, counts[name]])
		else:
			parts.append(name)
	mod_list_label.text = "  ·  ".join(parts)
