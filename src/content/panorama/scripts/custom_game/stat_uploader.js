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
            success: successCallback
        });
}

function SendCustomRequest(data, requestParams, successCallback) {
	$.AsyncWebRequest(data.url,
	{
		type: data.type,
		success: successCallback
	});
}


function SetAuthParams( args )
{
	authKey = args.AuthKey;
	url = args.URL;
}


(function() {
	GameUI.CustomUIConfig().SendRequest = SendRequest;
	GameUI.CustomUIConfig().SendCustomRequest = SendCustomRequest;
	GameEvents.Subscribe( "su_auth_params", SetAuthParams );
})();