class_name DamageNumber
extends Node2D

const FLOAT_HEIGHT := 44.0
const DURATION := 0.72

func init(amount: float, is_crit: bool = false, element: String = "") -> void:
	var label := $Label as Label
	var duration := DURATION

	if element != "":
		label.text = "%.1f" % amount
		duration = DURATION * 0.6
		match element:
			"poison": label.modulate = Color(0.35, 1.0, 0.3)
			"burn":   label.modulate = Color(1.0, 0.48, 0.1)
			"bleed":  label.modulate = Color(1.0, 0.22, 0.22)
			_:        label.modulate = Color.WHITE
		label.add_theme_font_size_override("font_size", 13)
	elif is_crit:
		label.text = "★ %d" % int(amount)
		label.modulate = Color(1.0, 0.88, 0.1)
		label.add_theme_font_size_override("font_size", 22)
	else:
		label.text = str(int(amount))
		label.modulate = Color.WHITE

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_HEIGHT, duration)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.55)\
		.set_delay(duration * 0.45)
	tween.finished.connect(queue_free)
