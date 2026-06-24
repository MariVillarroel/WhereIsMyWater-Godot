extends Area2D

signal gota_recibida(total_recibidas: int)

var gotas_recibidas := 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("gotas_agua"):
		return

	gotas_recibidas += 1
	gota_recibida.emit(gotas_recibidas)

	if body.has_method("eliminar"):
		body.eliminar()
	else:
		body.queue_free()
