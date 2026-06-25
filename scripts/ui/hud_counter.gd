class_name HudCounter
extends Control

const WATER_ICON := preload("res://assets/ui/water_icon.png")

# =====================================================
# PANEL
# =====================================================

const PANEL_WIDTH := 103
const PANEL_HEIGHT := 86

# =====================================================
# LAYOUT
# =====================================================

const ICON_X := 8
const ICON_Y := 14
const ICON_WIDTH := 33
const ICON_HEIGHT := 39

const NUMBER_X := 46
const NUMBER_Y := 5

const TEXT_Y := 58

# =====================================================
# UI
# =====================================================

var _panel: PixelPanel

var _icon: PixelTexture

var _number_label: PixelLabel

var _text_label: PixelLabel


func _ready() -> void:
	_create_ui()


# =====================================================
# PUBLIC API
# =====================================================

func actualizar(restantes: int) -> void:

	_number_label.text = str(restantes)

	call_deferred("_update_layout")


# =====================================================
# UI
# =====================================================

func _create_ui() -> void:

	_panel = PixelPanel.small()

	_panel.resize(
		PANEL_WIDTH,
		PANEL_HEIGHT
	)

	add_child(_panel)

	# -------------------------------------------------
	# ICONO
	# -------------------------------------------------

	_icon = PixelTexture.icon(
		WATER_ICON,
		Vector2(
			ICON_WIDTH,
			ICON_HEIGHT
		)
	)

	_panel.add_control(
		_icon,
		Vector2(
			ICON_X,
			ICON_Y
		)
	)

	# -------------------------------------------------
	# NUMERO
	# -------------------------------------------------

	_number_label = PixelLabel.counter_number("55")

	_panel.add_control(
		_number_label,
		Vector2(
			NUMBER_X,
			NUMBER_Y
		)
	)

	# -------------------------------------------------
	# TEXTO
	# -------------------------------------------------

	_text_label = PixelLabel.counter_text(
		"RESTANTES"
	)

	_panel.add_control(
		_text_label,
		Vector2.ZERO
	)

	call_deferred("_update_layout")


# =====================================================
# PRIVATE
# =====================================================

func _update_layout() -> void:

	# Número alineado con el centro de la gota

	_number_label.position.y = (
		ICON_Y
		+
		(
			ICON_HEIGHT
			-
			_number_label.size.y
		)
		* 0.5
	)

	# Texto centrado

	_text_label.position.x = (
		(
			PANEL_WIDTH
			-
			_text_label.size.x
		)
		* 0.5
	)

	_text_label.position.y = TEXT_Y
