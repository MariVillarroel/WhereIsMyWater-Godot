class_name TerrainRasterizer
extends RefCounted

## Convierte un TileMapLayer de diseño en una única Image RGBA.
##
## Se usa EXCLUSIVAMENTE una vez, al iniciar el nivel, para construir el
## estado inicial del terreno destructible. A partir de ese momento el
## TileMapLayer deja de participar en el render o en la colisión: toda
## la representación vive en la Image resultante.

var _used_rect: Rect2i
var _tile_size: Vector2i


func rasterize(
	terrain: TileMapLayer
) -> Image:

	_tile_size = terrain.tile_set.tile_size
	_used_rect = terrain.get_used_rect()

	var image := Image.create(
		_used_rect.size.x * _tile_size.x,
		_used_rect.size.y * _tile_size.y,
		false,
		Image.FORMAT_RGBA8
	)

	image.fill(Color.TRANSPARENT)

	# Cache de Image por source_id de atlas: evita llamar get_image() en
	# la textura del atlas una vez por celda cuando un nivel puede tener
	# miles de celdas compartiendo el mismo atlas.
	var cache := {}

	for cell in terrain.get_used_cells():

		var source_id := terrain.get_cell_source_id(cell)

		if source_id == -1:
			continue

		var source := terrain.tile_set.get_source(source_id)

		if source == null:
			continue

		if not (source is TileSetAtlasSource):
			continue

		var atlas := source as TileSetAtlasSource

		if not cache.has(source_id):
			var read_image := atlas.texture.get_image()

			if read_image != null:

				# blit_rect() requiere que origen y destino compartan el
				# mismo formato de píxel para copiar correctamente. Las
				# texturas importadas en Godot suelen leerse en formatos
				# sin canal alfa (p. ej. RGB8) o comprimidos (ETC2/S3TC),
				# que blit_rect no puede mezclar con FORMAT_RGBA8: el
				# resultado es una copia silenciosa con alfa en 0 (nada
				# visible), sin ningún error. Se normaliza aquí siempre.
				if read_image.is_compressed():
					read_image.decompress()

				if read_image.get_format() != Image.FORMAT_RGBA8:
					read_image.convert(Image.FORMAT_RGBA8)

			cache[source_id] = read_image

		var tile_image: Image = cache[source_id]

		if tile_image == null:
			push_error("TerrainRasterizer: no se pudo leer la imagen del atlas para source_id=" + str(source_id) + ". Revisa que la textura tenga 'Keep CPU copy' / lectura habilitada en su importación.")
			continue

		var atlas_coords := terrain.get_cell_atlas_coords(cell)

		var region := Rect2i(
			atlas_coords * _tile_size,
			_tile_size
		)

		var destination := Vector2i(
			(cell.x - _used_rect.position.x) * _tile_size.x,
			(cell.y - _used_rect.position.y) * _tile_size.y
		)

		image.blit_rect(
			tile_image,
			region,
			destination
		)

	return image


func used_rect() -> Rect2i:
	return _used_rect


func tile_size() -> Vector2i:
	return _tile_size
