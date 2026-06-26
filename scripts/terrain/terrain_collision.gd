class_name TerrainCollision
extends StaticBody2D


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


func rebuild_full(image: Image) -> void:
	rebuild(image)


func rebuild_region(image: Image, _affected_rect: Rect2i) -> void:
	rebuild(image)


func polygon_count() -> int:
	return _polygon_pool.size()



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
