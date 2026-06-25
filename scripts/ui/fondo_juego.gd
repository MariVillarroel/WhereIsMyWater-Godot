extends CanvasLayer

const VIEWPORT_SIZE := Vector2(1000, 750)


func _ready() -> void:
	layer = -10

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.06, 0.03, 0.12, 1.0),
		Color(0.09, 0.06, 0.18, 1.0),
		Color(0.11, 0.09, 0.24, 1.0),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	gradient_texture.width = int(VIEWPORT_SIZE.x)
	gradient_texture.height = int(VIEWPORT_SIZE.y)

	var fondo := TextureRect.new()
	fondo.texture = gradient_texture
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.offset_right = VIEWPORT_SIZE.x
	fondo.offset_bottom = VIEWPORT_SIZE.y

	add_child(fondo)
