extends CanvasLayer

var color_rect: ColorRect
var shader_material: ShaderMaterial
var _current_target: Node2D

func _ready() -> void:
	layer = 100 # Fica por cima de tudo
	process_mode = Node.PROCESS_MODE_ALWAYS # Continua rodando mesmo se o jogo pausar
	
	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	shader_material = ShaderMaterial.new()
	var shader = load("res://recursos/shaders/iris_transition.gdshader")
	if shader:
		shader_material.shader = shader
		shader_material.set_shader_parameter("circle_size", 1.05) # Começa aberto
		color_rect.material = shader_material
	
	add_child(color_rect)

# Efeito de abrir o círculo
func iris_in(target_node: Node2D, duration: float = 1.5) -> Signal:
	_current_target = target_node
	_update_center()
	
	shader_material.set_shader_parameter("circle_size", 0.0)
	var tween = create_tween()
	tween.tween_method(_set_circle_size, 0.0, 1.05, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween.finished

# Efeito de fechar o círculo
func iris_out(target_node: Node2D, duration: float = 1.5) -> Signal:
	_current_target = target_node
	_update_center()
	
	shader_material.set_shader_parameter("circle_size", 1.05)
	var tween = create_tween()
	tween.tween_method(_set_circle_size, 1.05, 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween.finished

func _set_circle_size(val: float) -> void:
	shader_material.set_shader_parameter("circle_size", val)
	_update_center() # Atualiza o centro caso a câmera ou o personagem se movam durante o tween

func _update_center() -> void:
	if not is_instance_valid(_current_target):
		return
	
	# Pega a posição do alvo na tela (considerando a câmera atual)
	var screen_pos = _current_target.get_global_transform_with_canvas().origin
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Converte a posição da tela para UV (0.0 a 1.0)
	var center_uv = screen_pos / viewport_size
	
	# Levanta um pouquinho o centro (porque o pivô da Carina é no pé, queremos focar no rosto)
	center_uv.y -= 0.05 
	
	shader_material.set_shader_parameter("center", center_uv)
