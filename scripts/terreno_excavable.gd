@tool
extends TileMapLayer

@export var ancho_en_tiles: int = 32
@export var alto_en_tiles: int = 18
@export var inicio_tierra_y: int = 5
@export var radio_excavacion: int = 1
@export var meta_hueco_inicio: Vector2i = Vector2i(25, 14)
@export var meta_hueco_tamano: Vector2i = Vector2i(5, 4)

var _excavando := false


func _ready() -> void:
	_generar_terreno_inicial()


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_excavando = event.pressed
		if _excavando:
			excavar_en_posicion(get_global_mouse_position())

	if event is InputEventMouseMotion and _excavando:
		excavar_en_posicion(get_global_mouse_position())


func excavar_en_posicion(global_position: Vector2) -> void:
	var posicion_local := to_local(global_position)
	var celda_central := local_to_map(posicion_local)

	for x in range(-radio_excavacion, radio_excavacion + 1):
		for y in range(-radio_excavacion, radio_excavacion + 1):
			var celda := celda_central + Vector2i(x, y)
			if celda.distance_to(celda_central) <= radio_excavacion:
				borrar_celda(celda)


func borrar_celda(cell_position: Vector2i) -> void:
	erase_cell(cell_position)


func _generar_terreno_inicial() -> void:
	clear()

	for x in range(ancho_en_tiles):
		for y in range(inicio_tierra_y, alto_en_tiles):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 0)

	for x in range(meta_hueco_inicio.x, meta_hueco_inicio.x + meta_hueco_tamano.x):
		for y in range(meta_hueco_inicio.y, meta_hueco_inicio.y + meta_hueco_tamano.y):
			erase_cell(Vector2i(x, y))
