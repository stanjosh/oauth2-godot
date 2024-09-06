@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"Oauth2", 
		"Node", 
		load("res://addons/godot_auth/tools/oauth.gd"),
		load("res://addons/godot_auth/oauth_icon.png"))


func _exit_tree():
	remove_custom_type('Oauth2')
