extends Control

signal account_created(email, username, password)
signal account_creation_failed(email, username, password, response_code)

@onready var email_input : LineEdit = %Email
@onready var username_input : LineEdit = %Username
@onready var password_input : LineEdit = %Password
@onready var password2_input : LineEdit = %Password2
@onready var error_text : Label = %ErrorText
@onready var bak_button = $BAKBUTTOn
@onready var loading : Control = $Spinner

@onready var toggle_password_visibility : TextureButton = $Izopanel/Password/ToggleVisibility
@onready var toggle_password2_visibility : TextureButton = $Izopanel/Password2/ToggleVisibility



@export var load_scene : PackedScene

var busy : bool = false

func _ready():
	loading.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$CreateAccount.pressed.connect(create_account)
	bak_button.pressed.connect(_on_bak_button_pressed)

	# Connect password visibility toggles
	$Izopanel/Password/ToggleVisibility.pressed.connect(toggle_password_hidden)
	$Izopanel/Password2/ToggleVisibility.pressed.connect(toggle_password2_hidden)

	# Set tooltips
	$Izopanel/Password/ToggleVisibility.tooltip_text = "Show/Hide Password"
	$Izopanel/Password2/ToggleVisibility.tooltip_text = "Show/Hide Confirm Password"


	# Set default icon states
	update_password_icon()
	update_password2_icon()

func _on_bak_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Log In or Sign Up/createandlogin.tscn")

func toggle_password_hidden():
	password_input.secret = !password_input.secret
	update_password_icon()

func toggle_password2_hidden():
	password2_input.secret = !password2_input.secret
	update_password2_icon()

func update_password_icon():
	var icon_path : String
	if password_input.secret:
		icon_path = "res://addons/GD-Sync/UI/Icons/eyeclose.png"
	else:
		icon_path = "res://addons/GD-Sync/UI/Icons/eye.png"
		
	if FileAccess.file_exists(icon_path):
		toggle_password_visibility.texture_normal = load(icon_path)

func update_password2_icon():
	var icon_path : String
	if password2_input.secret:
		icon_path = "res://addons/GD-Sync/UI/Icons/eyeclose.png"
	else:
		icon_path = "res://addons/GD-Sync/UI/Icons/eye.png"

	if FileAccess.file_exists(icon_path):
		toggle_password2_visibility.texture_normal = load(icon_path)



func create_account() -> void:
	if busy:
		loading.visible = true
		return

	busy = true
	loading.visible = true

	var email : String = email_input.text
	var username : String = username_input.text
	var password : String = password_input.text
	var confirm_password : String = password2_input.text

	if password != confirm_password:
		error_text.text = "Passwords do not match."
		loading.visible = false
		busy = false
		return

	var response_code : int = await GDSync.create_account(email, username, password)

	if response_code == ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.SUCCESS:
		error_text.text = ""
		account_created.emit(email, username, password)
		get_tree().change_scene_to_packed(load_scene)
	else:
		set_error_text(response_code)
		account_creation_failed.emit(email, username, password, response_code)

	loading.visible = false
	busy = false

func set_error_text(response_code : int) -> void:
	match response_code:
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.NO_RESPONSE_FROM_SERVER:
			error_text.text = "No response from server."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.DATA_CAP_REACHED:
			error_text.text = "Data transfer cap has been reached."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.RATE_LIMIT_EXCEEDED:
			error_text.text = "Rate limit exceeded, please wait and try again."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.NO_DATABASE:
			error_text.text = "API key has no linked database."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.STORAGE_FULL:
			error_text.text = "Database is full."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.INVALID_EMAIL:
			error_text.text = "Invalid email address."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.INVALID_USERNAME:
			error_text.text = "Username contains illegal characters."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.EMAIL_ALREADY_EXISTS:
			error_text.text = "An account with this email address already exists."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.USERNAME_ALREADY_EXISTS:
			error_text.text = "An account with this username already exists."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.USERNAME_TOO_SHORT:
			error_text.text = "Username is too short."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.USERNAME_TOO_LONG:
			error_text.text = "Username is too long."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.PASSWORD_TOO_SHORT:
			error_text.text = "Password is too short."
		ENUMS.ACCOUNT_CREATION_RESPONSE_CODE.PASSWORD_TOO_LONG:
			error_text.text = "Password is too long."
