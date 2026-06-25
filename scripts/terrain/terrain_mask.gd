class_name TerrainMask
extends RefCounted

## Responsable exclusivo de mutar los píxeles de la Image del terreno.
## No sabe nada de TileMap, de colisiones ni de render: solo recibe una
## Image y la modifica (borra alfa) en las regiones solicitadas.
##
## Cada operación de borrado devuelve el Rect2i (en espacio de píxeles,
## ya recortado a los límites de la imagen) que realmente fue afectado.
## TerrainSystem usa ese rect para limitar qué porción de la textura y
## de la colisión hay que reconstruir.

var _image: Image


func setup(
	image: Image
) -> void:

	_image = image


func erase_circle(
	center: Vector2,
	radius: float
) -> Rect2i:

	if _image == null:
		return Rect2i()

	var width := _image.get_width()
	var height := _image.get_height()

	var radius_squared := radius * radius
	var radius_int := int(ceil(radius))

	var center_i := Vector2i(
		roundi(center.x),
		roundi(center.y)
	)

	var min_x: int = maxi(center_i.x - radius_int, 0)
	var min_y: int = maxi(center_i.y - radius_int, 0)
	var max_x: int = mini(center_i.x + radius_int, width - 1)
	var max_y: int = mini(center_i.y + radius_int, height - 1)
	
	if min_x > max_x or min_y > max_y:
		return Rect2i()

	for y in range(min_y, max_y + 1):

		var dy := y - center_i.y

		for x in range(min_x, max_x + 1):

			var dx := x - center_i.x

			if float(dx * dx + dy * dy) > radius_squared:
				continue

			_image.set_pixel(x, y, Color.TRANSPARENT)

	return Rect2i(
		min_x,
		min_y,
		max_x - min_x + 1,
		max_y - min_y + 1
	)


func erase_rect(
	rect: Rect2i
) -> Rect2i:

	if _image == null:
		return Rect2i()

	var image_rect := Rect2i(
		0,
		0,
		_image.get_width(),
		_image.get_height()
	)

	var clipped := rect.intersection(image_rect)

	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return Rect2i()

	_image.fill_rect(clipped, Color.TRANSPARENT)

	return clipped


func is_solid(
	x: int,
	y: int
) -> bool:

	if _image == null:
		return false

	if x < 0 or y < 0:
		return false

	if x >= _image.get_width() or y >= _image.get_height():
		return false

	return _image.get_pixel(x, y).a >= 0.5


func image() -> Image:
	return _image
