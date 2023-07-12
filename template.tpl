___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Generate Session String",
  "description": "",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "cookieName",
    "displayName": "Name of the Session Cookie",
    "simpleValueType": true,
    "defaultValue": "_fp_custom_session"
  },
  {
    "type": "TEXT",
    "name": "lifetimeMinutes",
    "displayName": "Lifetime of the Session in Minutes",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ],
    "defaultValue": 30
  }
]


___SANDBOXED_JS_FOR_SERVER___

const getCookieValues = require("getCookieValues");
const getTimestampMillis = require("getTimestampMillis");
const logToConsole = require('logToConsole');
const makeNumber = require('makeNumber');

const cookie_name = data.cookieName||"_fp_custom_session";
const session_lifetime_mins = data.lifetimeMinutes||30;
const separator = ".";

const current_timestamp_ms = getTimestampMillis();

const update_session_cookie = function (curent_session_number, current_session_id) {

  const timestamp_ms = current_timestamp_ms;
  logToConsole(curent_session_number);
  let session_number =  current_session_id && curent_session_number ?  curent_session_number : curent_session_number++;
  logToConsole(curent_session_number);
  const session_id = current_session_id || timestamp_ms;
  const session_array = [session_id,curent_session_number,timestamp_ms];
  const session_string = session_array.join(separator);
  logToConsole({session_string: session_string});
  return session_string;
};

//readSessionCookie
const cookie = getCookieValues(cookie_name, true);

//ExtractSession ID, Number
if(cookie.length) {
  logToConsole(cookie);
  const cookieArray = cookie[0].split(".");
  const cookie_timestamp_ms = cookieArray[2];
  const cookie_session_no = makeNumber(cookieArray[1]);
  const cookie_session_id = cookieArray[0];
  if(current_timestamp_ms - cookie_timestamp_ms > session_lifetime_mins *60*1000) {
     logToConsole("Session older than session lifetime");
     return update_session_cookie(cookie_session_no, undefined);
  } else {
    logToConsole("still the same session");
    return update_session_cookie(cookie_session_no,cookie_session_id);
  }
} else {
  logToConsole("New user");
  return update_session_cookie(0);
}
data.gtmOnSuccess();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: sessionOlderThenLifetime
  code: |-
    const mockData = {
      // Mocked field values
    };

    mock("getCookieValues", (name, encode) => {
      return ["108101939925376.1.168909533362"];
    });

    mock("setCookie", (cookieName, cookieValue, cookieSettings) => {
      if (cookieName === "_fp_custom_session") {
        const cookieTimstamp = cookieValue.split(".")[1];
        assertThat(cookieTimstamp).isEqualTo("2");
      }
      else {
        fail("Unexpected cookie: " + cookieName);
      }
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
setup: ''


___NOTES___

Created on 12/07/2023, 11:07:43


