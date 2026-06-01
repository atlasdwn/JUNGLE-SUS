class_name Player extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Anim
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var poeira_passo: Marker2D = $PoeiraPasso
@onready var folhas_ambiente: GPUParticles2D = get_node_or_null("FolhasAmbiente")

@export var camera : Camera2D
@export var inventory : InventoryData

const WALK_DUST_INTERVAL := 0.12

var is_collecting = false
var collectible = null
var acceleration := 5
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var collectible_in_area = false
var walk_dust_enabled := false
var walk_dust_timer := 0.0
var walk_dust_left_step := false

func _ready():
	var active_camera := camera
	if active_camera == null:
		active_camera = get_node_or_null("Camera2D") as Camera2D

	if active_camera != null:
		$RemoteTransform2D.remote_path = active_camera.get_path()

	state_machine.initialize(self)
	
	if folhas_ambiente != null:
		_ciclo_folhas()

# Controla as folhas caindo (liga e desliga aleatoriamente)
func _ciclo_folhas() -> void:
	if not is_inside_tree() or folhas_ambiente == null:
		return
	
	# Liga as folhas e deixa tocando por 3 a 6 segundos
	folhas_ambiente.emitting = true
	await get_tree().create_timer(randf_range(3.0, 6.0)).timeout
	
	if not is_inside_tree() or folhas_ambiente == null:
		return
		
	# Desliga as folhas e espera 5 a 10 segundos antes de voltar
	folhas_ambiente.emitting = false
	await get_tree().create_timer(randf_range(5.0, 10.0)).timeout
	
	# Inicia o loop de novo
	_ciclo_folhas()

func _process(_delta: float) -> void:
	if is_collecting == false:
		direction.x = Input.get_axis("esquerda","direita")
		direction.y = Input.get_axis("cima","baixo")

func _physics_process(delta: float) -> void:
	move_and_slide()
	_update_walk_dust(delta)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			# Força do empurrão. Se estiver muito rápido, abaixe. Se muito devagar, aumente.
			var push_force = 100.0
			collider.apply_central_impulse(-collision.get_normal() * push_force)

func set_direction() -> bool:
	var new_dir : Vector2 = cardinal_direction
	
	if direction == Vector2.ZERO:
		return false

	# Alterado para >= para dar prioridade à direção horizontal nas diagonais
	if abs(direction.x) >= abs(direction.y):
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	anim.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func update_animation(state : String) -> void:
	anim_player.play(state + "_" + anim_direction())
	
func anim_direction() -> String:
	match cardinal_direction:
		Vector2.DOWN:
			return	"down"
		Vector2.UP:
			return "up"
		_:
			return "side"

func set_walk_dust(enabled: bool) -> void:
	walk_dust_enabled = enabled
	if enabled == false:
		walk_dust_timer = 0.0

func _update_walk_dust(delta: float) -> void:
	if walk_dust_enabled == false or direction == Vector2.ZERO:
		return

	walk_dust_timer -= delta
	if walk_dust_timer > 0.0:
		return

	walk_dust_timer = WALK_DUST_INTERVAL
	_spawn_walk_dust()

func _spawn_walk_dust() -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return

	var move_vector := direction.normalized()
	var backward_vector := -move_vector
	var lateral_vector := Vector2(-move_vector.y, move_vector.x)

	walk_dust_left_step = !walk_dust_left_step
	var step_side := -2.5 if walk_dust_left_step else 2.5
	var burst_origin := poeira_passo.global_position
	burst_origin += lateral_vector * step_side
	burst_origin += backward_vector * 1.5
	burst_origin += Vector2(0, randf_range(-1.0, 1.0))

	for _i in range(3):
		var chunk := Polygon2D.new()
		var radius := randf_range(1.8, 3.2)
		chunk.polygon = _make_dirt_chunk_polygon(radius)
		chunk.color = _random_dirt_color()
		chunk.global_position = burst_origin
		chunk.global_position += lateral_vector * randf_range(-1.5, 1.5)
		chunk.global_position += backward_vector * randf_range(-1.0, 1.0)
		chunk.scale = Vector2.ONE * randf_range(0.9, 1.2)
		chunk.rotation = randf_range(-0.6, 0.6)
		chunk.z_index = 0
		parent_node.add_child(chunk)

		var target_position := chunk.global_position
		target_position += backward_vector * randf_range(5.0, 9.0)
		target_position += lateral_vector * randf_range(-4.5, 4.5)
		target_position += Vector2(0, randf_range(-4.0, -1.5))

		var tween := chunk.create_tween()
		tween.set_parallel(true)
		tween.tween_property(chunk, "global_position", target_position, 0.18)
		tween.tween_property(chunk, "rotation", chunk.rotation + randf_range(-1.2, 1.2), 0.18)
		tween.tween_property(chunk, "scale", chunk.scale * randf_range(0.85, 1.05), 0.18)
		tween.tween_property(chunk, "modulate:a", 0.0, 0.24)
		tween.chain().tween_callback(Callable(chunk, "queue_free"))

func _make_dirt_chunk_polygon(radius: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-radius, radius * 0.25),
		Vector2(-radius * 0.55, -radius * 0.6),
		Vector2(radius * 0.15, -radius),
		Vector2(radius * 0.95, -radius * 0.2),
		Vector2(radius * 0.55, radius * 0.8),
		Vector2(-radius * 0.2, radius),
	])

func _random_dirt_color() -> Color:
	match randi() % 3:
		0:
			return Color(0.44, 0.31, 0.18, 0.95)
		1:
			return Color(0.52, 0.37, 0.22, 0.92)
		_:
			return Color(0.34, 0.23, 0.13, 0.9)

func _on_collider_area_entered(area: Area2D) -> void:
	var area_owner := area.owner
	if area_owner != null and area_owner.is_in_group("Collectibles"):
		collectible = area_owner
		collectible_in_area = true

func _on_collider_area_exited(area: Area2D) -> void:
	if area.owner == collectible:
		collectible = null
		collectible_in_area = false

func assustar() -> void:
	var frames = anim.sprite_frames
	if frames and frames.has_animation("scare"):
		frames.set_animation_loop("scare", false)
	
	# Desabilita a StateMachine temporariamente para não voltar pro Idle sozinho
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Permite tocar mesmo que o jogo esteja pausado (ex: durante cutscene)
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Para a animação do AnimationPlayer (que controla o andar/idle) e toca a do AnimatedSprite2D
	anim_player.stop()
	anim.play("scare")

func acalmar() -> void:
	# Retorna o controle normal das animações
	anim.process_mode = Node.PROCESS_MODE_INHERIT
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_INHERIT
	
	update_animation("idle")

func bloquear_movimento() -> void:
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	update_animation("idle") 
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED

func liberar_movimento() -> void:
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_INHERIT
