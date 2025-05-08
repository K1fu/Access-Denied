class_name CyberSecScreen
extends Control

signal hackable_selected(username: String)

const LABEL_SCENE: PackedScene = preload(
	"res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/CyberSecScreen/Hackables.tscn"
)

@onready var hackable_list: Control = $DevList
@onready var world_node:= get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()  # adjust path if different

var last_refresh: float = 0.0

func _ready() -> void:
	# 1️⃣ Connect to our new world signal via a Callable
	world_node.players_received.connect(Callable(self, "_on_players_received"))
	# 2️⃣ Prime the pump
	world_node.get_players()

func _process(delta: float) -> void:
	var now = Time.get_unix_time_from_system()
	if now - last_refresh >= 5:
		last_refresh = now
		world_node.get_players()

func _on_players_received(players: Array) -> void:
	# … your existing label‑instantiation & cleanup logic …
	for child in hackable_list.get_children():
		child.set_meta("delete", true)

	for data in players:
		if not data.is_hackable:
			continue
		var name = data.username
		var entry = hackable_list.get_node_or_null(name)
		if entry == null:
			entry = LABEL_SCENE.instantiate()
			entry.name = name
			# bind username so our handler knows who was clicked
			entry.connect(
				"selected",
				Callable(self, "_on_hackable_selected").bind(name)
			)
			hackable_list.add_child(entry)
		entry.set_meta("delete", false)
		entry.get_node("UsernameBox/Label").text = name

	for child in hackable_list.get_children():
		if child.get_meta("delete"):
			child.queue_free()

func _on_hackable_selected(username: String) -> void:
	emit_signal("hackable_selected", username)
