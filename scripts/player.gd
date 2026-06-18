class_name Player
extends Node2D

# Frostlight Warden — faceted crystalline guardian (player entity)
const _C_BASE  := Color("#1E9E84")
const _C_LIGHT := Color("#57C9AE")
const _C_DARK  := Color("#126350")
const _SHADOW  := Color(0.110, 0.165, 0.243, 0.18)

# Warden facet vertices (38w × 52h, centered at origin)
const _TOP        := Vector2(0.0,  -26.0)
const _L_UPPER    := Vector2(-11.0, -13.0)
const _L_MID      := Vector2(-13.0,  2.0)
const _L_LOWER    := Vector2(-8.0,   14.0)
const _R_UPPER    := Vector2(11.0,  -13.0)
const _R_MID      := Vector2(13.0,   2.0)
const _R_LOWER    := Vector2(8.0,    14.0)
const _BOTTOM     := Vector2(0.0,   26.0)
const _CROWN_MID  := Vector2(0.0,   -9.0)
const _Y_TOP      := -26.0
const _Y_BOT      :=  26.0

func place_in_corner(corner_position: Vector2) -> void:
	global_position = corner_position
	queue_redraw()

func _draw() -> void:
	# Ground shadow
	var sh_pts := PackedVector2Array()
	var sh_cols := PackedColorArray()
	for i in 16:
		var a := i * TAU / 16.0
		sh_pts.append(Vector2(cos(a) * 16.0, 27.0 + sin(a) * 4.0))
		sh_cols.append(_SHADOW)
	draw_polygon(sh_pts, sh_cols)

	# Dark facet (left body)
	var g_dt := _C_BASE.lerp(_C_DARK, 0.45)
	var pts_dark := PackedVector2Array([_TOP, _L_UPPER, _L_MID, _L_LOWER, _BOTTOM])
	draw_polygon(pts_dark, _fc(pts_dark, g_dt, _C_DARK))

	# Light facet (right body)
	var pts_light := PackedVector2Array([_TOP, _R_UPPER, _R_MID, _R_LOWER, _BOTTOM])
	draw_polygon(pts_light, _fc(pts_light, _C_LIGHT, _C_BASE))

	# Crown facet (top cap)
	var g_bbot := _C_BASE.lerp(_C_DARK, 0.28)
	var pts_crown := PackedVector2Array([_TOP, _L_UPPER, _CROWN_MID, _R_UPPER])
	draw_polygon(pts_crown, _fc(pts_crown, _C_BASE, g_bbot))

	# Core gem
	var core_pts := PackedVector2Array([
		Vector2(0.0, -6.0), Vector2(5.0, 1.0), Vector2(0.0, 8.0), Vector2(-5.0, 1.0)
	])
	var core_cols := PackedColorArray()
	core_cols.append(_C_LIGHT)
	core_cols.append(_C_LIGHT.lerp(_C_BASE, 0.4))
	core_cols.append(_C_BASE)
	core_cols.append(_C_LIGHT.lerp(_C_BASE, 0.4))
	draw_polygon(core_pts, core_cols)

# Per-vertex gradient using the entity's y_top / y_bot range
func _fc(pts: PackedVector2Array, c_top: Color, c_bot: Color) -> PackedColorArray:
	var cols := PackedColorArray()
	for v in pts:
		var t := clampf((v.y - _Y_TOP) / (_Y_BOT - _Y_TOP), 0.0, 1.0)
		cols.append(c_top.lerp(c_bot, t))
	return cols
