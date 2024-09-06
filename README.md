## oauth2-godot
#Google Oauth for Godot 4



###How to set up Google Oauth2:




A version of this tutorial from a few years ago, updated for Godot 4
https://youtu.be/07xfNmyJ9Nw?si=gazryMKF7VlgxEdW

1. Create a set of Oauth2 credentials using [Google Cloud Console](https://developers.google.com/identity/protocols/oauth2)
2. Create an dictionary with the credentials in this format, and fill in your info. Port and binding don't have to change.:
	```
	{
		oauth2_port:54545,
		oauth2_binding:"127.0.0.1",
		oauth2_client_id:"example",
		oauth2_client_secret:"example",
		oauth2_auth_server:"example",
		oauth2_token_req:"example",
		oauth2_token_key:"password"
	}
	```
3. Create an instance of the oauth2 node
```
var oauth = oauth2.new(dictionary_of_oauth2_credentials)
```
