#!/usr/bin/env python
import bottle
import requests
import os
import locale
import hashlib
import hmac
locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

app = bottle.app()

app_id = os.environ.get('ACCOUNTKIT_APP_ID')
app_secret = os.environ.get('ACCOUNTKIT_APP_SECRET')
client_token = os.environ.get('ACCOUNTKIT_CLIENT_TOKEN')
accountkit_version = 'v1.0'

@bottle.route('/')
def index():
    return bottle.template('index',
            app_id=app_id,
            csrf = 'DEADBEEF',
            accountkit_version = accountkit_version)

@bottle.route('/success', method='POST')
def success():
    query_params = bottle.request.forms.decode()

    code = query_params.get('code')

    token_url = 'https://graph.accountkit.com/'+accountkit_version+'/access_token'
    token_params = {'grant_type': 'authorization_code',
            'code': code,
            'access_token': 'AA|%s|%s'%(app_id, app_secret)
            }

    r = requests.get(token_url, params=token_params)
    token_response = r.json()

    print repr(token_response)

    user_id = token_response.get('id')
    user_access_token = token_response.get('access_token')
    refresh_interval = token_response.get('token_refresh_interval_sec')

    identity_url = 'https://graph.accountkit.com/'+accountkit_version+'/me'

    appsecret_proof = hmac.new(app_secret, user_access_token, hashlib.sha256)

    identity_params = {'access_token': user_access_token,
            'appsecret_proof': appsecret_proof.hexdigest()}

    r = requests.get(identity_url, params=identity_params)
    identity_response = r.json()

    print repr(identity_response)

    phone_number = identity_response.get('phone',{}).get('number', 'N/A')
    email_address = identity_response.get('email',{}).get('address', 'N/A')

    return bottle.template('response',
            user_id=user_id,
            phone_number=phone_number,
            email_address=email_address,
            user_access_token=user_access_token,
            refresh_interval=refresh_interval)

if __name__=='__main__':
    bottle.debug(True)
    port = 8080
    bottle.run(app=app, host='127.0.0.1', port=port)
