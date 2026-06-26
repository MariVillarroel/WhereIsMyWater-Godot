class_name TerrainRasterizer
extends RefCounted


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
