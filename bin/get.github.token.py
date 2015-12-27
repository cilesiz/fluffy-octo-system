#!/usr/bin/env python
import requests
from getpass import getpass
import json

username = 'getmade' # Your GitHub username
password = 'k3b3rtx3la' # Your GitHub password

# Note that credentials will be transmitted over a secure SSL connection
url = 'https://api.github.com/authorizations'
note = 'Mining the Social Web, 2nd Ed.'
post_data = {'scopes':['repo'],'note': note }

response = requests.post(
    url,
    auth = (username, password),
    data = json.dumps(post_data),
    )   

print "API response:", response.text
print
print "Your OAuth token is", response.json()['token']

