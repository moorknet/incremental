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
			"poison": label.add_theme_color_override("font_color", Color("#66A83F"))
			"burn":   label.add_theme_color_override("font_color", Color("#E8784E"))
			"bleed":  label.add_theme_color_override("font_color", Color("#D94F6E"))
			"cold":   label.add_theme_color_override("font_color", Color("#3F9BD6"))
			_:        label.add_theme_color_override("font_color", Color("#7E63D6"))
		label.add_theme_font_size_override("font_size", 13)
	elif is_crit:
		label.text = "★ %d" % int(amount)
		label.add_theme_color_override("font_color", Color("#E0A43C"))
		label.add_theme_font_size_override("font_size", 22)
	else:
		label.text = str(int(amount))
		label.add_theme_color_override("font_color", Color("#28313B"))
		label.add_theme_font_size_override("font_size", 16)

	# Pop-in: scale from 0.8 → 1.05 → 1.0 in the first 12% of duration
	scale = Vector2(0.8, 0.8)
	var pop := create_tween()
	pop.tween_property(self, "scale", Vector2(1.05, 1.05), duration * 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "scale", Vector2(1.0, 1.0), duration * 0.06)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Rise and fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_HEIGHT, duration)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.55)\
		.set_delay(duration * 0.45)
	tween.finished.connect(queue_free)
