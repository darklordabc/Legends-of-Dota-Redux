"use strict";

var authKey = null;
var url = null;

function SendRequest( requestParams, successCallback, errorCallback )
{
	if (!authKey || ! url)
	{
		$.Msg('Auth key or URL is empty!');
		return;
	}

    requestParams.AuthKey = authKey;
    var fullRequestParams = {
        type: 'POST',
        data: { 
        	CommandParams: JSON.stringify(requestParams) 
        },
        success: successCallback
    };

    if (errorCallback != null)
    	fullRequestParams.error = errorCallback;

    $.AsyncWebRequest(url, fullRequestParams);
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