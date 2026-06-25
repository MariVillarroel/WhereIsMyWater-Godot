@tool
extends TileMapLayer

## Este script SOLO se encarga de pintar el terreno inicial en tiles,
## como ayuda visual en el editor y como fuente de datos para
## TerrainRasterizer. Ya NO maneja excavación, input de mouse, ni
## consulta al GameManager: todo eso ahora vive en TerrainSystem.
##
## En runtime, TerrainSystem.rasterize() lee este TileMapLayer una sola
## vez al iniciar el nivel y luego lo oculta. A partir de ahí, todo el
## terreno visible y la colisión vienen de la Image generada, no de
## este nodo.

@export var ancho_en_tiles: int = 16
@export var alto_en_tiles: int = 12
@export var inicio_tierra_y: int = 3
@export var meta_hueco_inicio: Vector2i = Vector2i(25, 14)
@export var meta_hueco_tamano: Vector2i = Vector2i(5, 4)


func _ready() -> void:
	_generar_terreno_inicial()


func _generar_terreno_inicial() -> void:
	clear()

	for x in range(ancho_en_tiles):
		for y in range(inicio_tierra_y, alto_en_tiles):

			var source_id := 5

			if y == inicio_tierra_y:
				source_id = 6

			set_cell(
				Vector2i(x, y),
				source_id,
				Vector2i.ZERO,
				0
			)
