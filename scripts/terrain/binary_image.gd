class_name BinaryImage
extends RefCounted

## Envuelve una Image y expone consultas de "solidez" por píxel,
## usadas como campo escalar binario para Marching Squares.
##
## Un píxel es sólido si su canal alfa supera _alpha_threshold.
## Cualquier coordenada fuera de los límites de la imagen se considera
## NO sólida (aire), lo que permite que el algoritmo de contornos cierre
## correctamente los polígonos que tocan el borde del terreno.

var _image: Image
var _width: int
var _height: int
var _alpha_threshold: float


func setup(
	image: Image,
	alpha_threshold: float = 0.5
) -> void:

	_image = image
	_width = image.get_width()
	_height = image.get_height()
	_alpha_threshold = alpha_threshold


func is_solid(
	x: int,
	y: int
) -> bool:

	if x < 0:
		return false

	if y < 0:
		return false

	if x >= _width:
		return false

	if y >= _height:
		return false

	return _image.get_pixel(x, y).a >= _alpha_threshold


func width() -> int:
	return _width


func height() -> int:
	return _height