class_name HudMain
extends Control

const WATER_ICON := preload("res://assets/ui/water_icon.png")

# =====================================================
# LAYOUT
# =====================================================

const ICON_X := 18
const ICON_Y := 18

const TITLE_X := 88
const TITLE_Y := 14

const BAR_X := 88
const BAR_Y := 46

const TEXT_X := 88
const TEXT_Y := 68

const PERCENT_X := -500
const PERCENT_Y := 36

const ICON_SIZE := Vector2i(56, 67)


const TEXT_SPACING := 10
const PANEL_PADDING := 20

# =====================================================
# UI
# =====================================================

var _panel: PixelPanel

var _icon: PixelTexture
var _title: PixelLabel

var _progress: PixelProgressBar

var _current_label: PixelLabel
var _total_label: PixelLabel
var _percent_label: PixelLabel


func _ready() -> void:
	_create_ui()


# =====================================================
# PUBLIC API
# =====================================================

func actualizar(
	gotas_actuales: int,
	gotas_objetivo: int
) -> void:

	_progress.actualizar(
		gotas_actuales,
		gotas_objetivo
	)

	_current_label.text = str(gotas_actuales)

	_total_label.text = "/ %d GOTAS" % gotas_objetivo

	var porcentaje: int = 0

	if gotas_objetivo > 0:
		porcentaje = roundi(
			float(gotas_actuales)
			/
			float(gotas_objetivo)
			*
			100.0
		)

	_percent_label.text = "%d%%" % porcentaje

	call_deferred("_update_layout")


func actualizar_restantes(_restantes: int) -> void:
	pass


# =====================================================
# UI
# =====================================================

func _create_ui() -> void:

	_panel = PixelPanel.main()
	add_child(_panel)

	_icon = PixelTexture.icon(
		WATER_ICON,
		ICON_SIZE
	)

	_panel.add_control(
		_icon,
		Vector2(
			ICON_X,
			ICON_Y
		)
	)

	_title = PixelLabel.title(
		"AGUA RECUPERADA"
	)

	_panel.add_control(
		_title,
		Vector2(
			TITLE_X,
			TITLE_Y
		)
	)

	_progress = PixelProgressBar.new()

	_panel.add_control(
		_progress,
		Vector2(
			BAR_X,
			BAR_Y
		)
	)

	_current_label = PixelLabel.number("0")

	_panel.add_control(
		_current_label,
		Vector2(
			TEXT_X,
			TEXT_Y
		)
	)

	_total_label = PixelLabel.body("/ 0 GOTAS")

	_panel.add_control(
		_total_label,
		Vector2(
			TEXT_X + 30,
			TEXT_Y + 3
		)
	)

	_percent_label = PixelLabel.percent("0%")

	_panel.add_control(
		_percent_label,
		Vector2(
			PERCENT_X,
			PERCENT_Y
		)
	)

	call_deferred("_update_layout")


# =====================================================
# PRIVATE
# =====================================================

func _update_layout() -> void:

	_total_label.position.x = (
		_current_label.position.x
		+
		_current_label.size.x
		+
		TEXT_SPACING
	)

	_percent_label.position.x = (
		_panel.width()
		-
		_percent_label.size.x
		-
		PANEL_PADDING
	)
