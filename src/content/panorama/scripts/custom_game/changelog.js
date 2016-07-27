"use strict";

function SendRequest( requestParams, successCallback )
{
    requestParams.AuthKey = "3mzyNGkbMUvWugUyNMV9";

    $.AsyncWebRequest('http://ec2-52-59-238-84.eu-central-1.compute.amazonaws.com/commander.php',
        {
            type: 'POST',
            data: { 
            	CommandParams: JSON.stringify(requestParams) 
            },
            success: function (data) {
                $.Msg('GDS Reply: ', data)
            }
        });
}

function GetSteamID32() {
    var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
}

function GetDate() {
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	return yyyy * 10000 + mm * 100 + dd;
}

// TODO: Back-end
var messages = [];
/*messages[0] = {"steamid" : 76561198054179075, "message" : "Testing messages"}
messages[1] = {"steamid" : 76561198054179075, "message" : "Testing messages x2"}
messages[2] = {"steamid" : 76561198001376044, "message" : "Testing messages x3"}*/

function toggleChangelog(arg){
	$("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"))

	if (arg) { //shortcut to open panel and select specific tab
		arg();
	}
}

function toggleDescription(arg){
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
	$("#showDescriptionButton").checked = true;
}

function toggleUpdates(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = true
	$("#creditsDisplay").visible = false
	$("#showUpdatesButton").checked = true;
}

function toggleCredits(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = true
	$("#showCreditsButton").checked = true;
}

function setMessagesNumber() {
	var messageCount = Object.keys(messages).length;

	$("#changelogNotificationLabel").text = messageCount;
}

function decrementLabelNumber(panel) {
	var number = parseInt(panel.text);
	number--;
	if (number <= 0) {
		panel.GetParent().visible = false;
	} else {
		panel.text = number;
	}
}

function setupCredits() {
	var panel = $("#creditsPanel");

	for (var contributor in GameUI.CustomUIConfig().premiumData) {
		(function () {
			var userPic = $.CreatePanel("Panel", panel, contributor);
			userPic.BLoadLayoutSnippet("userPic");

			var steamID64 = GameUI.CustomUIConfig().premiumData[contributor]["steamID64"];
			var steamID32 = GameUI.CustomUIConfig().premiumData[contributor]["steamID3"];

			for (var message in messages) {
				(function ( msg, steamID ) {
					if (msg.DeveloperSteamID == steamID) {
						var devMessagePanel = $.CreatePanel("Panel", userPic.FindChildTraverse("userPicMessages"), "devMessage_"+steamID);
						devMessagePanel.BLoadLayoutSnippet("devMessage");
						devMessagePanel.FindChildTraverse("devMessageLabel").text = "!";

						devMessagePanel.SetPanelEvent('onactivate', function(){
							var messageText = msg.Reply;
							Game.EmitSound( "ui.click_alt" );

							decrementLabelNumber($("#changelogNotificationLabel"))
							devMessagePanel.visible = false;

							$.DispatchEvent( "UIShowCustomLayoutPopupParameters", "CustomPopupTest", "file://{resources}/layout/custom_game/dev_message.xml", "popupvalue="+messageText);
							
							var playerID = Players.GetLocalPlayer();
							var info =  Game.GetPlayerInfo(Players.GetLocalPlayer());

						    var requestParams = {
						        Command: "MarkMessageRead",
								MessageID: msg.ID
						    };

					    	$.Msg(requestParams);
						    SendRequest( requestParams, null );

							//GameEvents.SendCustomGameEventToServer( "su_mark_message_read", { message_id: msg.ID } );
						});
					}
				})( messages[message], steamID32);
			}

			userPic.FindChildTraverse("avatar").steamid = steamID64;
			
			userPic.FindChildTraverse("userPicDescription").text = $.Localize(steamID64.toString()+ "_Description");

			userPic.FindChildTraverse("userPicName").github = GameUI.CustomUIConfig().premiumData[contributor]["github"];

			userPic.FindChildTraverse("userPicName").text = $.Localize(steamID64.toString()) + " (github)";
			userPic.FindChildTraverse("userPicName").SetPanelEvent('onactivate', function(){
				$.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), "https://github.com/"+userPic.FindChildTraverse("userPicName").github);
			});
		})();
	}
}

function sendMessage() {
	var text = $( "#submitInput" ).text;
	//GameEvents.SendCustomGameEventToServer( "su_send_message", { message: text } );
	
	var playerID = Players.GetLocalPlayer();
	var info =  Game.GetPlayerInfo(Players.GetLocalPlayer());

    var requestParams = {
        Command: "SendPlayerMessage",
        Data: {
	      SteamID: GetSteamID32(),
	      Nickname: info.player_name,
	      Message: $( "#submitInput" ).text,
	      TimeStamp: GetDate() 
	  	}
    };

    SendRequest( requestParams, null );
}

function newMessages( newMessages ) {
	messages = newMessages;

	setMessagesNumber();
	setupCredits();
}

function FromServerMsg( args ) {
	$.Msg(args.str)
}

(function() {
	$("#descriptionDisplay").visible = true;
	$("#showDescriptionButton").checked = true;

	GameEvents.Subscribe( "su_new_messages", newMessages );
	GameEvents.Subscribe( "su_server_msg", FromServerMsg );
})();