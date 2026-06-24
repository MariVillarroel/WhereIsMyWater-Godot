extends Node2D

@export var gotas_group: StringName = &"gotas_agua"
@export var color_agua: Color = Color(0.08, 0.65, 0.95, 0.58)
@export var color_borde: Color = Color(0.72, 0.95, 1.0, 0.22)
@export var radio_visual: float = 16.0
@export var radio_borde: float = 21.0
@export var distancia_union: float = 46.0
@export var minimo_gotas_cluster: int = 2
@export var muestras_por_gota: int = 12
@export var iteraciones_suavizado: int = 2
@export_range(0.0, 1.0, 0.01) var suavizado_temporal: float = 0.35
@export var max_gotas_visuales: int = 140

var _clusters: Array[PackedVector2Array] = []
var _clusters_borde: Array[PackedVector2Array] = []
var _clusters_previos: Array[PackedVector2Array] = []


func _process(_delta: float) -> void:
	_actualizar_poligonos()
	queue_redraw()


func _draw() -> void:
	for poligono in _clusters_borde:
		if poligono.size() >= 3:
			draw_colored_polygon(poligono, color_borde)

	for poligono in _clusters:
		if poligono.size() >= 3:
			draw_colored_polygon(poligono, color_agua)


func _actualizar_poligonos() -> void:
	var clusters_nuevos: Array[PackedVector2Array] = []
	var bordes_nuevos: Array[PackedVector2Array] = []

	var gotas: Array[Vector2] = _obtener_posiciones_gotas()
	if gotas.is_empty():
		_clusters.clear()
		_clusters_borde.clear()
		_clusters_previos.clear()
		return

	var grupos: Array = _crear_clusters(gotas)
	for grupo in grupos:
		if grupo.size() < minimo_gotas_cluster:
			continue

		var nube_puntos: PackedVector2Array = _crear_nube_para_grupo(grupo, radio_visual)
		var contorno: PackedVector2Array = _convex_hull(nube_puntos)
		contorno = _suavizar_chaikin(contorno, iteraciones_suavizado)
		if contorno.size() >= 3:
			clusters_nuevos.append(contorno)

		var nube_borde: PackedVector2Array = _crear_nube_para_grupo(grupo, radio_borde)
		var contorno_borde: PackedVector2Array = _convex_hull(nube_borde)
		contorno_borde = _suavizar_chaikin(contorno_borde, iteraciones_suavizado)
		if contorno_borde.size() >= 3:
			bordes_nuevos.append(contorno_borde)

	_clusters = _interpolar_clusters(_clusters_previos, clusters_nuevos)
	_clusters_borde = bordes_nuevos
	_clusters_previos = _clusters.duplicate()


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


func _crear_clusters(posiciones: Array[Vector2]) -> Array:
	var grupos: Array = []
	var visitadas: Array[bool] = []
	visitadas.resize(posiciones.size())
	visitadas.fill(false)

	for i in range(posiciones.size()):
		if visitadas[i]:
			continue

		var grupo: Array = []
		var pendientes: Array[int] = [i]
		visitadas[i] = true

		while not pendientes.is_empty():
			var indice: int = pendientes.pop_back()
			var actual: Vector2 = posiciones[indice]
			grupo.append(actual)

			for j in range(posiciones.size()):
				if visitadas[j]:
					continue
				if actual.distance_to(posiciones[j]) <= distancia_union:
					visitadas[j] = true
					pendientes.append(j)

		grupos.append(grupo)

	return grupos


func _crear_nube_para_grupo(grupo: Array, radio: float) -> PackedVector2Array:
	var puntos: PackedVector2Array = PackedVector2Array()
	var muestras: int = maxi(muestras_por_gota, 6)

	for centro in grupo:
		var centro_gota: Vector2 = centro
		for i in range(muestras):
			var angulo: float = TAU * float(i) / float(muestras)
			puntos.append(centro_gota + Vector2(cos(angulo), sin(angulo)) * radio)

	return puntos


func _convex_hull(puntos: PackedVector2Array) -> PackedVector2Array:
	if puntos.size() <= 3:
		return puntos

	var ordenados: Array = Array(puntos)
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

	var resultado: PackedVector2Array = PackedVector2Array()
	for punto in inferior:
		resultado.append(punto)
	for punto in superior:
		resultado.append(punto)

	return resultado


func _suavizar_chaikin(puntos: PackedVector2Array, iteraciones: int) -> PackedVector2Array:
	var resultado: PackedVector2Array = puntos
	var repeticiones: int = maxi(iteraciones, 0)

	for _i in range(repeticiones):
		if resultado.size() < 3:
			return resultado

		var suavizado: PackedVector2Array = PackedVector2Array()
		for i in range(resultado.size()):
			var actual: Vector2 = resultado[i]
			var siguiente: Vector2 = resultado[(i + 1) % resultado.size()]
			suavizado.append(actual.lerp(siguiente, 0.25))
			suavizado.append(actual.lerp(siguiente, 0.75))

		resultado = suavizado

	return resultado


func _interpolar_clusters(previos: Array[PackedVector2Array], nuevos: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var resultado: Array[PackedVector2Array] = []
	var cantidad: int = nuevos.size()

	for i in range(cantidad):
		var nuevo: PackedVector2Array = nuevos[i]
		if i >= previos.size() or previos[i].size() != nuevo.size():
			resultado.append(nuevo)
			continue

		var anterior: PackedVector2Array = previos[i]
		var interpolado: PackedVector2Array = PackedVector2Array()
		for j in range(nuevo.size()):
			interpolado.append(anterior[j].lerp(nuevo[j], suavizado_temporal))

		resultado.append(interpolado)

	return resultado


func _ordenar_por_xy(a: Vector2, b: Vector2) -> bool:
	if is_equal_approx(a.x, b.x):
		return a.y < b.y
	return a.x < b.x


func _cross(origen: Vector2, a: Vector2, b: Vector2) -> float:
	return (a - origen).cross(b - origen)
