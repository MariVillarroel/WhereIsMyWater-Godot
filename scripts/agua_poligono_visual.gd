extends Node2D

@export var gotas_group: StringName = &"gotas_agua"
@export var color_agua: Color = Color(0.08, 0.65, 0.95, 0.58)
@export var radio_visual: float = 16.0
@export var distancia_union: float = 46.0
@export var minimo_gotas_cluster: int = 2
@export var muestras_por_gota: int = 10
@export var max_gotas_visuales: int = 140
@export var debug_mostrar_gotas: bool = true

var _clusters: Array[PackedVector2Array] = []


func _process(_delta: float) -> void:
	_actualizar_poligonos()
	queue_redraw()


func _draw() -> void:
	for poligono in _clusters:
		if poligono.size() >= 3:
			draw_colored_polygon(poligono, color_agua)


func _actualizar_poligonos() -> void:
	_clusters.clear()

	var gotas := _obtener_posiciones_gotas()
	if gotas.is_empty():
		return

	var grupos := _crear_clusters(gotas)
	for grupo in grupos:
		if grupo.size() < minimo_gotas_cluster:
			continue

		var nube_puntos := _crear_nube_para_grupo(grupo)
		var contorno := _convex_hull(nube_puntos)
		if contorno.size() >= 3:
			_clusters.append(contorno)


func _obtener_posiciones_gotas() -> Array[Vector2]:
	var posiciones: Array[Vector2] = []
	var nodos := get_tree().get_nodes_in_group(gotas_group)

	for nodo in nodos:
		if posiciones.size() >= max_gotas_visuales:
			break
		if not nodo is Node2D or nodo.is_queued_for_deletion():
			continue

		posiciones.append(to_local((nodo as Node2D).global_position))

	return posiciones


func _crear_clusters(posiciones: Array[Vector2]) -> Array[Array]:
	var grupos: Array[Array] = []
	var visitadas: Array[bool] = []
	visitadas.resize(posiciones.size())
	visitadas.fill(false)

	for i in range(posiciones.size()):
		if visitadas[i]:
			continue

		var grupo: Array[Vector2] = []
		var pendientes: Array[int] = [i]
		visitadas[i] = true

		while not pendientes.is_empty():
			var indice := pendientes.pop_back()
			var actual := posiciones[indice]
			grupo.append(actual)

			for j in range(posiciones.size()):
				if visitadas[j]:
					continue
				if actual.distance_to(posiciones[j]) <= distancia_union:
					visitadas[j] = true
					pendientes.append(j)

		grupos.append(grupo)

	return grupos


func _crear_nube_para_grupo(grupo: Array[Vector2]) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	var muestras := max(muestras_por_gota, 6)

	for centro in grupo:
		for i in range(muestras):
			var angulo := TAU * float(i) / float(muestras)
			puntos.append(centro + Vector2(cos(angulo), sin(angulo)) * radio_visual)

	return puntos


func _convex_hull(puntos: PackedVector2Array) -> PackedVector2Array:
	if puntos.size() <= 3:
		return puntos

	var ordenados := Array(puntos)
	ordenados.sort_custom(_ordenar_por_xy)

	var inferior: Array[Vector2] = []
	for punto in ordenados:
		while inferior.size() >= 2 and _cross(inferior[-2], inferior[-1], punto) <= 0.0:
			inferior.pop_back()
		inferior.append(punto)

	var superior: Array[Vector2] = []
	for i in range(ordenados.size() - 1, -1, -1):
		var punto: Vector2 = ordenados[i]
		while superior.size() >= 2 and _cross(superior[-2], superior[-1], punto) <= 0.0:
			superior.pop_back()
		superior.append(punto)

	inferior.pop_back()
	superior.pop_back()

	var resultado := PackedVector2Array()
	for punto in inferior:
		resultado.append(punto)
	for punto in superior:
		resultado.append(punto)

	return resultado


func _ordenar_por_xy(a: Vector2, b: Vector2) -> bool:
	if is_equal_approx(a.x, b.x):
		return a.y < b.y
	return a.x < b.x


func _cross(origen: Vector2, a: Vector2, b: Vector2) -> float:
	return (a - origen).cross(b - origen)
