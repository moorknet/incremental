extends Node2D

func _draw() -> void:
	var top := Color("#EFF4F9")
	var bot := Color("#DAE3ED")
	# Full-screen vertical gradient (4-vertex quad, GPU interpolates)
	draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(800, 0), Vector2(800, 500), Vector2(0, 500)]),
		PackedColorArray([top, top, bot, bot])
	)

	# Decorative ridge silhouettes at the bottom
	_draw_ridge(PackedVector2Array([
		Vector2(0, 500), Vector2(0, 395), Vector2(180, 360), Vector2(390, 378),
		Vector2(580, 352), Vector2(740, 365), Vector2(800, 355), Vector2(800, 500)
	]), Color(0.842, 0.886, 0.924, 1.0))

	_draw_ridge(PackedVector2Array([
		Vector2(0, 500), Vector2(0, 430), Vector2(140, 415), Vector2(320, 425),
		Vector2(520, 408), Vector2(700, 418), Vector2(800, 412), Vector2(800, 500)
	]), Color(0.855, 0.896, 0.933, 1.0))

func _draw_ridge(pts: PackedVector2Array, col: Color) -> void:
	var cols := PackedColorArray()
	for i in pts.size():
		cols.append(col)
	draw_polygon(pts, cols)
