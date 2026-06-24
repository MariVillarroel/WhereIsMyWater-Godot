extends Node

signal contador_actualizado(gotas_recibidas: int, gotas_objetivo: int)
signal victoria
signal derrota

enum EstadoJuego {
	PREPARANDO,
	JUGANDO,
	GANADO,
	PERDIDO,
	PAUSADO,
}

@export_node_path("Node") var spawner_path: NodePath
@export_node_path("Area2D") var meta_path: NodePath
@export var nombre_nivel: String = "Nivel 1"
@export var gotas_totales: int = 100
@export var gotas_objetivo: int = 20
@export var siguiente_nivel: PackedScene

var estado_actual: EstadoJuego = EstadoJuego.PREPARANDO
var gotas_generadas := 0
var gotas_recibidas := 0
var partida_terminada := false
var generacion_terminada := false

@onready var _spawner: Node = get_node_or_null(spawner_path)
@onready var _meta: Area2D = get_node_or_null(meta_path)


func _ready() -> void:
	if _spawner != null:
		_spawner.gota_generada.connect(_on_gota_generada)
		_spawner.generacion_terminada.connect(_on_generacion_terminada)

	if _meta != null:
		_meta.gota_recibida.connect(_on_gota_recibida)

	iniciar_nivel()


func iniciar_nivel() -> void:
	gotas_generadas = 0
	gotas_recibidas = 0
	partida_terminada = false
	generacion_terminada = false
	estado_actual = EstadoJuego.JUGANDO
	contador_actualizado.emit(gotas_recibidas, gotas_objetivo)


func puede_jugar() -> bool:
	return estado_actual == EstadoJuego.JUGANDO


func _process(_delta: float) -> void:
	if partida_terminada or not generacion_terminada:
		return

	var gotas_activas := get_tree().get_nodes_in_group("gotas_agua").filter(
		func(gota: Node) -> bool:
			return not gota.is_queued_for_deletion()
	).size()

	if gotas_recibidas + gotas_activas < gotas_objetivo:
		_finalizar_con_derrota()


func registrar_gota_generada() -> void:
	if not puede_jugar():
		return

	gotas_generadas += 1


func _on_gota_generada(cantidad_generada: int) -> void:
	gotas_generadas = cantidad_generada


func _on_gota_recibida(total_recibidas: int) -> void:
	if partida_terminada:
		return

	gotas_recibidas = total_recibidas
	contador_actualizado.emit(gotas_recibidas, gotas_objetivo)

	if gotas_recibidas >= gotas_objetivo:
		_finalizar_con_victoria()


func _on_generacion_terminada() -> void:
	if partida_terminada:
		return

	generacion_terminada = true


func _finalizar_con_victoria() -> void:
	estado_actual = EstadoJuego.GANADO
	partida_terminada = true
	_detener_spawner()
	victoria.emit()
	print("Victoria: llegaron %s de %s gotas requeridas." % [gotas_recibidas, gotas_objetivo])


func _finalizar_con_derrota() -> void:
	estado_actual = EstadoJuego.PERDIDO
	partida_terminada = true
	_detener_spawner()
	derrota.emit()
	print("Derrota: llegaron %s de %s gotas requeridas." % [gotas_recibidas, gotas_objetivo])


func _detener_spawner() -> void:
	if _spawner != null and _spawner.has_method("detener"):
		_spawner.detener()
