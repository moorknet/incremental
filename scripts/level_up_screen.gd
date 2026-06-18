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

	for child in card_row.get_children():
		child.free()

	for i in _offers.size():
		card_row.add_child(_make_card(_offers[i], i))

	visible = true
	get_tree().paused = true

func _make_card(mod: Modifier, index: int) -> Control:
	var accent := _tier_color(mod.tier)
	for tag in mod.tags:
		match tag:
			&"poison":    accent = Color("#66A83F"); break
			&"fire":      accent = Color("#E8784E"); break
			&"cold":      accent = Color("#3F9BD6"); break
			&"bleed":     accent = Color("#D94F6E"); break
			&"lightning": accent = Color("#7E63D6"); break
			&"shock":     accent = Color("#7E63D6"); break

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 150)
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	card_sb.set_corner_radius_all(14)
	card_sb.shadow_color = Color(0.16, 0.22, 0.29, 0.14)
	card_sb.shadow_size = 12
	card_sb.shadow_offset = Vector2(0, 5)
	card.add_theme_stylebox_override("panel", card_sb)

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Accent stripe at top
	var stripe := ColorRect.new()
	stripe.custom_minimum_size = Vector2(0, 5)
	stripe.color = accent
	vb.add_child(stripe)

	# Content margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 12)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 5)

	# Rarity badge
	var rarity := Label.new()
	rarity.text = _rarity_text(mod.tier)
	rarity.add_theme_font_size_override("font_size", 10)
	rarity.add_theme_color_override("font_color", accent)
	inner.add_child(rarity)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = mod.display_name
	name_lbl.add_theme_font_size_override("font_size", 17)
	name_lbl.add_theme_color_override("font_color", Color("#28313B"))
	inner.add_child(name_lbl)

	# Description
	var desc := Label.new()
	desc.text = mod.get_card_description()
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color("#7E8C9A"))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(desc)

	margin.add_child(inner)
	vb.add_child(margin)
	card.add_child(vb)

	# Click handler via gui_input
	var idx := index
	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_card_pressed(idx))

	return card

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

func _tier_color(tier: int) -> Color:
	match tier:
		1: return Color("#8C99A6")
		2: return Color("#3F9BD6")
		3: return Color("#7E63D6")
		_: return Color("#8C99A6")

func _rarity_text(tier: int) -> String:
	match tier:
		1: return "COMMON"
		2: return "UNCOMMON"
		3: return "RARE"
		_: return "COMMON"
