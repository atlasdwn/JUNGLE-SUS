class_name Player extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Anim
@onready var collision: CollisionShape2D = $Collision
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

var acceleration := 5
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN

func _ready():
	state_machine.initialize(self)

func _process(_delta: float) -> void:
	direction.x = Input.get_axis("esquerda","direita")
	direction.y = Input.get_axis("cima","baixo")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func set_direction() -> bool:
	var new_dir : Vector2 = cardinal_direction
	if  direction == Vector2.ZERO:
		return false
		
	if direction.y == 0:
		Vector2()
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
		
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir ==cardinal_direction:
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
			
