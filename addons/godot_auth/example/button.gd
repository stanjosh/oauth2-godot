extends Button

##Make sure the button has a $RichTextLabel and you connect the _on_mouse_entered, _on_mouse_exited, and _on_pressed signals.
##Put a reference to your credentials dictionary in the constructor call Oauth2.new(credentials_reference) in the _ready function.

@onready var rich_text_label = $RichTextLabel

var oauth2 : Oauth2
var signed_in : bool = false

func _ready():
	oauth2 = Oauth2.new()
	add_child(oauth2)
	oauth2.connect("token_authorized", _on_token_authorized)
	oauth2.connect("token_error", _on_token_error)
	oauth2.connect("working", func(): rich_text_label.text= "[wave amp=50.0 freq=5.0 connected=1]...[/wave]" )
	oauth2.connect("logged_out", func(): rich_text_label.text= "Sign in with Google" )

func _on_pressed():
	if signed_in:
		oauth2.clear_tokens()
		signed_in = false
	else:
		oauth2.authorize()
	
func _on_token_authorized():
	rich_text_label.text = "%s" % oauth2.user_info.get("name")
	rich_text_label.tooltip_text = "sign out"
	signed_in = true
	pass
	
func _on_token_error(error : String):
	rich_text_label.text = "[color=red]error! %s[/color]" % error
	signed_in = false
	pass



func _on_mouse_entered():
	if signed_in:
		rich_text_label.text = "[color=red]sign out?[/color]"



func _on_mouse_exited():
	if signed_in:
		rich_text_label.text = "%s" % oauth2.user_info.get("name")
