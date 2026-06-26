extends Area2D

signal gota_recibida(total_recibidas: int)

@export_node_path("Node") var game_manager_path: NodePath

@onready var _game_manager: Node = get_node_or_null(game_manager_path)
@onready var plant_sprite: Sprite2D = $PlantSprite
@onready var bubble_sprite: Sprite2D = $BubbleSprite

var _plant_textures: Array[Texture2D] = [
	preload("res://assets/ui/plant_death.png"),
	preload("res://assets/ui/plant_state1.png"),
	preload("res://assets/ui/plant_state2.png"),
	preload("res://assets/ui/plant_state3.png"),
	preload("res://assets/ui/plant_alive.png")
]
var _water_bubble_tex: Texture2D = preload("res://assets/ui/water_bubble_text.png")
var _happy_bubble_tex: Texture2D = preload("res://assets/ui/happy_bubble_text.png")

var _gotas_recibidas := 0
var _current_plant_state := 0
var _bubble_tween: Tween
@onready var _plant_base_scale: Vector2 = plant_sprite.scale

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if _game_manager != null:
		if _game_manager.has_signal("progreso_actualizado"):
			_game_manager.progreso_actualizado.connect(_on_progreso_actualizado)
	
	plant_sprite.texture = _plant_textures[0]
	bubble_sprite.texture = _water_bubble_tex
	
	_start_bubble_animation()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("gotas_agua"):
		return

	if not _puede_recibir_gota():
		return

	if _game_manager != null and _game_manager.has_method("registrar_gota_recibida"):
		_gotas_recibidas = _game_manager.registrar_gota_recibida()
	else:
		_gotas_recibidas += 1

	gota_recibida.emit(_gotas_recibidas)
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

func _on_progreso_actualizado(gotas_recibidas: int, gotas_objetivo: int, _gotas_restantes: int) -> void:
	if gotas_objetivo <= 0:
		return
	
	var progress = clampf(float(gotas_recibidas) / float(gotas_objetivo), 0.0, 1.0)
	_update_plant_state(progress)

func _update_plant_state(progress: float) -> void:
	var new_state := 0
	if progress >= 1.0:
		new_state = 4
	elif progress >= 0.75:
		new_state = 3
	elif progress >= 0.50:
		new_state = 2
	elif progress >= 0.25:
		new_state = 1
	else:
		new_state = 0
		
	if new_state != _current_plant_state:
		_current_plant_state = new_state
		plant_sprite.texture = _plant_textures[_current_plant_state]
		_play_pop_animation()
		
		if _current_plant_state == 4:
			bubble_sprite.texture = _happy_bubble_tex

func _play_pop_animation() -> void:
	var tween = create_tween()
	tween.tween_property(plant_sprite, "scale", _plant_base_scale * 1.12, 0.075)
	tween.tween_property(plant_sprite, "scale", _plant_base_scale, 0.075)

func _start_bubble_animation() -> void:
	if _bubble_tween != null and _bubble_tween.is_valid():
		_bubble_tween.kill()
		
	_bubble_tween = create_tween().set_loops()
	var base_y = bubble_sprite.position.y
	_bubble_tween.tween_property(bubble_sprite, "position:y", base_y - 3.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bubble_tween.tween_property(bubble_sprite, "position:y", base_y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
