"use strict";

var authKey = null;
var url = null;

function SendRequest( requestParams, successCallback )
{
	if (!authKey || ! url)
	{
		$.Msg('Auth key or URL is empty!');
		return;
	}

    requestParams.AuthKey = authKey;

    $.AsyncWebRequest(url,
        {
            type: 'POST',
            data: { 
            	CommandParams: JSON.stringify(requestParams) 
            },
            success: function (data) {
            }
        });
}


function SetAuthParams( args )
{
	authKey = args.AuthKey;
	url = args.URL;
}


(function() {
	GameUI.CustomUIConfig().SendRequest = SendRequest;
	GameEvents.Subscribe( "su_auth_params", SetAuthParams );
})();