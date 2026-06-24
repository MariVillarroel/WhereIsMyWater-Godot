extends Node2D

@export var gotas_group: StringName = &"gotas_agua"
@export_node_path("TileMapLayer") var terreno_path: NodePath
@export var color_agua: Color = Color(0.08, 0.65, 0.95, 0.58)
@export var color_borde: Color = Color(0.72, 0.95, 1.0, 0.22)
@export var radio_visual: float = 16.0
@export var radio_borde: float = 21.0
@export var tamano_celda_visual: float = 12.0
@export var margen_tierra: float = 2.0
@export_range(0.0, 1.0, 0.01) var suavizado_temporal: float = 0.35
@export var max_gotas_visuales: int = 140

var _rects_agua: Array[Rect2] = []
var _rects_borde: Array[Rect2] = []
var _rects_agua_previos: Array[Rect2] = []
var _rects_borde_previos: Array[Rect2] = []
@onready var _terreno: TileMapLayer = get_node_or_null(terreno_path)


func _process(_delta: float) -> void:
	_actualizar_poligonos()
	queue_redraw()


func _draw() -> void:
	for rect in _rects_borde:
		draw_rect(rect, color_borde, true)

	for rect in _rects_agua:
		draw_rect(rect, color_agua, true)


func _actualizar_poligonos() -> void:
	var rects_agua_nuevos: Array[Rect2] = []
	var rects_borde_nuevos: Array[Rect2] = []

	var gotas: Array[Vector2] = _obtener_posiciones_gotas()
	if gotas.is_empty():
		_rects_agua.clear()
		_rects_borde.clear()
		_rects_agua_previos.clear()
		_rects_borde_previos.clear()
		return

	var celdas_agua: Dictionary = {}
	var celdas_borde: Dictionary = {}

	for gota in gotas:
		_agregar_celdas_cercanas(gota, radio_borde, celdas_borde)
		_agregar_celdas_cercanas(gota, radio_visual, celdas_agua)

	rects_borde_nuevos = _crear_rects_desde_celdas(celdas_borde)
	rects_agua_nuevos = _crear_rects_desde_celdas(celdas_agua)

	_rects_borde = _interpolar_rects(_rects_borde_previos, rects_borde_nuevos)
	_rects_agua = _interpolar_rects(_rects_agua_previos, rects_agua_nuevos)
	_rects_borde_previos = _rects_borde.duplicate()
	_rects_agua_previos = _rects_agua.duplicate()


func _obtener_posiciones_gotas() -> Array[Vector2]:
	var posiciones: Array[Vector2] = []
	var nodos: Array[Node] = get_tree().get_nodes_in_group(gotas_group)

	for nodo in nodos:
		if posiciones.size() >= max_gotas_visuales:
			break
		if not (nodo is Node2D) or nodo.is_queued_for_deletion():
			continue

		posiciones.append(to_local((nodo as Node2D).global_position))

	return posiciones


func _agregar_celdas_cercanas(centro: Vector2, radio: float, celdas: Dictionary) -> void:
	var radio_celdas: int = ceili(radio / tamano_celda_visual)
	var celda_central: Vector2i = _posicion_a_celda_visual(centro)

	for x in range(celda_central.x - radio_celdas, celda_central.x + radio_celdas + 1):
		for y in range(celda_central.y - radio_celdas, celda_central.y + radio_celdas + 1):
			var celda: Vector2i = Vector2i(x, y)
			var centro_celda: Vector2 = _celda_visual_a_centro(celda)
			if centro.distance_to(centro_celda) > radio:
				continue
			if not _espacio_visual_libre(centro_celda):
				continue

			celdas[celda] = true


func _crear_rects_desde_celdas(celdas: Dictionary) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var tamano: Vector2 = Vector2(tamano_celda_visual, tamano_celda_visual)

	for celda in celdas.keys():
		var celda_visual: Vector2i = celda
		var posicion: Vector2 = Vector2(celda_visual) * tamano_celda_visual
		rects.append(Rect2(posicion, tamano))

	return rects


func _posicion_a_celda_visual(posicion: Vector2) -> Vector2i:
	return Vector2i(floori(posicion.x / tamano_celda_visual), floori(posicion.y / tamano_celda_visual))


func _celda_visual_a_centro(celda: Vector2i) -> Vector2:
	return (Vector2(celda) + Vector2(0.5, 0.5)) * tamano_celda_visual


func _espacio_visual_libre(posicion_local: Vector2) -> bool:
	if _terreno == null:
		return true

	var global: Vector2 = to_global(posicion_local)
	var posicion_terreno: Vector2 = _terreno.to_local(global)
	var celda_terreno: Vector2i = _terreno.local_to_map(posicion_terreno)
	if _terreno.get_cell_source_id(celda_terreno) == -1:
		return true

	var centro_tile: Vector2 = _terreno.to_global(_terreno.map_to_local(celda_terreno))
	return global.distance_to(centro_tile) > 16.0 + margen_tierra


func _interpolar_rects(previos: Array[Rect2], nuevos: Array[Rect2]) -> Array[Rect2]:
	if previos.is_empty() or previos.size() != nuevos.size():
		return nuevos

	var resultado: Array[Rect2] = []
	for i in range(nuevos.size()):
		var rect_previo: Rect2 = previos[i]
		var rect_nuevo: Rect2 = nuevos[i]
		var posicion: Vector2 = rect_previo.position.lerp(rect_nuevo.position, suavizado_temporal)
		resultado.append(Rect2(posicion, rect_nuevo.size))

	return resultado
