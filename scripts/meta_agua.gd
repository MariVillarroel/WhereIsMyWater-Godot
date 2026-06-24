extends Area2D

signal gota_recibida(total_recibidas: int)

@export_node_path("Node") var game_manager_path: NodePath

var gotas_recibidas := 0
@onready var _game_manager: Node = get_node_or_null(game_manager_path)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("gotas_agua"):
		return

	if not _puede_recibir_gota():
		return

	if _game_manager != null and _game_manager.has_method("registrar_gota_recibida"):
		gotas_recibidas = _game_manager.registrar_gota_recibida()
	else:
		gotas_recibidas += 1

	gota_recibida.emit(gotas_recibidas)
	_eliminar_gota(body)


func _puede_recibir_gota() -> bool:
	if _game_manager == null or not _game_manager.has_method("puede_jugar"):
		return true

	return _game_manager.puede_jugar()


func _eliminar_gota(body: Node2D) -> void:
	if body.has_method("eliminar"):
		body.eliminar()
	else:
		body.queue_free()
