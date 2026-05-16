extends TileMapLayer

var fade_tween: Tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Carina":
		_fade_to(0.4)
		get_tree().call_group("player_torch", "add_obstruction")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Carina":
		_fade_to(1.0)
		get_tree().call_group("player_torch", "remove_obstruction")

func _fade_to(target_alpha: float) -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", target_alpha, 0.2)
