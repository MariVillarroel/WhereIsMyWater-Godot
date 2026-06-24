extends Area2D

signal gota_perdida


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("gotas_agua"):
		return

	gota_perdida.emit()

	if body.has_method("eliminar"):
		body.eliminar()
	else:
		body.queue_free()
