extends RigidBody2D

const GRUPO_GOTAS := "gotas_agua"

@export var fuerza_agitacion_lateral: float = 18.0
@export var velocidad_horizontal_maxima: float = 120.0

var _direccion_agitacion := 1.0


func _ready() -> void:
	add_to_group(GRUPO_GOTAS)
	can_sleep = false
	contact_monitor = true
	max_contacts_reported = 4
	_direccion_agitacion = -1.0 if randf() < 0.5 else 1.0


func _physics_process(_delta: float) -> void:
	if get_contact_count() == 0:
		return

	if abs(linear_velocity.x) < velocidad_horizontal_maxima:
		apply_central_force(Vector2(fuerza_agitacion_lateral * _direccion_agitacion, 0.0))

	if randf() < 0.04:
		_direccion_agitacion *= -1.0


func eliminar() -> void:
	queue_free()
