extends Node2D

signal gota_generada(cantidad_generada: int)
signal generacion_terminada

@export var escena_gota: PackedScene
@export_node_path("CanvasGroup") var agua_canvas_group_path: NodePath
@export_node_path("Node") var game_manager_path: NodePath
@export var gotas_totales: int = 100
@export var intervalo_generacion: float = 0.08
@export var variacion_horizontal: float = 10.0

var gotas_generadas := 0
var _activo := true
var _tiempo_acumulado := 0.0
var _generacion_terminada_emitida := false
@onready var _agua_canvas_group: CanvasGroup = get_node_or_null(agua_canvas_group_path)
@onready var _game_manager: Node = get_node_or_null(game_manager_path)


func _process(delta: float) -> void:
	if not _activo:
		return

	if not _puede_generar_por_estado():
		return

	if not _puede_generar_mas_gotas():
		_finalizar_generacion()
		return

	_tiempo_acumulado += delta
	if _tiempo_acumulado < intervalo_generacion:
		return

	_tiempo_acumulado = 0.0
	generar_gota()


func generar_gota() -> void:
	if escena_gota == null or _agua_canvas_group == null:
		return

	if not _puede_generar_por_estado() or not _puede_generar_mas_gotas():
		return

	var gota := escena_gota.instantiate() as Node2D
	var desplazamiento := randf_range(-variacion_horizontal, variacion_horizontal)
	gota.global_position = global_position + Vector2(desplazamiento, 0.0)
	_agua_canvas_group.add_child(gota)

	gotas_generadas += 1
	if _game_manager != null and _game_manager.has_method("registrar_gota_generada"):
		_game_manager.registrar_gota_generada()
	gota_generada.emit(gotas_generadas)


func detener() -> void:
	_activo = false


func _puede_generar_por_estado() -> bool:
	if _game_manager == null or not _game_manager.has_method("puede_jugar"):
		return true

	return _game_manager.puede_jugar()


func _puede_generar_mas_gotas() -> bool:
	return gotas_generadas < _obtener_gotas_totales()


func _obtener_gotas_totales() -> int:
	if _game_manager != null:
		var total_configurado = _game_manager.get("gotas_totales")
		if total_configurado != null:
			return int(total_configurado)

	return gotas_totales


func _finalizar_generacion() -> void:
	_activo = false
	if _generacion_terminada_emitida:
		return

	_generacion_terminada_emitida = true
	generacion_terminada.emit()
