class_name TerrainVisual
extends Sprite2D

## Render exclusivamente basado en una ImageTexture. Este nodo nunca
## lee del TileMap: solo refleja en pantalla lo que hay en la Image que
## le pasa TerrainSystem.

var _image: Image
var _texture: ImageTexture


func _ready() -> void:
	centered = false


func set_image(
	image: Image
) -> void:

	_image = image

	_texture = ImageTexture.create_from_image(_image)

	texture = _texture

	position = Vector2.ZERO


## Sube la Image completa a la GPU. Costoso en imágenes grandes;
## se prefiere update_image_region cuando se conoce el área afectada.
func update_image() -> void:

	if _texture == null:
		return

	_texture.update(_image)


## Punto de extensión para actualización parcial de la textura.
##
## ImageTexture no expone una actualización parcial pública en GDScript
## (ImageTexture.update() siempre sube la Image completa). Godot sí
## tiene RenderingServer.texture_2d_update() / texture_set_data_partial
## a nivel de servidor, pero usarlo aquí acoplaría TerrainVisual a la
## RID interna de la textura y a su formato exacto, lo cual es frágil
## entre versiones de Godot.
##
## Por eso esta función mantiene la firma con la región (para que
## TerrainSystem no tenga que cambiar si en el futuro se implementa la
## actualización parcial real vía RenderingServer) pero, por ahora,
## delega en update_image(). Para los tamaños de imagen típicos de un
## nivel 2D (cientos de miles de píxeles, no millones) el costo de
## update_image() en cada excavación es bajo y no requiere esta
## optimización para mantener un framerate estable.
func update_image_region(
	_region: Rect2i
) -> void:

	update_image()


func image() -> Image:
	return _image
