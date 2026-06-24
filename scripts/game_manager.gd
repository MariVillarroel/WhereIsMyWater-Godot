extends Node

signal contador_actualizado(gotas_recibidas: int, objetivo_minimo: int)
signal victoria
signal derrota

@export_node_path("Node") var spawner_path: NodePath
@export_node_path("Area2D") var meta_path: NodePath
@export var objetivo_minimo: int = 20
@export var gotas_totales: int = 100
@export var espera_derrota_segundos: float = 4.0

var gotas_generadas := 0
var gotas_recibidas := 0
var partida_terminada := false

@onready var _spawner: Node = get_node_or_null(spawner_path)
@onready var _meta: Area2D = get_node_or_null(meta_path)


func _ready() -> void:
	if _spawner != null:
		_spawner.gota_generada.connect(_on_gota_generada)
		_spawner.generacion_terminada.connect(_on_generacion_terminada)

	if _meta != null:
		_meta.gota_recibida.connect(_on_gota_recibida)

	contador_actualizado.emit(gotas_recibidas, objetivo_minimo)


func _on_gota_generada(cantidad_generada: int) -> void:
	gotas_generadas = cantidad_generada


func _on_gota_recibida(total_recibidas: int) -> void:
	if partida_terminada:
		return

	gotas_recibidas = total_recibidas
	contador_actualizado.emit(gotas_recibidas, objetivo_minimo)

	if gotas_recibidas >= objetivo_minimo:
		_finalizar_con_victoria()


func _on_generacion_terminada() -> void:
	if partida_terminada:
		return

	await get_tree().create_timer(espera_derrota_segundos).timeout

	if partida_terminada:
		return

	if gotas_recibidas < objetivo_minimo:
		_finalizar_con_derrota()


func _finalizar_con_victoria() -> void:
	partida_terminada = true
	_detener_spawner()
	victoria.emit()
	print("Victoria: llegaron %s de %s gotas requeridas." % [gotas_recibidas, objetivo_minimo])


func _finalizar_con_derrota() -> void:
	partida_terminada = true
	_detener_spawner()
	derrota.emit()
	print("Derrota: llegaron %s de %s gotas requeridas." % [gotas_recibidas, objetivo_minimo])


func _detener_spawner() -> void:
	if _spawner != null and _spawner.has_method("detener"):
		_spawner.detener()
