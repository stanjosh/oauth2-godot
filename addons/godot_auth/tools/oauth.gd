extends Node
class_name Oauth2

signal token_authorized
signal token_error(error : String)
signal working
signal logged_out

var port : int
var binding : String
var client_id : String
var client_secret : String
var auth_server : String
var token_req : String
var token_key : String

var redirect_server = TCPServer.new()
var token : String
var refresh_token : String
var user_info : Dictionary


@export var environment_variables : Dictionary
@export_file("*.html*") var authorized_html_page : String = "res://addons/godot_auth/tools/authorized.html.txt"

#vars is a dictionary containing the standard Oauth2 environment variables and a password to read the encrypted tokens
func _init(vars : Dictionary = {}) -> void:
	if vars:
		environment_variables = vars

func _ready():
	if environment_variables:
		use_vars(environment_variables)
	if port and binding and client_id and client_secret and auth_server and token_req:
		if load_tokens():
			authorize()
		set_process(false)
	else:
		push_error("Missing some environment variables for Oauth. Check node inspector")
		
func _process(_delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			print(request)
			var auth_code = request.split("&scope")[0].split("=")[1]
			prints("Received auth code")
			get_token_from_auth(auth_code)
			connection.put_data(HTML.new(authorized_html_page).ascii())
			set_process(false)

func use_vars(vars : Dictionary) -> void:
	port = vars.oauth_port
	binding = vars.oauth_binding
	client_id = vars.oauth_client_id
	client_secret = vars.oauth_client_secret
	auth_server = vars.oauth_auth_server
	token_req = vars.oauth_token_req
	token_key = vars.oauth_token_key

func authorize():
	load_tokens()
	if !await validate_tokens():
		if !await refresh_tokens():
			get_auth_code()

func get_auth_code() -> void:
	set_process(true)
	redirect_server.listen(port, binding)
	if redirect_server.is_listening():
		prints("listening on", redirect_server.get_local_port())
	
	var uri_parts := [
		"client_id=%s" % client_id,
		"redirect_uri=http://%s:%s" % [binding, port],
		"response_type=code",
		"scope=https://www.googleapis.com/auth/userinfo.email"
	]
	
	var uri = auth_server + "?" + "&".join(uri_parts)
	var error = OS.shell_open(uri)
	if error != OK:
		token_error.emit("Couldn't open: \"%s\". Error code: %s." % [uri, error])
		push_error("Couldn't open: \"%s\". Error code: %s." % [uri, error])

func get_token_from_auth(auth_code) -> void:
	print("Getting token from auth")
	var body = "&".join([
		"code=%s" % auth_code, 
		"client_id=%s" % client_id,
		"client_secret=%s" % client_secret,
		"redirect_uri=http://%s:%s" % [binding, port],
		"grant_type=authorization_code"
	])
	var response : Dictionary = await _http_post(token_req, body)
	print("token request completed")
	print(response)
	if response.has("error"):
		push_error(response["error"], " : ", response["error_description"])
		return
	token = response["access_token"]
	refresh_token = response["refresh_token"]
	user_info = await get_user_info()
	token_authorized.emit()
	save_tokens()

func refresh_tokens() -> bool:
	print("refreshing tokens")
	var body = "&".join([
		"client_id=%s" % client_id,
		"client_secret=%s" % client_secret,
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	])

	var response : Dictionary = await _http_post(token_req, body)
	print(response)
	if response.has("error"):
		push_warning(response["error"], " : ", response["error_description"])
		return false
	elif response.get("access_token"):
		token = response["access_token"]
		save_tokens()
		print("token refreshed")
		user_info = await get_user_info()
		token_authorized.emit()
		return true
	token_error.emit("Could not refresh tokens.")
	return false
	
func validate_tokens() -> bool:
	print("validating token")
	var body = "access_token=%s" % token
	var response : Dictionary = await _http_post(token_req, body)
	print(response)
	if token and response.has("expiration") and int(response["expiration"]) > 0:
		print(response["expiration"])
		print("token is valid")
		user_info = await get_user_info()
		token_authorized.emit()
		return true
	return false

func load_tokens() -> bool:
	print("Loading tokens")
	var file := FileAccess.open_encrypted_with_pass("user://token.dat", FileAccess.READ, token_key)
	if file != null:
		var tokens = file.get_var()
		token = tokens.get("token")
		refresh_token = tokens.get("refresh_token")
		file.close()
		return true
	return false

func save_tokens() -> void:
	print("Saving tokens")
	var file = FileAccess.open_encrypted_with_pass("user://token.dat", FileAccess.WRITE, token_key)
	if file != null:
		var tokens = {
			"token" : token,
			"refresh_token" : refresh_token
		}
		file.store_var(tokens)
		file.close()
	else:
		token_error.emit("Cannot save tokens!")
		push_error("cannot write to user://token.dat")

func clear_tokens():
	user_info = {}
	DirAccess.remove_absolute("user://token.dat")
	logged_out.emit()

func get_user_info() -> Dictionary:
	working.emit()
	var url = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=%s" % token
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
		]
	headers = PackedStringArray(headers)
	var _http_request = HTTPRequest.new()
	add_child(_http_request)
	var response_code = _http_request.request(url, headers, HTTPClient.METHOD_GET)
	if response_code == OK:
		var response = await _http_request.request_completed
		print(response[3].get_string_from_utf8())
		return JSON.parse_string(response[3].get_string_from_utf8())
	else:
		return {}


func _http_post(url: String, request_data: String = "") -> Dictionary:
	working.emit()
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
		]
	headers = PackedStringArray(headers)
	var _http_request = HTTPRequest.new()
	add_child(_http_request)
	var response_code = _http_request.request(url, headers, HTTPClient.METHOD_POST, request_data)
	if response_code == OK:
		var response = await _http_request.request_completed
		return JSON.parse_string(response[3].get_string_from_utf8())
	else:
		return {}
