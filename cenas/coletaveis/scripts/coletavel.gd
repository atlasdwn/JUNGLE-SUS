@tool
class_name Coletavel extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var sprite_interacao: Sprite2D = $SpriteInteracao
@export var item: ItemData
@onready var anim_player: AnimationPlayer = $SpriteInteracao/AnimPlayer

var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = item.texture
	sprite_interacao.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_collectible_area_body_entered(_body: Node2D) -> void:
	anim_player.play("show")
	player=_body
	sprite_interacao.set_deferred('visible', true)
	player.collectible=self
	player.collectible_in_area = true

func _on_collectible_area_body_exited(_body: Node2D) -> void:
	anim_player.play('hide')
	player.collectible_in_area = false
	player.collectible = null
