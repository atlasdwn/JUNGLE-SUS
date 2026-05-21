extends CanvasLayer

@onready var content: RichTextLabel = $DialogUI/DialogBG/Content
@onready var name_label: Label = $DialogUI/NameLabel
@onready var portrait: Sprite2D = $DialogUI/Portrait
@onready var dialog_ui: Control = $DialogUI
@onready var timer: Timer = $DialogUI/Timer
@onready var dialog_progress: PanelContainer = $DialogUI/DialogProgress
@onready var dialog_progress_button: Label = $DialogUI/DialogProgress/DialogProgressButton
@onready var animation_player: AnimationPlayer = $DialogUI/DialogProgress/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
