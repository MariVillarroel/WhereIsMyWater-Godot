class_name MarchingSquares
extends RefCounted

## Implementación de Marching Squares para extracción de contornos.
##
## Recorre un BinaryImage celda por celda (cada celda está formada por
## 4 píxeles: arriba-izq, arriba-der, abajo-der, abajo-izq) y, según el
## patrón sólido/vacío de esas 4 esquinas, emite uno o dos segmentos de
## línea que aproximan el borde entre tierra y aire dentro de esa celda.
##
## El resultado es una lista plana de segmentos (pares de Vector2) en
## espacio de píxeles. No están conectados entre sí todavía: eso es
## responsabilidad de ContourBuilder.
##
## Convención de esquinas (bit -> posición):
##   1 = arriba-izquierda   (x,   y)
##   2 = arriba-derecha     (x+1, y)
##   4 = abajo-derecha      (x+1, y+1)
##   8 = abajo-izquierda    (x,   y+1)
##
## Los puntos de borde se ubican en el punto medio de cada arista de la
## celda (no se interpola por intensidad porque el campo es binario).

class Segment:
	var a: Vector2
	var b: Vector2

	func _init(p_a: Vector2, p_b: Vector2) -> void:
		a = p_a
		b = p_b


static func extract_segments(
	field: BinaryImage,
	min_x: int = -1,
	min_y: int = -1,
	max_x: int = -1,
	max_y: int = -1
) -> Array[Segment]:

	var segments: Array[Segment] = []

	# Si no se especifica una región, se recorre la imagen completa.
	# Las celdas de Marching Squares viven en el espacio "entre píxeles",
	# por lo que necesitamos un píxel extra de margen en cada borde para
	# que las formas que tocan el límite del terreno se cierren bien.
	var start_x := min_x if min_x >= 0 else -1
	var start_y := min_y if min_y >= 0 else -1
	var end_x := max_x if max_x >= 0 else field.width()
	var end_y := max_y if max_y >= 0 else field.height()

	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			_process_cell(field, x, y, segments)

	return segments


static func _process_cell(
	field: BinaryImage,
	x: int,
	y: int,
	segments: Array[Segment]
) -> void:

	var top_left := field.is_solid(x, y)
	var top_right := field.is_solid(x + 1, y)
	var bottom_right := field.is_solid(x + 1, y + 1)
	var bottom_left := field.is_solid(x, y + 1)

	var case_index := 0

	if top_left:
		case_index |= 1

	if top_right:
		case_index |= 2

	if bottom_right:
		case_index |= 4

	if bottom_left:
		case_index |= 8

	if case_index == 0 or case_index == 15:
		return

	# Puntos medios de las 4 aristas de la celda, en espacio de píxeles.
	var top := Vector2(x + 0.5, y)
	var right := Vector2(x + 1.0, y + 0.5)
	var bottom := Vector2(x + 0.5, y + 1.0)
	var left := Vector2(x, y + 0.5)

	# La dirección de cada segmento importa: las cadenas de ContourBuilder
	# solo conectan "el final de un segmento" con "el inicio de otro que
	# empiece exactamente ahí". Por eso cada caso y su complemento (la
	# configuración con las mismas esquinas pero invertidas, p. ej. 1 y 14)
	# deben usar el mismo par de puntos en orden INVERSO: si la esquina
	# sólida aislada cambia de un lado a otro de la arista, el sentido de
	# recorrido del borde también se invierte. Validado para que toda
	# combinación de excavaciones produzca contornos cerrados sin cadenas
	# rotas, incluyendo formas que tocan el borde de la imagen.
	match case_index:
		1:
			segments.append(Segment.new(left, top))
		14:
			segments.append(Segment.new(top, left))
		2:
			segments.append(Segment.new(top, right))
		13:
			segments.append(Segment.new(right, top))
		3:
			segments.append(Segment.new(left, right))
		12:
			segments.append(Segment.new(right, left))
		4:
			segments.append(Segment.new(right, bottom))
		11:
			segments.append(Segment.new(bottom, right))
		6:
			segments.append(Segment.new(top, bottom))
		9:
			segments.append(Segment.new(bottom, top))
		7:
			segments.append(Segment.new(left, bottom))
		8:
			segments.append(Segment.new(bottom, left))
		5:
			# Caso ambiguo (diagonales TL y BR sólidas, TR y BL vacías).
			# Se interpreta como dos esquinas separadas (no conectadas),
			# que es la elección estable más común para no producir
			# parpadeo geométrico entre excavaciones sucesivas.
			segments.append(Segment.new(left, top))
			segments.append(Segment.new(right, bottom))
		10:
			# Caso ambiguo complementario (diagonales TR y BL sólidas).
			segments.append(Segment.new(top, right))
			segments.append(Segment.new(bottom, left))