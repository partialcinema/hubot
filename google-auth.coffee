google = require "googleapis"
googleClientSecrets = require "./helper-client-id.json"

scopes = [
  'https://www.googleapis.com/auth/calendar'
]

CLIENT_ID = googleClientSecrets.web.client_id
CLIENT_SECRET = googleClientSecrets.web.client_secret

OAuth2 = google.auth.OAuth2
oauth2Client = new OAuth2 CLIENT_ID, CLIENT_SECRET, 'http://dev.partialcinema.com:3000/helper/auth'

accessToken = null
refreshToken = process.env.GOOGLE_CALENDAR_REFRESH_TOKEN

oauth2Client.setCredentials
  access_token: accessToken
  refresh_token: refreshToken

module.exports = oauth2Client