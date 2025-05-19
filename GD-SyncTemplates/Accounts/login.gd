extends Control

signal logged_in(email)
signal login_failed(email, response_code)

@onready var email_input : LineEdit = $LoginPanel/Email
@onready var password_input : LineEdit = $LoginPanel/Password
@onready var error_text : Label = $LoginPanel/ErrorText
@onready var back_button = $BackButton
@onready var loading : Control = $Spinner
@onready var toggler_button : Button = $LoginPanel/Password/ToggleVisibility

var busy : bool = false
var password_visible : bool = false

func _ready():
	loading.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	toggler_button.text = "👁️" 
	$LoginPanel/LogInButton.pressed.connect(login)
	back_button.pressed.connect(_on_back_button_pressed)
	toggler_button.pressed.connect(_on_ToggleVisibility_pressed) # <-- IMPORTANT

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Log In or Sign Up/createandlogin.tscn")

func _on_ToggleVisibility_pressed():
	print("Toggle button pressed!")  # ← for debugging
	password_visible = !password_visible
	password_input.secret = not password_visible
	if password_visible:
		toggler_button.text = "🙈"
	else:
		toggler_button.text = "👁️"


func login() -> void:
	if busy:
		loading.visible = true
		return
	busy = true
	loading.visible = true

	var email : String = email_input.text
	var password : String = password_input.text

	var response : Dictionary = await GDSync.login(email, password)
	var response_code : int = response["Code"]
	
	if response_code == ENUMS.LOGIN_RESPONSE_CODE.SUCCESS:
		error_text.text = ""
		logged_in.emit(email)
		get_tree().change_scene_to_file("res://Menus/Lobby/lobby_browsing_menu.tscn")
	else:
		set_error_text(response_code, response)
		login_failed.emit(email, response_code)

	loading.visible = false
	busy = false

func set_error_text(response_code : int, response : Dictionary) -> void:
	match(response_code):
		ENUMS.LOGIN_RESPONSE_CODE.NO_RESPONSE_FROM_SERVER:
			error_text.text = "No response from server."
		ENUMS.LOGIN_RESPONSE_CODE.DATA_CAP_REACHED:
			error_text.text = "Data transfer cap has been reached."
		ENUMS.LOGIN_RESPONSE_CODE.RATE_LIMIT_EXCEEDED:
			error_text.text = "Rate limit exceeded, please wait and try again."
		ENUMS.LOGIN_RESPONSE_CODE.NO_DATABASE:
			error_text.text = "API key has no linked database."
		ENUMS.LOGIN_RESPONSE_CODE.EMAIL_OR_PASSWORD_INCORRECT:
			error_text.text = "Email or password incorrect."
		ENUMS.LOGIN_RESPONSE_CODE.NOT_VERIFIED:
			error_text.text = "The email address has not yet been verified."
		ENUMS.LOGIN_RESPONSE_CODE.BANNED:
			var ban_time : int = response["BanTime"]
			if ban_time == -1:
				error_text.text = "Account is permanently banned."
			else:
				var ban_time_string : String = Time.get_datetime_string_from_unix_time(ban_time, true)
				error_text.text = "Account is banned until " + ban_time_string + "."

	loading.visible = false  # Make sure loading spinner is hidden on error
