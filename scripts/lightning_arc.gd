extends Node2D

var _from: Vector2
var _to: Vector2
var _mid: Vector2    # pre-jittered midpoint
var _mid2: Vector2   # second jitter point for triple-segment arcs

func init(p_from: Vector2, p_to: Vector2) -> void:
	global_position = Vector2.ZERO
	_from = p_from
	_to = p_to

	# Pre-compute jitter so the arc shape is stable during the fade
	var perp := (_to - _from).normalized().rotated(PI / 2.0)
	var span := _from.distance_to(_to)
	var mid_base := (_from + _to) / 2.0
	_mid  = mid_base + perp * randf_range(-span * 0.22, span * 0.22)
	# Secondary kink roughly between mid and end
	var q := (_mid + _to) / 2.0
	_mid2 = q + perp * randf_range(-span * 0.10, span * 0.10)

	# Spawn with full alpha, tween to transparent
	modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.30).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tw.finished.connect(queue_free)

func _draw() -> void:
	const COL := Color("#7E63D6")
	const GLOW := Color(0.494, 0.388, 0.839, 0.22)
	# Glow pass (wide, semi-transparent)
	draw_line(_from, _mid,  GLOW, 6.0, true)
	draw_line(_mid,  _mid2, GLOW, 6.0, true)
	draw_line(_mid2, _to,   GLOW, 6.0, true)
	# Core pass (crisp, bright)
	draw_line(_from, _mid,  COL,  1.6, true)
	draw_line(_mid,  _mid2, COL,  1.6, true)
	draw_line(_mid2, _to,   COL,  1.6, true)
	# Bright spark at each kink
	draw_circle(_mid,  2.2, Color(0.85, 0.78, 1.0, 0.90))
	draw_circle(_mid2, 1.6, Color(0.85, 0.78, 1.0, 0.80))
