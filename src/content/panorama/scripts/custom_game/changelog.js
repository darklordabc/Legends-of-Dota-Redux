"use strict";

var util = GameUI.CustomUIConfig().Util;

var messages = [];

function toggleChangelog(arg){
	$("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"))

	if (arg) { //shortcut to open panel and select specific tab
		arg();
	}
}

function displayChangelog(){
	$("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"))
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

	$("#changelogNotification").visible = messageCount > 0;

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
	var flagsPath = 'file://{images}/custom_game/flags/';
	
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

						    MarkMessageAsRead( msg.ID )
						});
					}
				})( messages[message], steamID32);
			}

			userPic.FindChildTraverse("avatar").steamid = steamID64;
			
			userPic.FindChildTraverse("userPicDescription").text = $.Localize(steamID64.toString()+ "_Description");

			userPic.FindChildTraverse("userPicName").github = GameUI.CustomUIConfig().premiumData[contributor]["github"];
			userPic.FindChildTraverse("userPicFlag").SetImage(flagsPath + GameUI.CustomUIConfig().premiumData[contributor]["country"] + '.png' );

			userPic.FindChildTraverse("userPicName").text = $.Localize(steamID64.toString());
			userPic.FindChildTraverse("userPicName").SetPanelEvent('onactivate', function(){
				$.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), "https://github.com/"+userPic.FindChildTraverse("userPicName").github);
			});
		})();
	}
}

function sendMessage() {
	var text = $( "#submitInput" ).text;
	$.Schedule(6.0, function () {
		$.DispatchEvent( 'UIHideCustomLayoutTooltip', $("#submitButton"), "SendTooltip");
	})
	if (text.length < 6) {
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', $("#submitButton"), "SendTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize("lodMessageLengthTooltip"));
		return;
	}
	
	var playerID = Players.GetLocalPlayer();
	var info =  Game.GetPlayerInfo(Players.GetLocalPlayer());

    $.Schedule(6.0, function () {
		$("#submitButton").text = $.Localize("lodMessageSubmit");
		$("#submitButton").RemoveClass("Sent");
	})

    $("#submitButton").text = $.Localize("lodMessageSent");
    $("#submitButton").AddClass("Sent");
    $( "#submitInput" ).text = "";
    $("#submitButton").SetFocus();
    // $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', $("#submitButton"), "SendTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize("lodMessageButtonTooltip"));
    Game.EmitSound( "compendium_levelup" );

    SendMessage( text )
}

function newMessages( newMessages ) {
	messages = newMessages;

	setMessagesNumber();
	setupCredits();
}

(function() {
	$("#descriptionDisplay").visible = true;
	$("#showDescriptionButton").checked = true;
	$("#changelogNotification").visible = false;
	
	util.blockMouseWheel($("#changelogDisplay"));
	util.blockMouseWheel($("#changelogNotification"));

	GameEvents.Subscribe( "lodOnChangelog", displayChangelog );
	GameEvents.Subscribe( "su_new_messages", newMessages );
})();