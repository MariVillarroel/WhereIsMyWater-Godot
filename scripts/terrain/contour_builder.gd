class_name ContourBuilder
extends RefCounted

## Toma los segmentos sueltos producidos por MarchingSquares y los
## encadena en polígonos cerrados (PackedVector2Array).
##
## Cada segmento conecta dos puntos en una grilla de medios-píxeles,
## así que conectar "el final de un segmento con el inicio de otro que
## empiece en el mismo punto" es una búsqueda exacta por igualdad de
## Vector2 (sin tolerancia de distancia), lo que es rápido y robusto.

const _MERGE_EPSILON := 0.001


static func build_polygons(
	segments: Array[MarchingSquares.Segment]
) -> Array[PackedVector2Array]:

	var polygons: Array[PackedVector2Array] = []

	if segments.is_empty():
		return polygons

	# Índice: punto de inicio (como clave de string) -> lista de índices
	# de segmentos que comienzan ahí. Permite recorrer la cadena sin
	# búsquedas lineales repetidas.
	var by_start: Dictionary = {}

	for i in segments.size():
		var key := _point_key(segments[i].a)
		if not by_start.has(key):
			by_start[key] = []
		by_start[key].append(i)

	var consumed := PackedByteArray()
	consumed.resize(segments.size())

	for start_index in segments.size():

		if consumed[start_index] == 1:
			continue

		var polygon := PackedVector2Array()
		var current_index := start_index
		var first_point := segments[current_index].a

		var safety_counter := segments.size() + 1

		while safety_counter > 0:

			safety_counter -= 1

			consumed[current_index] = 1
			polygon.append(segments[current_index].a)

			var next_point := segments[current_index].b
			var next_key := _point_key(next_point)

			if next_point.distance_squared_to(first_point) <= _MERGE_EPSILON:
				# Cerramos el polígono.
				break

			var candidates: Array = by_start.get(next_key, [])

			var next_index := -1

			for candidate in candidates:
				if consumed[candidate] == 0:
					next_index = candidate
					break

			if next_index == -1:
				# Cadena rota (no debería ocurrir con datos consistentes
				# de Marching Squares, pero se protege contra bordes de
				# imagen irregulares). Se descarta el polígono parcial.
				polygon.clear()
				break

			current_index = next_index

		if polygon.size() >= 3:
			polygons.append(_simplify_collinear(polygon))

	return polygons


## Une puntos colineales consecutivos para reducir el número de vértices
## sin alterar la forma. Marching Squares en una grilla regular produce
## muchísimos puntos a lo largo de tramos rectos.
static func _simplify_collinear(
	polygon: PackedVector2Array
) -> PackedVector2Array:

	var count := polygon.size()

	if count < 3:
		return polygon

	var result := PackedVector2Array()

	for i in count:

		var prev := polygon[(i - 1 + count) % count]
		var current := polygon[i]
		var next := polygon[(i + 1) % count]

		var delta_in := current - prev
		var delta_out := next - current

		# Si algún tramo tiene longitud cero (puntos duplicados, posible
		# en geometrías degeneradas), se conserva el punto para no perder
		# información en vez de normalizar un vector nulo.
		if delta_in.length_squared() <= 0.0001 or delta_out.length_squared() <= 0.0001:
			result.append(current)
			continue

		var dir_in := delta_in.normalized()
		var dir_out := delta_out.normalized()

		# Si la dirección de entrada y salida es esencialmente la misma,
		# el punto actual no aporta forma y se puede omitir.
		if dir_in.distance_squared_to(dir_out) > 0.0001:
			result.append(current)

	if result.size() < 3:
		return polygon

	return result


static func _point_key(point: Vector2) -> String:
	# Los puntos de MarchingSquares siempre caen en una grilla de medio
	# píxel, así que redondear a milésimas es seguro y evita problemas
	# de precisión de punto flotante al comparar.
	return "%d_%d" % [
		roundi(point.x * 1000.0),
		roundi(point.y * 1000.0)
	]