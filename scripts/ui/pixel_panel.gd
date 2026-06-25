class_name PixelPanel
extends Control

const MAIN_FRAME := preload("res://assets/ui/hud_main_frame.png")
const SMALL_FRAME := preload("res://assets/ui/hud_small_frame.png")

var _background: PixelTexture


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


# =====================================================
# FACTORY
# =====================================================

static func main() -> PixelPanel:
	return _create(MAIN_FRAME)


static func small() -> PixelPanel:
	return _create(SMALL_FRAME)


static func custom(
	texture: Texture2D
) -> PixelPanel:
	return _create(texture)


static func _create(
	texture: Texture2D
) -> PixelPanel:

	var panel := PixelPanel.new()

	panel._background = PixelTexture.frame(texture)

	panel.add_child(panel._background)

	panel.resize(
		texture.get_width(),
		texture.get_height()
	)

	return panel


# =====================================================
# HELPERS
# =====================================================

func add_control(
	control: Control,
	position: Vector2
) -> void:

	control.position = position

	add_child(control)


func resize(
	width: float,
	height: float
) -> PixelPanel:

	custom_minimum_size = Vector2(
		width,
		height
	)

	size = custom_minimum_size

	if _background != null:
		_background.resize(
			width,
			height
		)

	return self


func panel_size() -> Vector2:
	return size


func width() -> float:
	return size.x


func height() -> float:
	return size.y
