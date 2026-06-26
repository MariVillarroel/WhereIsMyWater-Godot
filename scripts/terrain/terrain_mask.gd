class_name TerrainMask
extends RefCounted


var _image: Image
var _locked_image: Image


func setup(
	image: Image,
	locked_image: Image = null
) -> void:

	_image = image
	_locked_image = locked_image


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

	var erased := false

	for y in range(min_y, max_y + 1):

		var dy := y - center_i.y

		for x in range(min_x, max_x + 1):

			var dx := x - center_i.x

			if float(dx * dx + dy * dy) > radius_squared:
				continue

			if _is_locked(x, y):
				continue

			_image.set_pixel(x, y, Color.TRANSPARENT)
			erased = true

	if not erased:
		return Rect2i()

	return Rect2i(
		min_x,
		min_y,
		max_x - min_x + 1,
		max_y - min_y + 1
	)

func erase_stroke(
	from: Vector2,
	to: Vector2,
	radius: float
) -> Rect2i:

	if _image == null:
		return Rect2i()

	var width := _image.get_width()
	var height := _image.get_height()
	var radius_squared := radius * radius
	var radius_int := int(ceil(radius))

	var min_x: int = maxi(floori(minf(from.x, to.x)) - radius_int, 0)
	var min_y: int = maxi(floori(minf(from.y, to.y)) - radius_int, 0)
	var max_x: int = mini(ceili(maxf(from.x, to.x)) + radius_int, width - 1)
	var max_y: int = mini(ceili(maxf(from.y, to.y)) + radius_int, height - 1)

	if min_x > max_x or min_y > max_y:
		return Rect2i()

	var segment := to - from
	var segment_length_squared := segment.length_squared()
	var erased := false

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var point := Vector2(x, y)
			var closest := from

			if segment_length_squared > 0.0:
				var t := clampf((point - from).dot(segment) / segment_length_squared, 0.0, 1.0)
				closest = from + segment * t

			if point.distance_squared_to(closest) > radius_squared:
				continue

			if _is_locked(x, y):
				continue

			_image.set_pixel(x, y, Color.TRANSPARENT)
			erased = true

	if not erased:
		return Rect2i()

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

	var erased := false

	for y in range(clipped.position.y, clipped.end.y):
		for x in range(clipped.position.x, clipped.end.x):
			if _is_locked(x, y):
				continue

			_image.set_pixel(x, y, Color.TRANSPARENT)
			erased = true

	if not erased:
		return Rect2i()

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



func _is_locked(
	x: int,
	y: int
) -> bool:

	if _locked_image == null:
		return false

	if x < 0 or y < 0:
		return false

	if x >= _locked_image.get_width() or y >= _locked_image.get_height():
		return false

	return _locked_image.get_pixel(x, y).a >= 0.5

func image() -> Image:
	return _image
