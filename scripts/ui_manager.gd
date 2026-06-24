extends CanvasLayer

@export_node_path("Node") var game_manager_path: NodePath
@export_node_path("Label") var contador_label_path: NodePath
@export_node_path("Label") var mensaje_label_path: NodePath

@onready var _game_manager: Node = get_node_or_null(game_manager_path)
@onready var _contador_label: Label = get_node_or_null(contador_label_path)
@onready var _mensaje_label: Label = get_node_or_null(mensaje_label_path)


func _ready() -> void:
	if _game_manager != null:
		_game_manager.contador_actualizado.connect(_on_contador_actualizado)
		_game_manager.victoria.connect(_on_victoria)
		_game_manager.derrota.connect(_on_derrota)

	if _mensaje_label != null:
		_mensaje_label.visible = false

	_on_contador_actualizado(0, 20)


func _on_contador_actualizado(gotas_recibidas: int, objetivo_minimo: int) -> void:
	if _contador_label == null:
		return

	_contador_label.text = "Gotas: %s / %s" % [gotas_recibidas, objetivo_minimo]


func _on_victoria() -> void:
	_mostrar_mensaje("VICTORIA")


func _on_derrota() -> void:
	_mostrar_mensaje("DERROTA")


func _mostrar_mensaje(texto: String) -> void:
	if _mensaje_label == null:
		return

	_mensaje_label.text = texto
	_mensaje_label.visible = true
