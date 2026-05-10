class_name Player extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Anim
@onready var collision: CollisionShape2D = $Collision
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

@export var inventory : InventoryData

var is_collecting = false
var collectible = null
var acceleration := 5
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var collectible_in_area = false

func _ready():
	state_machine.initialize(self)

func _process(_delta: float) -> void:
	if is_collecting == false:
		direction.x = Input.get_axis("esquerda","direita")
		direction.y = Input.get_axis("cima","baixo")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func set_direction() -> bool:
	var new_dir : Vector2 = cardinal_direction
	
	if direction == Vector2.ZERO:
		return false

	if abs(direction.x) > abs(direction.y):
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

func _on_collider_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("Collectibles"):
		collectible = area.owner
		collectible_in_area = true
		
#func _on_collider_area_exited(area: Area2D) -> void:
	#if area.owner == collectible:
		#collectible = null
		#print(collectible)
		#collectible_in_area = false
		#print(collectible_in_area)
