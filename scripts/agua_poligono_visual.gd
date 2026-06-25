extends Node2D

@export var gotas_group: StringName = &"gotas_agua"

var _sub_viewport: SubViewport
var _viewport_sprite: Sprite2D
var _water_draw_node: Node2D
var _drop_texture: Texture2D

func _ready() -> void:
	_drop_texture = preload("res://assets/prototype/water_drop_soft.svg")
	
	_sub_viewport = SubViewport.new()
	_sub_viewport.disable_3d = true
	_sub_viewport.transparent_bg = true
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub_viewport.size = Vector2i(2048, 2048) 
	add_child(_sub_viewport)
	
	_water_draw_node = Node2D.new()
	_water_draw_node.draw.connect(_on_water_draw)
	_sub_viewport.add_child(_water_draw_node)
	
	_viewport_sprite = Sprite2D.new()
	_viewport_sprite.texture = _sub_viewport.get_texture()
	_viewport_sprite.centered = false
	_viewport_sprite.material = self.material
	add_child(_viewport_sprite)
	
	var canvas_group = get_parent().get_node_or_null("AguaCanvasGroup") as CanvasGroup
	if canvas_group:
		canvas_group.hide()

func _process(_delta: float) -> void:
	if _water_draw_node:
		_water_draw_node.queue_redraw()

func _on_water_draw() -> void:
	if _drop_texture == null:
		return
		
	var gotas = get_tree().get_nodes_in_group(gotas_group)
	if gotas.is_empty():
		return
		
	var scaled_size = _drop_texture.get_size() * 0.7
	var offset = scaled_size / 2.0
	
	for gota in gotas:
		if gota is Node2D and not gota.is_queued_for_deletion():
			var rect = Rect2(gota.global_position - offset, scaled_size)
			_water_draw_node.draw_texture_rect(_drop_texture, rect, false)
