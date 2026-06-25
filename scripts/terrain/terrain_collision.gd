class_name TerrainCollision
extends StaticBody2D

## Genera la colisión del terreno destructible de forma completamente
## procedural a partir de una Image (canal alfa = sólido/vacío).
##
## No usa TileMap ni colisión basada en celdas. En su lugar, utiliza
## el método nativo BitMap.opaque_to_polygons de Godot para extraer
## los contornos exactos de las zonas sólidas de manera ultra-rápida y
## crea un CollisionPolygon2D hijo por cada contorno encontrado.
##
## Soporta dos modos de reconstrucción:
##   - rebuild_full(image): recorre toda la imagen. Se usa una sola vez
##     al iniciar el nivel.
##   - rebuild_region(image, rect): recorre solo una región (por ejemplo
##     el área afectada por un disparo de excavación). En esta implementación
##     basada en BitMap, la reconstrucción completa es tan rápida que 
##     rebuild_region simplemente delega en una reconstrucción completa para 
##     garantizar la corrección topológica perfecta sin penalización 
##     significativa de rendimiento.
##
## En la práctica, para terrenos de tamaño de nivel (no mundos infinitos),
## el costo de Marching Squares completo es bajo (miles de celdas, no
## millones), así que aquí se prioriza CORRECCIÓN sobre micro-optimización:
## cada llamada a rebuild_full/rebuild_region reconstruye el conjunto
## completo de polígonos a partir del estado actual de la imagen.

var _polygon_pool: Array[CollisionPolygon2D] = []

func _ready() -> void:
	var mat = PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 0.2
	physics_material_override = mat


func rebuild(image: Image) -> void:

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)

	var rect := Rect2(0, 0, image.get_width(), image.get_height())
	var raw_polygons := bitmap.opaque_to_polygons(rect, 1.0)

	var polygons: Array[PackedVector2Array] = []
	for p in raw_polygons:
		polygons.append(p)

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
