class_name HudLevel
extends Control

# =====================================================
# PANEL
# =====================================================

const PANEL_WIDTH := 88
const PANEL_HEIGHT := 86

# =====================================================
# LAYOUT
# =====================================================

const TITLE_Y := 12
const NUMBER_Y := 35

# =====================================================
# UI
# =====================================================

var _panel: PixelPanel

var _title_label: PixelLabel

var _number_label: PixelLabel


func _ready() -> void:
	_create_ui()


# =====================================================
# PUBLIC API
# =====================================================

func actualizar(nivel: int) -> void:

	_number_label.text = str(nivel).pad_zeros(2)

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

	#------------------------------------
	# TITULO
	#------------------------------------

	_title_label = PixelLabel.level_title(
		"NIVEL"
	)

	_panel.add_control(
		_title_label,
		Vector2.ZERO
	)

	#------------------------------------
	# NUMERO
	#------------------------------------

	_number_label = PixelLabel.level_number(
		"1"
	)

	_panel.add_control(
		_number_label,
		Vector2.ZERO
	)

	call_deferred("_update_layout")


# =====================================================
# PRIVATE
# =====================================================

func _update_layout() -> void:

	_title_label.position.x = (
		(PANEL_WIDTH - _title_label.size.x) * 0.5
	)

	_title_label.position.y = TITLE_Y

	_number_label.position.x = (
		(PANEL_WIDTH - _number_label.size.x) * 0.5
	)

	_number_label.position.y = NUMBER_Y
