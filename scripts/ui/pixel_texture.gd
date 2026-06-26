class_name PixelTexture
extends TextureRect


func _init() -> void:

	mouse_filter = Control.MOUSE_FILTER_IGNORE

	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE



static func frame(
	texture: Texture2D,
	size: Vector2 = Vector2.ZERO
) -> PixelTexture:

	var rect := _create(texture)

	if size == Vector2.ZERO:
		size = Vector2(
			texture.get_width(),
			texture.get_height()
		)

	rect.resize_to(size)

	return rect


static func sprite(
	texture: Texture2D,
	size: Vector2 = Vector2.ZERO
) -> PixelTexture:

	var rect := _create(texture)

	if size == Vector2.ZERO:
		size = Vector2(
			texture.get_width(),
			texture.get_height()
		)

	rect.resize_to(size)

	return rect


static func icon(
	texture: Texture2D,
	size: Vector2
) -> PixelTexture:

	var rect := _create(texture)

	rect.resize_to(size)

	return rect



static func _create(
	texture: Texture2D
) -> PixelTexture:

	var rect := PixelTexture.new()

	rect.texture = texture

	return rect



func place(
	x: float,
	y: float
) -> PixelTexture:

	position = Vector2(x, y)

	return self


func place_at(
	pos: Vector2
) -> PixelTexture:

	position = pos

	return self


func resize(
	width: float,
	height: float
) -> PixelTexture:

	return resize_to(
		Vector2(
			width,
			height
		)
	)


func resize_to(
	new_size: Vector2
) -> PixelTexture:

	size = new_size
	custom_minimum_size = new_size

	return self
