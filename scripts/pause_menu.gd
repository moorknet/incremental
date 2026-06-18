extends CanvasLayer

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var abandon_btn: Button = $Panel/VBox/AbandonButton

func _ready() -> void:
	visible = false
	resume_btn.pressed.connect(_resume)
	abandon_btn.pressed.connect(_abandon)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		_resume()
	elif GameManager.run_active and not get_tree().paused:
		_open()

func open() -> void:
	if not GameManager.run_active:
		return
	_open()

func _open() -> void:
	visible = true
	get_tree().paused = true

func _resume() -> void:
	get_tree().paused = false
	visible = false

func _abandon() -> void:
	get_tree().paused = false
	visible = false
	GameManager.end_run()
