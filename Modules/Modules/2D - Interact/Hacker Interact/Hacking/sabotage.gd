extends Button

@export var cooldownTime: float = 10

@onready var Main: Control = $"../../../../.."
@onready var HackScreen: CanvasLayer = $".."
@onready var health_bar: ProgressBar = $"../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."

@onready var cooldowntimer: Timer = $CooldownTimer
@onready var cooldownpanel: PanelContainer = $cooldown_container
@onready var label = $cooldown_container/Label

func _ready() -> void:
	cooldowntimer.wait_time = cooldownTime
	cooldownpanel.hide()

func _on_pressed() -> void:
	Main.Sabotage()
	_start_cooldown()

func _start_cooldown():
	if cooldowntimer.time_left: return
	
	cooldowntimer.start()
	cooldownpanel.show()

func _process(delta: float) -> void:
	if cooldowntimer.time_left:
		var roundCooldown = round(cooldowntimer.time_left)
		if roundCooldown == 0: roundCooldown = 1
		label.text = str(roundCooldown)

func _on_cooldown_timer_timeout() -> void:
	cooldownpanel.hide()
