___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


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
const Math = require('Math');

const cookie_name = data.cookieName||"_fp_custom_session";
const session_lifetime_mins = data.lifetimeMinutes||30;
const separator = ".";



function removeDigits(myNumber, digitsToRemove){
  return (myNumber- (myNumber%Math.pow(10, digitsToRemove)))/Math.pow(10, digitsToRemove);
}

const current_timestamp_seconds = removeDigits(getTimestampMillis(),3);

const update_session_cookie = function (curent_session_number, current_session_id) {

  logToConsole(curent_session_number);
  let session_number =  current_session_id && curent_session_number ?  curent_session_number : curent_session_number++;
  logToConsole(curent_session_number);
  const session_id = current_session_id || current_timestamp_seconds;
  const session_array = [session_id,curent_session_number,current_timestamp_seconds];
  const session_string = session_array.join(separator);
  logToConsole({session_string: session_string});
  //data.gtmOnSuccess();
  return session_string;
};


//readSessionCookie
const cookie = getCookieValues(cookie_name, true);

//ExtractSession ID, Number
if(cookie.length) {
  logToConsole(cookie);
  const cookieArray = cookie[0].split(".");
  //Need to check if timestamps are 10 digits long to ensure long session cookie is migrated to short one. Otherwise cut last 3 digits.
  const cookie_timestamp_seconds = cookieArray[2].length === 10 ? cookieArray[2] : removeDigits(cookieArray[2],3);
  const cookie_session_no = makeNumber(cookieArray[1]);
  const cookie_session_id = cookieArray[0].length === 10 ? cookieArray[0] : removeDigits(cookieArray[0],3);
  if(current_timestamp_seconds - cookie_timestamp_seconds > session_lifetime_mins * 60) {
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
      return ["1081019399.1.1689095333"];
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
- name: old Cookie sessionOlderThenLifetime
  code: |-
    const mockData = {
      // Mocked field values
    };

    mock("getCookieValues", (name, encode) => {
      return ["1081019399000.1.1689095333000"];
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
- name: same Session
  code: |
    const mockData = {
      // Mocked field values
    };

    // Mocking getCookieValues function to return a session cookie with a timestamp 30 minutes ago
    mock("getCookieValues", (name, encode) => {
      return ['1716752835.2.1716752835'];
    });

    // Mocking setCookie function to check if the session ID remains constant after an event within 30 minutes
    mock("setCookie", (cookieName, cookieValue, cookieSettings) => {
      if (cookieName === "_fp_custom_session") {
        // Splitting cookie value to extract session ID
        const sessionId = cookieValue.split(".")[0];
        // Asserting that the session ID remains constant after an event within 30 minutes
        assertThat(sessionId).isEqualTo("1716752835");
      } else {
        fail("Unexpected cookie: " + cookieName);
      }
    });

    // Call runCode to run the template's code.
    runCode(mockData);
setup: ''


___NOTES___

Created on 12/07/2023, 11:07:43


