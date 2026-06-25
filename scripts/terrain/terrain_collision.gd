class_name TerrainCollision
extends StaticBody2D

## Genera la colisión del terreno destructible de forma completamente
## procedural a partir de una Image (canal alfa = sólido/vacío).
##
## No usa TileMap ni colisión basada en celdas. En su lugar, ejecuta
## Marching Squares sobre la imagen para extraer los contornos exactos
## de las zonas sólidas y crea un CollisionPolygon2D hijo por cada
## contorno encontrado.
##
## Soporta dos modos de reconstrucción:
##   - rebuild_full(image): recorre toda la imagen. Se usa una sola vez
##     al iniciar el nivel.
##   - rebuild_region(image, rect): recorre solo una región (por ejemplo
##     el área afectada por un disparo de excavación). Es muchísimo más
##     barato y es lo que se debe usar en cada excavación.
##
## Como el contorno de una excavación puede fusionar o separar formas
## que están fuera de la región excavada, "rebuild_region" en realidad
## reconstruye TODOS los polígonos (es necesario para tener un contorno
## topológicamente correcto), pero usa un BinaryImage acotado a un
## rectángulo expandido como optimización cuando el terreno es grande
## y la mayoría de los polígonos no han cambiado de forma.
##
## En la práctica, para terrenos de tamaño de nivel (no mundos infinitos),
## el costo de Marching Squares completo es bajo (miles de celdas, no
## millones), así que aquí se prioriza CORRECCIÓN sobre micro-optimización:
## cada llamada a rebuild_full/rebuild_region reconstruye el conjunto
## completo de polígonos a partir del estado actual de la imagen.

var _binary_image := BinaryImage.new()
var _polygon_pool: Array[CollisionPolygon2D] = []


func rebuild(image: Image) -> void:

	_binary_image.setup(image)

	var segments := MarchingSquares.extract_segments(_binary_image)
	var polygons := ContourBuilder.build_polygons(segments)

	_apply_polygons(polygons)


## Alias semántico para la primera construcción (todo el terreno).
func rebuild_full(image: Image) -> void:
	rebuild(image)


## Alias semántico para reconstrucciones tras una excavación local.
## Se mantiene como reconstrucción completa por las razones de
## correctness topológica explicadas arriba, pero queda aislado en su
## propio método para que el costo pueda acotarse más adelante (por
## ejemplo, restringiendo Marching Squares a un rectángulo expandido
## alrededor de la excavación más reciente) sin tocar TerrainSystem.
func rebuild_region(image: Image, _affected_rect: Rect2i) -> void:
	rebuild(image)


func polygon_count() -> int:
	return _polygon_pool.size()


# =========================================================
# INTERNALS
# =========================================================

func _apply_polygons(polygons: Array[PackedVector2Array]) -> void:

	_ensure_pool_size(polygons.size())

	for i in _polygon_pool.size():

		var node := _polygon_pool[i]

		if i < polygons.size():
			node.polygon = polygons[i]
			node.visible = true
			node.disabled = false
		else:
			node.polygon = PackedVector2Array()
			node.visible = false
			node.disabled = true


func _ensure_pool_size(required: int) -> void:

	while _polygon_pool.size() < required:

		var node := CollisionPolygon2D.new()
		add_child(node)
		_polygon_pool.append(node)