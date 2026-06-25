extends CanvasLayer

@export_node_path("Node") var game_manager_path: NodePath
@export_node_path("Panel") var panel_victoria_path: NodePath
@export_node_path("Panel") var panel_derrota_path: NodePath
@export_node_path("Button") var boton_reiniciar_victoria_path: NodePath
@export_node_path("Button") var boton_siguiente_nivel_path: NodePath
@export_node_path("Button") var boton_reiniciar_derrota_path: NodePath

@onready var _game_manager: Node = get_node_or_null(game_manager_path)
@onready var _panel_victoria: Panel = get_node_or_null(panel_victoria_path)
@onready var _panel_derrota: Panel = get_node_or_null(panel_derrota_path)
@onready var _boton_reiniciar_victoria: Button = get_node_or_null(boton_reiniciar_victoria_path)
@onready var _boton_siguiente_nivel: Button = get_node_or_null(boton_siguiente_nivel_path)
@onready var _boton_reiniciar_derrota: Button = get_node_or_null(boton_reiniciar_derrota_path)

var _hud_root: Control

var _hud_main: HudMain
var _hud_counter: HudCounter
var _hud_level: HudLevel

const VIEWPORT_WIDTH := 1000.0
const HUD_TOP := 12.0
const HUD_SIDE := 16.0
const HUD_GAP := 10.0
const HUD_LEVEL_WIDTH := 88.0
const HUD_COUNTER_WIDTH := 103.0

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_viewport_resized)
	_crear_interfaz()

	if _game_manager != null:
		_game_manager.progreso_actualizado.connect(_on_progreso_actualizado)
		_game_manager.victoria.connect(_on_victoria)
		_game_manager.derrota.connect(_on_derrota)

		_refrescar_desde_game_manager()

	_ocultar_paneles()
	_conectar_botones()
	_actualizar_boton_siguiente_nivel()


func _process(_delta: float) -> void:
	if _game_manager == null or not _game_manager.has_method("puede_jugar"):
		return

	if not _game_manager.puede_jugar():
		return

	if not _game_manager.has_method("obtener_gotas_restantes"):
		return

	actualizar_restantes(int(_game_manager.obtener_gotas_restantes()))


func _on_viewport_resized() -> void:
	var w := get_viewport().get_visible_rect().size.x
	if _hud_level != null:
		_hud_level.position.x = w - HUD_SIDE - HUD_LEVEL_WIDTH
	if _hud_counter != null:
		var level_x := w - HUD_SIDE - HUD_LEVEL_WIDTH
		_hud_counter.position.x = level_x - HUD_GAP - HUD_COUNTER_WIDTH

func actualizar_progreso(
	gotas_recibidas: int,
	gotas_objetivo: int
) -> void:
	if _hud_main != null:
		_hud_main.actualizar(
			gotas_recibidas,
			gotas_objetivo
		)
		
func actualizar_restantes(gotas_restantes: int) -> void:

	if _hud_counter != null:
		_hud_counter.actualizar(gotas_restantes)

func actualizar_nivel(
	nivel: int
) -> void:

	if _hud_level != null:
		_hud_level.actualizar(nivel)
	
func _on_progreso_actualizado(
	gotas_recibidas: int,
	gotas_objetivo: int,
	gotas_restantes: int
) -> void:
	actualizar_progreso(gotas_recibidas, gotas_objetivo)
	actualizar_restantes(gotas_restantes)


func _on_victoria() -> void:
	_ocultar_paneles()

	if _panel_victoria != null:
		_panel_victoria.visible = true

	_actualizar_boton_siguiente_nivel()
	_refrescar_desde_game_manager()


func _on_derrota() -> void:
	_ocultar_paneles()

	if _panel_derrota != null:
		_panel_derrota.visible = true

	_refrescar_desde_game_manager()


func _refrescar_desde_game_manager() -> void:
	if _game_manager == null:
		return

	_on_progreso_actualizado(
		int(_game_manager.get("gotas_recibidas")),
		int(_game_manager.get("gotas_objetivo")),
		int(_game_manager.obtener_gotas_restantes())
	)

	actualizar_nivel(
		int(_game_manager.get("numero_nivel"))
	)

func _ocultar_paneles() -> void:
	if _panel_victoria != null:
		_panel_victoria.visible = false

	if _panel_derrota != null:
		_panel_derrota.visible = false


func _conectar_botones() -> void:
	if _boton_reiniciar_victoria != null:
		_boton_reiniciar_victoria.pressed.connect(_on_reiniciar_pressed)

	if _boton_reiniciar_derrota != null:
		_boton_reiniciar_derrota.pressed.connect(_on_reiniciar_pressed)

	if _boton_siguiente_nivel != null:
		_boton_siguiente_nivel.pressed.connect(_on_siguiente_nivel_pressed)


func _on_reiniciar_pressed() -> void:
	if _game_manager != null and _game_manager.has_method("reiniciar_nivel"):
		_game_manager.reiniciar_nivel()


func _on_siguiente_nivel_pressed() -> void:
	if _game_manager != null and _game_manager.has_method("cargar_siguiente_nivel"):
		_game_manager.cargar_siguiente_nivel()


func _actualizar_boton_siguiente_nivel() -> void:
	if _boton_siguiente_nivel == null or _game_manager == null:
		return

	print("================================")
	print("PackedScene:", _game_manager.siguiente_nivel)
	print("Visible:", _boton_siguiente_nivel.visible)
	print("Disabled:", _boton_siguiente_nivel.disabled)
	print("================================")

	var tiene_siguiente_nivel: bool = _game_manager.get("siguiente_nivel") != null
	_boton_siguiente_nivel.visible = tiene_siguiente_nivel
	_boton_siguiente_nivel.disabled = not tiene_siguiente_nivel

	print("Después:")
	print("Visible:", _boton_siguiente_nivel.visible)
	print("Disabled:", _boton_siguiente_nivel.disabled)

func _crear_interfaz() -> void:

	_hud_root = Control.new()

	_hud_root.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(_hud_root)

	_crear_hud_principal()
	_crear_hud_counter()
	_crear_hud_level()

	if _panel_victoria != null:
		_panel_victoria.set_script(preload("res://scripts/ui/victory_panel.gd"))
		if _panel_victoria.has_method("inicializar"):
			_panel_victoria.inicializar()

	if _panel_derrota != null:
		_panel_derrota.set_script(preload("res://scripts/ui/defeat_panel.gd"))
		if _panel_derrota.has_method("inicializar"):
			_panel_derrota.inicializar()

func _crear_hud_principal() -> void:

	_hud_main = HudMain.new()
	_hud_main.position = Vector2(HUD_SIDE, HUD_TOP)

	_hud_root.add_child(
		_hud_main
	)
func _crear_hud_counter() -> void:

	_hud_counter = HudCounter.new()

	var w := get_viewport().get_visible_rect().size.x
	var level_x := w - HUD_SIDE - HUD_LEVEL_WIDTH
	_hud_counter.position = Vector2(
		level_x - HUD_GAP - HUD_COUNTER_WIDTH,
		HUD_TOP
	)

	_hud_root.add_child(
		_hud_counter
	)
func _crear_hud_level() -> void:

	_hud_level = HudLevel.new()

	var w := get_viewport().get_visible_rect().size.x
	_hud_level.position = Vector2(
		w - HUD_SIDE - HUD_LEVEL_WIDTH,
		HUD_TOP
	)

	_hud_root.add_child(
		_hud_level
	)
