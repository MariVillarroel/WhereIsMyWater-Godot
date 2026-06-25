class_name TerrainSystem
extends Node2D

## Orquestador del terreno destructible.
##
## Flujo:
##   TileMapLayer (solo editor / setup inicial)
##       -> TerrainRasterizer  -> Image
##       -> TerrainMask        -> muta la Image (excavación = borrar alfa)
##       -> TerrainVisual      -> sube la Image como ImageTexture
##       -> TerrainCollision   -> Marching Squares -> CollisionPolygon2D
##
## Después de _ready(), el TileMapLayer original se oculta y deja de
## participar en cualquier cosa visible o física. Ningún otro sistema
## del juego (GameManager, Spawner, Meta, Agua, HUD, niveles) necesita
## cambiar: este nodo es un reemplazo drop-in del terreno basado en
## TileMap, expuesto bajo la misma idea de "excavar en una posición".
##
## JERARQUÍA DE ESCENA ESPERADA:
##
##   TerrainSystem (este script)
##     ├── TileMapLayer   (terrain_path)   -- terreno de diseño, se oculta en runtime
##     ├── TerrainVisual  (visual_path)    -- Sprite2D con la ImageTexture
##     └── TerrainCollision (collision_path) -- StaticBody2D con los CollisionPolygon2D
##
## Los cuatro nodos deben ser hijos directos del mismo TerrainSystem
## (o, al menos, no tener transformaciones propias entre sí) para que
## las conversiones de coordenadas locales sean consistentes entre el
## TileMapLayer original y la Image rasterizada.

signal terrain_dug(global_position: Vector2, radius: float)

@export_node_path("TileMapLayer")
var terrain_path: NodePath

@export_node_path("TerrainVisual")
var visual_path: NodePath

@export_node_path("TerrainCollision")
var collision_path: NodePath

## Si es true, este nodo escucha el mouse directamente (botón izquierdo
## mantenido = excavar mientras se mueve), replicando el comportamiento
## de borrador de Photoshop descrito en los requisitos. Si el juego ya
## tiene su propio controlador de input para excavar, se puede dejar en
## false y llamar a erase_circle() manualmente desde ese controlador.
@export var handle_mouse_input: bool = true

@export_range(1.0, 256.0, 1.0) var dig_radius: float = 28.0

## Callable opcional: func() -> bool. Si se asigna, se consulta antes de
## cada excavación (equivalente al "_puede_excavar" / "puede_jugar" del
## script original). Permite que GameManager siga controlando cuándo se
## puede jugar sin que TerrainSystem conozca su API concreta.
var can_dig_check: Callable


var _terrain: TileMapLayer
var _visual: TerrainVisual
var _collision: TerrainCollision

var _rasterizer: TerrainRasterizer
var _mask: TerrainMask

var _used_rect: Rect2i
var _tile_size: Vector2i

var _is_digging := false


func _ready() -> void:

	_terrain = get_node_or_null(terrain_path)
	_visual = get_node_or_null(visual_path)
	_collision = get_node_or_null(collision_path)

	if _terrain == null:
		push_error("TerrainSystem: TileMapLayer no encontrado en terrain_path.")
		return

	if _visual == null:
		push_error("TerrainSystem: TerrainVisual no encontrado en visual_path.")
		return

	if _collision == null:
		push_error("TerrainSystem: TerrainCollision no encontrado en collision_path.")
		return

	_tile_size = _terrain.tile_set.tile_size
	_used_rect = _terrain.get_used_rect()

	_rasterizer = TerrainRasterizer.new()

	var image := _rasterizer.rasterize(_terrain)
	var locked_image := Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
	locked_image.fill(Color.TRANSPARENT)

	var additions = get_tree().get_nodes_in_group("terrain_additions")
	var erasers = get_tree().get_nodes_in_group("terrain_erasers")
	var blockers = get_tree().get_nodes_in_group("terrain_blockers")

	for eraser in erasers:
		if eraser is Sprite2D and eraser.texture != null:
			var tex_size = eraser.texture.get_size()
			var real_size = Vector2(tex_size.x * abs(eraser.scale.x), tex_size.y * abs(eraser.scale.y))
			var local_pos = _terrain.to_local(eraser.global_position) - _terrain_origin_local()
			var dest = local_pos - (real_size / 2.0)
			var rect = Rect2i(Vector2i(round(dest.x), round(dest.y)), Vector2i(round(real_size.x), round(real_size.y)))
			rect = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
			image.fill_rect(rect, Color.TRANSPARENT)

	for add in additions:
		if add is Sprite2D and add.texture != null:
			var tex_img = add.texture.get_image()
			if tex_img != null:
				if tex_img.is_compressed():
					tex_img.decompress()
				if tex_img.get_format() != Image.FORMAT_RGBA8:
					tex_img.convert(Image.FORMAT_RGBA8)

				if add.scale != Vector2.ONE:
					var new_w = max(1, int(tex_img.get_width() * abs(add.scale.x)))
					var new_h = max(1, int(tex_img.get_height() * abs(add.scale.y)))
					tex_img.resize(new_w, new_h, Image.INTERPOLATE_BILINEAR)

				var local_pos = _terrain.to_local(add.global_position) - _terrain_origin_local()
				var tex_size = tex_img.get_size()
				var dest = local_pos - (Vector2(tex_size) / 2.0)

				image.blend_rect(tex_img, Rect2i(Vector2i.ZERO, tex_size), Vector2i(round(dest.x), round(dest.y)))
				add.visible = false

	for blocker in blockers:
		if blocker is Sprite2D and blocker.texture != null:
			var tex_img = blocker.texture.get_image()
			if tex_img != null:
				if tex_img.is_compressed():
					tex_img.decompress()
				if tex_img.get_format() != Image.FORMAT_RGBA8:
					tex_img.convert(Image.FORMAT_RGBA8)

				if blocker.scale != Vector2.ONE:
					var new_w = max(1, int(tex_img.get_width() * abs(blocker.scale.x)))
					var new_h = max(1, int(tex_img.get_height() * abs(blocker.scale.y)))
					tex_img.resize(new_w, new_h, Image.INTERPOLATE_BILINEAR)

				var local_pos = _terrain.to_local(blocker.global_position) - _terrain_origin_local()
				var tex_size = tex_img.get_size()
				var dest = local_pos - (Vector2(tex_size) / 2.0)
				var dest_i := Vector2i(round(dest.x), round(dest.y))

				image.blend_rect(tex_img, Rect2i(Vector2i.ZERO, tex_size), dest_i)
				locked_image.blend_rect(tex_img, Rect2i(Vector2i.ZERO, tex_size), dest_i)
				blocker.visible = false

	_mask = TerrainMask.new()
	_mask.setup(image, locked_image)

	_visual.set_image(image)
	_visual.position = _terrain_origin_local()

	_collision.position = _terrain_origin_local()
	_collision.rebuild_full(image)

	# A partir de aquí el TileMapLayer ya no participa en render ni en
	# física: toda la representación vive en la Image / CollisionPolygon2D.
	_terrain.visible = false

	# "collision_enabled" es una propiedad de TileMapLayer (Godot 4.3+).
	# Se verifica con "in" antes de asignarla para no romper en versiones
	# de Godot donde no exista, ya que en ese caso bastaría con que el
	# TileMapLayer quede oculto e ignorado por el resto del juego.
	if "collision_enabled" in _terrain:
		_terrain.collision_enabled = false


func _unhandled_input(event: InputEvent) -> void:

	if not handle_mouse_input:
		return

	if _mask == null:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			if not _can_dig():
				return
			_is_digging = true
			erase_circle(get_global_mouse_position(), dig_radius)
		else:
			_is_digging = false

	elif event is InputEventMouseMotion and _is_digging:

		if not _can_dig():
			_is_digging = false
			return

		erase_circle(get_global_mouse_position(), dig_radius)


# =====================================================
# PUBLIC API
# =====================================================

## Excava un círculo en coordenadas globales del mundo. Borra píxeles
## (no tiles), reconstruye la textura visible y la colisión, y permite
## que el agua use exactamente el mismo agujero para atravesar.
func erase_circle(
	global_position: Vector2,
	radius: float
) -> void:

	if _mask == null:
		return

	var local := _to_image_space(global_position)

	var affected_rect := _mask.erase_circle(local, radius)

	if affected_rect.size.x <= 0 or affected_rect.size.y <= 0:
		return

	_visual.update_image_region(affected_rect)
	_collision.rebuild_region(_mask.image(), affected_rect)

	terrain_dug.emit(global_position, radius)


## Excava un rectángulo en coordenadas globales del mundo (por ejemplo,
## para huecos de meta o explosiones rectangulares).
func erase_rect(
	global_rect: Rect2i
) -> void:

	if _mask == null:
		return

	var origin := _to_image_space(global_rect.position)

	var local_rect := Rect2i(
		Vector2i(roundi(origin.x), roundi(origin.y)),
		global_rect.size
	)

	var affected_rect := _mask.erase_rect(local_rect)

	if affected_rect.size.x <= 0 or affected_rect.size.y <= 0:
		return

	_visual.update_image_region(affected_rect)
	_collision.rebuild_region(_mask.image(), affected_rect)


## Consulta de solidez en coordenadas globales del mundo. Pensado para
## que el sistema de Agua decida si el líquido puede atravesar un punto
## del terreno: exactamente el mismo dato (la Image) que determina el
## render y la colisión, así que agua y terreno nunca se desincronizan.
func is_solid_at_global_position(
	global_position: Vector2
) -> bool:

	if _mask == null:
		return false

	var local := _to_image_space(global_position)

	return _mask.is_solid(
		roundi(local.x),
		roundi(local.y)
	)


func image() -> Image:
	if _mask == null:
		return null
	return _mask.image()


func visual() -> TerrainVisual:
	return _visual


func collision() -> TerrainCollision:
	return _collision


func terrain() -> TileMapLayer:
	return _terrain


func used_rect() -> Rect2i:
	return _used_rect


# =====================================================
# INTERNALS
# =====================================================

## Origen, en coordenadas locales de este nodo, donde empieza el
## terreno rasterizado (esquina superior izquierda de used_rect).
func _terrain_origin_local() -> Vector2:

	return Vector2(
		_used_rect.position.x * _tile_size.x,
		_used_rect.position.y * _tile_size.y
	)


## Convierte una posición global del mundo a coordenadas de píxel
## dentro de la Image del terreno (espacio que usan TerrainMask,
## TerrainVisual y TerrainCollision).
func _to_image_space(
	global_position: Vector2
) -> Vector2:

	var local := _terrain.to_local(global_position)

	return local - _terrain_origin_local()


func _can_dig() -> bool:

	if not can_dig_check.is_valid():
		return true

	return can_dig_check.call()
