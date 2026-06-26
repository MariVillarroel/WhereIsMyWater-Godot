extends Panel

const UITheme = preload("res://scripts/ui/ui_theme.gd")

var DEFEAT_FRAME := preload("res://assets/ui/derrota_frame.png")
var DEFEAT_WATER := preload("res://assets/ui/derrota_water.png")
var RESTART_TEXTURE := preload("res://assets/ui/restart.png")

var _backdrop: TextureRect
var _frame: PixelTexture
var _title_label: PixelLabel
var _subtitle_label: PixelLabel
var _water_icon: PixelTexture

var _boton_reiniciar: Button


func inicializar() -> void:
	var empty_style := StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty_style)

	var placeholder_label := get_node_or_null("LabelMensaje")
	if placeholder_label:
		placeholder_label.visible = false

	_boton_reiniciar = get_node_or_null("BotonReiniciar")

	if _boton_reiniciar == null:
		push_warning("No se encontró BotonReiniciar")

	var boton_siguiente := get_node_or_null("BotonSiguienteNivel")
	if boton_siguiente:
		boton_siguiente.visible = false
		boton_siguiente.disabled = true

	var gradient_texture := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0, 0, 0, 0.65),
		Color(0, 0, 0, 0.25)
	])
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 1.0)

	_backdrop = TextureRect.new()
	_backdrop.texture = gradient_texture
	_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)

	custom_minimum_size = Vector2(365, 291)
	size = custom_minimum_size

	_frame = PixelTexture.frame(DEFEAT_FRAME)
	_frame.resize(365, 291)
	_frame.position = Vector2.ZERO
	add_child(_frame)

	move_child(_backdrop, 0)
	move_child(_frame, 1)

	_title_label = PixelLabel.defeat_title("DERROTA")
	add_child(_title_label)

	_subtitle_label = PixelLabel.defeat_subtitle("TE QUEDASTE SIN GOTAS")
	add_child(_subtitle_label)

	_water_icon = PixelTexture.sprite(DEFEAT_WATER)
	_water_icon.resize(110, 80)
	add_child(_water_icon)

	if _boton_reiniciar:
		_style_button(_boton_reiniciar, RESTART_TEXTURE)
		move_child(_boton_reiniciar, get_child_count() - 1)

	update_layout()

	var parent_control := get_parent() as Control
	if parent_control:
		parent_control.resized.connect(_on_parent_resized)

	_center_in_viewport()


func _style_button(button: Button, texture: Texture2D) -> void:
	button.text = ""
	button.flat = false

	button.visible = true
	button.disabled = false
	button.mouse_filter = Control.MOUSE_FILTER_STOP

	button.custom_minimum_size = texture.get_size()
	button.size = texture.get_size()

	var normal := StyleBoxTexture.new()
	normal.texture = texture
	normal.draw_center = true

	var hover := StyleBoxTexture.new()
	hover.texture = texture
	hover.draw_center = true
	hover.modulate_color = Color(1.12, 1.12, 1.12)

	var pressed := StyleBoxTexture.new()
	pressed.texture = texture
	pressed.draw_center = true
	pressed.modulate_color = Color(0.88, 0.88, 0.88)

	var disabled := StyleBoxTexture.new()
	disabled.texture = texture
	disabled.draw_center = true

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	button.queue_redraw()


func update_layout() -> void:
	if _title_label:
		_title_label.position = Vector2(
			(365.0 - _title_label.size.x) * 0.5,
			32.0
		)

	if _subtitle_label:
		_subtitle_label.position = Vector2(
			(365.0 - _subtitle_label.size.x) * 0.5,
			72.0
		)

	if _water_icon:
		_water_icon.position = Vector2(
			(365.0 - 110.0) * 0.5,
			100.0
		)

	if _boton_reiniciar:
		_boton_reiniciar.position = Vector2(
			(365.0 - RESTART_TEXTURE.get_width()) * 0.5,
			205.0
		)


func _on_parent_resized() -> void:
	_center_in_viewport()


func _center_in_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	position = (viewport_size - size) * 0.5

	if _backdrop:
		_backdrop.position = -position
		_backdrop.size = viewport_size