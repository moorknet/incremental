extends CanvasLayer

signal shop_requested

@onready var time_label: Label = $Panel/TimeLabel
@onready var level_label: Label = $Panel/LevelLabel
@onready var kills_label: Label = $Panel/KillsLabel
@onready var damage_label: Label = $Panel/DamageLabel
@onready var meta_label: Label = $Panel/MetaLabel
@onready var total_meta_label: Label = $Panel/TotalMetaLabel
@onready var shop_btn: Button = $Panel/PlayAgainButton

func _ready() -> void:
	visible = false
	GameManager.run_ended.connect(_on_run_ended)
	shop_btn.pressed.connect(_on_shop_pressed)

func _on_run_ended() -> void:
	var m := int(GameManager.elapsed_time) / 60
	var s := fmod(GameManager.elapsed_time, 60.0)
	time_label.text = "Time  %d:%04.1f" % [m, s]
	level_label.text = "Level Reached  %d" % GameManager.level
	kills_label.text = "Kills  %d" % GameManager.kills
	damage_label.text = "Damage Dealt  %d" % int(GameManager.damage_dealt)
	meta_label.text = "Meta Earned  +%d" % GameManager.meta_earned_last_run
	total_meta_label.text = "Total Meta  %d" % MetaSave.meta_currency
	shop_btn.text = "Visit Shop  ›"
	visible = true

func _on_shop_pressed() -> void:
	visible = false
	shop_requested.emit()
