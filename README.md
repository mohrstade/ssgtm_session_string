# Server Side GTM Session String Generator
Creates a Session String with a Session ID which is a timestamp when the session started, Session Number, and Update Timestamp.

## Persisting the Session String
To persist the cookie for example you can use the [Cookie Monster Template.](https://www.simoahava.com/custom-templates/cookie-monster/) You can persist the cookie for as long as you want as the session duration handling is happening within the generated value. My recommendation would be 400 days. Use the same cookie name as defined in the template. It also makes sense to not update the cookie on [`user_engagement`](https://support.google.com/analytics/answer/11109416?hl=en) event or any events that you do not want to trigger an extension of the session.

## Structure of the Cookie
This is the structure of the value:

session_id.session_number.last_update_timestamp

### For Example `1689148544303.1.11689148544303`

The Session id is: 1689148544303
It is the first Session since the cookie was generated.
The cookie was just generated and was never updated because the id and timestamp are matching. -> This is the Session start.
The Session started at GMT Wednesday, 12. July 2023 07:55:44.303

### For Example `1689152144303.2.1689157184220`

The Session id is: 1689152144303
It is the second Session since the cookie was generated.
The cookie was generated at  GTM 12. July 2023 08:55:44.303 and was last updated GMT 12. July 2023 10:19:44.220 . -> The user has been interacting since 5039917 milliseconds so about 1.4 hours.

# Inputs
## Cookie Name:
Name of the Session Cookie. This field sets the cookie's name to read the session's current value. Also, use the same name to write the value into the cookie.

## Session Lifetime:
Also you can set the lifetime for the session. This is used to determine after how many minutes of inactivity a new session id is generated and the session number is incremented by 1. Please don't confuse this with the lifetime of the cookie. This is determined by the value you define when setting the cookie.


![Screenshot 2023-07-12 at 12 04 28](https://github.com/mohrstade/ssgtm_session_string/assets/3420538/20646606-c51b-49df-a517-66dc3ac89689)
