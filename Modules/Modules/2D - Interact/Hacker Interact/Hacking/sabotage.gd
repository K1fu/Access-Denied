extends Button

@export var cooldownTime: float = 10

@onready var Main: PanelContainer = $"../../../.."
@onready var HackScreen: CanvasLayer = $"../../../../.."
@onready var health_bar: ProgressBar = $"../../../../../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."

@onready var cooldowntimer: Timer = $CooldownTimer
@onready var cooldownpanel: PanelContainer = $cooldown_container
@onready var label = $cooldown_container/Label

func _ready() -> void:
	cooldowntimer.wait_time = cooldownTime
	cooldownpanel.hide()
	button.disabled = false

func _on_pressed() -> void:
	Main.Sabotage()
	_start_cooldown()

func _start_cooldown() -> void:
	if cooldowntimer.is_stopped():
		cooldowntimer.start()
		cooldownpanel.show()
		button.disabled = true

func _process(delta: float) -> void:
	if not cooldowntimer.is_stopped():
		label.text = str(round(cooldowntimer.time_left))

func _on_cooldown_timer_timeout() -> void:
	cooldownpanel.hide()
	button.disabled = false
