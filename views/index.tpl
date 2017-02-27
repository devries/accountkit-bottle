<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Account Kit Test</title>

    <script src="https://sdk.accountkit.com/en_US/sdk.js"></script>

<script>
  // initialize Account Kit with CSRF protection
  AccountKit_OnInteractive = function(){
    AccountKit.init(
      {
        appId:"{{ app_id }}", 
        state:"{{ csrf }}", 
        version:"{{ accountkit_version }}",
        fbAppEventsEnabled:true
      }
    );
  };

  // login callback
  function loginCallback(response) {
    if (response.status === "PARTIALLY_AUTHENTICATED") {
      var code = response.code;
      var csrf = response.state;
      document.getElementById("code").value = code;
      document.getElementById("csrf").value = csrf;
      document.getElementById("login_success").submit();
    }
    else if (response.status === "NOT_AUTHENTICATED") {
      document.getElementById("message").innerText = "Not Authenticated";
    }
    else if (response.status === "BAD_PARAMS") {
      document.getElementById("message").innerText = "Bad Params";
    }
  }

  // phone form submission handler
  function smsLogin() {
    // var countryCode = document.getElementById("country_code").value;
    // var phoneNumber = document.getElementById("phone_number").value;
    AccountKit.login(
      'PHONE', 
      {countryCode: '+1', phoneNumber: ''}, // will use default values if not specified
      loginCallback
    );
  }


  // email form submission handler
  function emailLogin() {
    // var emailAddress = document.getElementById("email").value;
    AccountKit.login(
      'EMAIL',
      {emailAddress: ''},
      loginCallback
    );
  }
</script>

  </head>
  <body>
    <button onclick="smsLogin();">Login via SMS</button>
    <div>OR</div>
    <button onclick="emailLogin();">Login via Email</button>

  <form id="login_success" method="post" action="/success">
    <input id="csrf" type="hidden" name="csrf" />
    <input id="code" type="hidden" name="code" />
  </form>

  <div>
    <b>Message</b>: <span id="message"></span>
  </div>

</body>
</html>
