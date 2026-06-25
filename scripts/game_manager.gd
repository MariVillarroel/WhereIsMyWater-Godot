extends Node

signal progreso_actualizado(gotas_recibidas: int, gotas_objetivo: int, gotas_restantes: int)
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
const CONFIG_NIVELES := {
	1: {"gotas_totales": 80, "gotas_objetivo": 30},
	2: {"gotas_totales": 99, "gotas_objetivo": 50},
}

@export var nombre_nivel: String = "Nivel 1"
@export var numero_nivel: int = 1
@export var siguiente_nivel: PackedScene

var gotas_totales := 80
var gotas_objetivo := 30

var estado_actual: EstadoJuego = EstadoJuego.PREPARANDO
var gotas_generadas := 0
var gotas_recibidas := 0
var partida_terminada := false
var generacion_terminada := false

@onready var _spawner: Node = get_node_or_null(spawner_path)
@onready var _meta: Area2D = get_node_or_null(meta_path)


func _ready() -> void:
	_aplicar_configuracion_nivel()

	if _spawner != null:
		_spawner.gota_generada.connect(_on_gota_generada)
		_spawner.generacion_terminada.connect(_on_generacion_terminada)

	if _meta != null:
		_meta.gota_recibida.connect(_on_gota_recibida)

	iniciar_nivel()


func _aplicar_configuracion_nivel() -> void:
	var config: Dictionary = CONFIG_NIVELES.get(numero_nivel, CONFIG_NIVELES[1])
	gotas_totales = int(config["gotas_totales"])
	gotas_objetivo = int(config["gotas_objetivo"])


func iniciar_nivel() -> void:
	gotas_generadas = 0
	gotas_recibidas = 0
	partida_terminada = false
	generacion_terminada = false
	estado_actual = EstadoJuego.JUGANDO
	_emit_progreso()


func _emit_progreso() -> void:
	progreso_actualizado.emit(gotas_recibidas, gotas_objetivo, obtener_gotas_restantes())


func puede_jugar() -> bool:
	return estado_actual == EstadoJuego.JUGANDO


func _process(_delta: float) -> void:
	if partida_terminada or not generacion_terminada:
		return

	evaluar_estado()


func registrar_gota_generada() -> void:
	if not puede_jugar():
		return

	gotas_generadas += 1


func _on_gota_generada(cantidad_generada: int) -> void:
	gotas_generadas = cantidad_generada
	_emit_progreso()


func registrar_gota_recibida() -> int:
	if not puede_jugar():
		return gotas_recibidas

	gotas_recibidas += 1
	_emit_progreso()
	evaluar_estado()

	return gotas_recibidas


func _on_gota_recibida(total_recibidas: int) -> void:
	if partida_terminada or total_recibidas <= gotas_recibidas:
		return

	gotas_recibidas = total_recibidas
	_emit_progreso()
	evaluar_estado()


func evaluar_estado() -> void:
	if not puede_jugar():
		return

	if gotas_recibidas >= gotas_objetivo:
		ganar()
		return

	if gotas_recibidas + obtener_gotas_restantes() < gotas_objetivo:
		perder()


func obtener_gotas_restantes() -> int:
	var gotas_activas := get_tree().get_nodes_in_group("gotas_agua").filter(
		func(gota: Node) -> bool:
			return not gota.is_queued_for_deletion()
	).size()
	var gotas_por_generar = max(gotas_totales - gotas_generadas, 0)
	return gotas_activas + gotas_por_generar


func ganar() -> void:
	if estado_actual == EstadoJuego.GANADO:
		return

	estado_actual = EstadoJuego.GANADO
	partida_terminada = true
	_detener_spawner()
	victoria.emit()
	print("Victoria: llegaron %s de %s gotas requeridas." % [gotas_recibidas, gotas_objetivo])


func perder() -> void:
	if estado_actual == EstadoJuego.PERDIDO:
		return

	estado_actual = EstadoJuego.PERDIDO
	partida_terminada = true
	_detener_spawner()
	derrota.emit()
	print("Derrota: llegaron %s de %s gotas requeridas." % [gotas_recibidas, gotas_objetivo])


func _on_generacion_terminada() -> void:
	if partida_terminada:
		return

	generacion_terminada = true
	evaluar_estado()


func _finalizar_con_victoria() -> void:
	ganar()


func _finalizar_con_derrota() -> void:
	perder()


func _detener_spawner() -> void:
	if _spawner != null and _spawner.has_method("detener"):
		_spawner.detener()


func reiniciar_nivel() -> void:
	get_tree().call_deferred("reload_current_scene")


func cargar_siguiente_nivel() -> void:
	if siguiente_nivel == null:
		push_warning("No hay siguiente nivel configurado para %s." % nombre_nivel)
		return

	get_tree().call_deferred("change_scene_to_packed", siguiente_nivel)
