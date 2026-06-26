class_name PixelProgressBar
extends TextureProgressBar

const FILL_TEXTURE: Texture2D = preload("res://assets/ui/progress_fill.png")
const EMPTY_TEXTURE: Texture2D = preload("res://assets/ui/progress_empty.png")

const MIN_PROGRESS := 0.0
const MAX_PROGRESS := 100.0


func _init() -> void:

	min_value = MIN_PROGRESS
	max_value = MAX_PROGRESS
	value = MIN_PROGRESS

	texture_under = EMPTY_TEXTURE
	texture_progress = FILL_TEXTURE

	fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT

	stretch_margin_left = 0
	stretch_margin_top = 0
	stretch_margin_right = 0
	stretch_margin_bottom = 0

	custom_minimum_size = Vector2(
		FILL_TEXTURE.get_width(),
		FILL_TEXTURE.get_height()
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE



func actualizar(
	actual: int,
	objetivo: int
) -> void:

	if objetivo <= 0:
		reiniciar()
		return

	value = clampf(
		float(actual)
		/
		float(objetivo)
		*
		MAX_PROGRESS,
		MIN_PROGRESS,
		MAX_PROGRESS
	)


func reiniciar() -> void:
	value = MIN_PROGRESS


func porcentaje() -> float:
	return value / MAX_PROGRESS
