extends Button

@export var cooldownTime: float = 2

@onready var health_bar: ProgressBar = $"../../../../../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."
@onready var DevScreen: CanvasLayer = $"../../../../.."
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var cooldown_container: PanelContainer = $cooldown_container
@onready var cooldown_count_label: Label = $cooldown_container/Label

func _ready() -> void:
	cooldown_timer.wait_time = cooldownTime
	cooldown_container.hide()
	button.disabled = false

func _on_pressed() -> void:
	health_bar.repair_health(10)
	DevScreen.hide()
	_start_cooldown()

func _start_cooldown():
	if cooldown_timer.is_stopped():
		cooldown_timer.start()
		cooldown_container.show()
		button.disabled = true

func _process(delta: float) -> void:
	if not cooldown_timer.is_stopped():
		cooldown_count_label.text = str(round(cooldown_timer.time_left))

func _on_cooldown_timer_timeout() -> void:
	cooldown_container.hide()
	button.disabled = false
