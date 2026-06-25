class_name PixelLabel
extends Label

const UITheme = preload("res://scripts/ui/ui_theme.gd")


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


# =====================================================
# HUD MAIN
# =====================================================

static func title(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		UITheme.TITLE_SIZE,
		UITheme.COLOR_WHITE
	)


static func number(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		UITheme.NUMBER_SIZE,
		UITheme.COLOR_PRIMARY
	)


static func body(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_MEDIUM,
		UITheme.TEXT_SIZE,
		UITheme.COLOR_WHITE
	)


static func percent(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		UITheme.TITLE_SIZE + 5,
		UITheme.COLOR_PRIMARY
	)


# =====================================================
# HUD COUNTER
# =====================================================

static func counter_number(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		43,
		UITheme.COLOR_WHITE
	)


static func counter_text(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		16,
		UITheme.COLOR_PRIMARY
	)


# =====================================================
# HUD LEVEL
# =====================================================

static func level_title(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		24,
		Color("#F8E001")
	)


static func level_number(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		UITheme.TITLE_SIZE +15,
		UITheme.COLOR_WHITE
	)


# =====================================================
# FUTUROS COMPONENTES
# =====================================================
#
# Victory
static func victory_title(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		42,
		Color("#F8E001")
	)


static func victory_subtitle(value: String) -> PixelLabel:
	return _create(
		value,
		UITheme.FONT_BOLD,
		20,
		UITheme.COLOR_WHITE
	)

# Defeat
# Timer
# Dialog
# Buttons
#
# =====================================================


# =====================================================
# PRIVATE
# =====================================================

static func _create(
	value: String,
	font: FontFile,
	size: int,
	color: Color
) -> PixelLabel:

	var label := PixelLabel.new()

	label.text = value

	label._apply_style(
		font,
		size,
		color
	)

	return label


func _apply_style(
	font: FontFile,
	size: int,
	color: Color
) -> void:

	add_theme_font_override(
		"font",
		font
	)

	add_theme_font_size_override(
		"font_size",
		size
	)

	add_theme_color_override(
		"font_color",
		color
	)

	horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	mouse_filter = Control.MOUSE_FILTER_IGNORE
