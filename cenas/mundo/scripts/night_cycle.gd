extends CanvasModulate

@export var day_color := Color.WHITE
@export var night_color := Color(0.32, 0.39, 0.62, 1.0)
@export_range(0.1, 600.0, 0.1) var fade_duration := 25.0
@export_range(0.0, 120.0, 0.1) var start_delay := 0.0
@export var auto_start := true

var night_tween: Tween


func _ready() -> void:
	color = day_color

	if auto_start:
		start_night_fade()


func start_night_fade() -> void:
	if night_tween != null:
		night_tween.kill()

	night_tween = create_tween()

	if start_delay > 0.0:
		night_tween.tween_interval(start_delay)

	night_tween.tween_property(self, "color", night_color, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func set_night_progress(progress: float) -> void:
	if night_tween != null:
		night_tween.kill()
		night_tween = null

	color = day_color.lerp(night_color, clampf(progress, 0.0, 1.0))
