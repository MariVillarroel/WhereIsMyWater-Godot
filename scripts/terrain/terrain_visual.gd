class_name TerrainVisual
extends Sprite2D


var _image: Image
var _texture: ImageTexture


func _ready() -> void:
	centered = false


func set_image(
	image: Image
) -> void:

	_image = image

	_texture = ImageTexture.create_from_image(_image)

	texture = _texture

	position = Vector2.ZERO


func update_image() -> void:

	if _texture == null:
		return

	_texture.update(_image)


func update_image_region(
	_region: Rect2i
) -> void:

	update_image()


func image() -> Image:
	return _image
