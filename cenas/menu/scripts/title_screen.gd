extends Control

const HOVER_ROTATION := deg_to_rad(4.0)
const HOVER_TWEEN_DURATION := 0.12

@export_file("*.tscn") var world_scene_path := "res://cenas/cutscenes/cutscene_inicio.tscn"

@onready var start_button: TextureButton = $SafeArea/BottomDock/BottomRow/Buttons/StartButton
@onready var exit_button: TextureButton = $SafeArea/BottomDock/BottomRow/Buttons/ExitButton

var button_tweens: Dictionary[TextureButton, Tween] = {}


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_prepare_button(start_button)
	_prepare_button(exit_button)
	_setup_hover_rotation(start_button)
	_setup_hover_rotation(exit_button)


func _prepare_button(button: TextureButton) -> void:
	button.rotation = 0.0
	_center_button_pivot(button)
	_center_button_pivot.bind(button).call_deferred()
	button.resized.connect(_center_button_pivot.bind(button))


func _center_button_pivot(button: TextureButton) -> void:
	button.pivot_offset = button.size * 0.5


func _setup_hover_rotation(button: TextureButton) -> void:
	button.mouse_entered.connect(_rotate_button.bind(button, HOVER_ROTATION))
	button.mouse_exited.connect(_rotate_button.bind(button, 0.0))


func _rotate_button(button: TextureButton, target_rotation: float) -> void:
	_center_button_pivot(button)

	if button_tweens.has(button):
		button_tweens[button].kill()

	var tween := create_tween()
	button_tweens[button] = tween
	tween.tween_property(button, "rotation", target_rotation, HOVER_TWEEN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_start_pressed() -> void:
	if not ResourceLoader.exists(world_scene_path):
		push_warning("Nao encontrei a cena do mundo em: %s" % world_scene_path)
		return

	get_tree().change_scene_to_file(world_scene_path)


func _on_exit_pressed() -> void:
	get_tree().quit()
