extends CanvasLayer

@onready var title_label: Label = $Panel/TitleLabel
@onready var card_row: HBoxContainer = $Panel/CardRow

var _offers: Array[Modifier] = []
var _pending_levels: int = 0

func _ready() -> void:
	visible = false
	GameManager.level_up.connect(_on_level_up)

func _on_level_up(new_level: int) -> void:
	if visible:
		_pending_levels += 1
		return
	_show_cards(new_level)

func _show_cards(new_level: int) -> void:
	title_label.text = "LEVEL  %d" % new_level

	var num_cards := mini(3 + MetaSave.extra_cards, 8)
	_offers = ModifierRegistry.pick_offers(num_cards)

	# Rebuild card buttons
	for child in card_row.get_children():
		child.free()

	for i in _offers.size():
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 180)
		btn.text = _offers[i].get_card_description()
		btn.pressed.connect(_on_card_pressed.bind(i))
		card_row.add_child(btn)

	visible = true
	get_tree().paused = true

func _on_card_pressed(index: int) -> void:
	if index < _offers.size() and GameManager.attack:
		(GameManager.attack as Attack).add_modifier(_offers[index])
		GameManager.notify_modifier_added()

	if _pending_levels > 0:
		_pending_levels -= 1
		get_tree().paused = false
		visible = false
		_show_cards(GameManager.level)
	else:
		get_tree().paused = false
		visible = false
