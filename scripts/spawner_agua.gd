extends Node2D

signal gota_generada(cantidad_generada: int)
signal generacion_terminada

@export var escena_gota: PackedScene
@export_node_path("CanvasGroup") var agua_canvas_group_path: NodePath
@export var gotas_totales: int = 100
@export var intervalo_generacion: float = 0.08
@export var variacion_horizontal: float = 10.0

var gotas_generadas := 0
var _activo := true
var _tiempo_acumulado := 0.0
@onready var _agua_canvas_group: CanvasGroup = get_node_or_null(agua_canvas_group_path)


func _process(delta: float) -> void:
	if not _activo:
		return

	if gotas_generadas >= gotas_totales:
		_activo = false
		generacion_terminada.emit()
		return

	_tiempo_acumulado += delta
	if _tiempo_acumulado < intervalo_generacion:
		return

	_tiempo_acumulado = 0.0
	generar_gota()


func generar_gota() -> void:
	if escena_gota == null or _agua_canvas_group == null:
		return

	var gota := escena_gota.instantiate() as Node2D
	var desplazamiento := randf_range(-variacion_horizontal, variacion_horizontal)
	gota.global_position = global_position + Vector2(desplazamiento, 0.0)
	_agua_canvas_group.add_child(gota)

	gotas_generadas += 1
	gota_generada.emit(gotas_generadas)


func detener() -> void:
	_activo = false
