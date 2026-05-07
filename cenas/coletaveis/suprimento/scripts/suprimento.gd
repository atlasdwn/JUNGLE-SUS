extends StaticBody2D

@onready var sprite_interacao: Sprite2D = $SpriteInteracao

@export var item: ItemData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_interacao.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#func _on_collectible_area_entered(area: Area2D) -> void:
	#if area.owner.name == "Carina":
		#sprite_interacao.set_deferred('visible', true)		
#
#func _on_collectible_area_exited(area: Area2D) -> void:
	#if area.owner.name == "Carina":
		#sprite_interacao.set_deferred('visible', false)

func _on_collectible_area_body_entered(body: Node2D) -> void:
	if body.name == "Carina":
		sprite_interacao.set_deferred('visible', true)		

func _on_collectible_area_body_exited(body: Node2D) -> void:
	if body.name == "Carina":
		sprite_interacao.set_deferred('visible', false)
