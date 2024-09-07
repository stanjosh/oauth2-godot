### oauth2-godot
# Google Oauth for Godot 4


[Instructions](#instructions) | [Customization](#customize-html-page) | [How This Works](#how-this-works)


## Instructions
1. Create a set of Oauth2 credentials using [Google Cloud Console](https://developers.google.com/identity/protocols/oauth2)
2. Create an dictionary with the credentials in this format, and fill in your info :
	```
	var oauth_credentials = {
		oauth2_port:54140,
		oauth2_binding:"127.0.0.1",
		oauth2_client_id:"example",
		oauth2_client_secret:"example",
		oauth2_auth_server:"URI",
		oauth2_token_req:"URI",
		oauth2_token_key:"password"
	}
	```

	Port and binding have default values, no need to include them... usually.

	These are prefixed with oauth2_ because I recommend using something like [GD Credentials](https://godotengine.org/asset-library/asset/3302), as you can encrypt the credentials with a password and access them from a global dictionary.

3. Create an instance of the oauth2 node
	```
	var oauth = oauth2.new(oauth_credentials)
	```

	When this node enters the tree, it will attempt to find any valid local tokens and re-authorize them. Otherwise, it just waits for you to call
	```
	oauth.authorize()
	```
	Which will do all of the necessary black magic of tokens.

4. Retrieve user email, name and other scoped information as a dictionary
	```
	oauth.user_info
	```

5. Sign out and remove local data:
	```
	oauth.clear_tokens()
	```
---

## Customize HTML Page
	The successful authorization HTML page is in the /root/addons/godot_auth/tools directory. It doesn't do anything special, modify it to your will.
## How this works:
	I am not going to explain Oauth2. That is for you to figure out: [Oauth2](https://developers.google.com/identity/protocols/oauth2)

	The node creates a TCP server and waits for a connection from the Oauth server, basically. They send some stuff back and forth, and decide whether the token is valid or not. Then, the node saves it locally encrypted and sends another request for the information included in the scope of the credentials, and stores the recieved info in a dictionary. The node shuts down the TCP server when it is not actively trying to authorize.

---
## Why
Much of this was updated from this tutorial, which is very nice, but quite outdated: [OAuth 2.0 in The Godot Engine](
https://youtu.be/07xfNmyJ9Nw?si=WzO_eqYrKJTT10a9)

## License
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007