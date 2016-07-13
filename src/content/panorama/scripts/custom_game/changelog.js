"use strict";

// TODO: Back-end
var messages = [];
messages[0] = {"steamid" : 76561198054179075, "message" : "Testing messages"}
messages[1] = {"steamid" : 76561198054179075, "message" : "Testing messages x2"}
messages[2] = {"steamid" : 76561198001376044, "message" : "Testing messages x3"}

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
	var messageCount = messages.length;

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
      
	for (var steamID3 in GameUI.CustomUIConfig().premiumData) {
		(function () {
			var userPic = $.CreatePanel("Panel", panel, steamID3);
			userPic.BLoadLayoutSnippet("userPic");

			var steamID64 = GameUI.CustomUIConfig().premiumData[steamID3]["steamID64"]

			for (var message in messages) {
				(function () {
					var messageTable = messages[message];

					if (messageTable.steamid == steamID64) {
						var devMessagePanel = $.CreatePanel("Panel", userPic.FindChildTraverse("userPicMessages"), "devMessage_"+steamID64);
						devMessagePanel.BLoadLayoutSnippet("devMessage");
						devMessagePanel.FindChildTraverse("devMessageLabel").text = "!";

						devMessagePanel.SetPanelEvent('onactivate', function(){
							var messageText = messageTable.message;
							Game.EmitSound( "ui.click_alt" );

							decrementLabelNumber($("#changelogNotificationLabel"))
							devMessagePanel.visible = false;

							$.DispatchEvent( "UIShowCustomLayoutPopupParameters", "CustomPopupTest", "file://{resources}/layout/custom_game/dev_message.xml", "popupvalue="+messageText);
						});
					}
				})();
			}

			userPic.FindChildTraverse("avatar").steamid = steamID64;
			
			userPic.FindChildTraverse("userPicDescription").text = $.Localize(steamID3.toString()+ "_Description");

			userPic.FindChildTraverse("userPicName").github = GameUI.CustomUIConfig().premiumData[steamID3]["github"];

			userPic.FindChildTraverse("userPicName").text = $.Localize(steamID3.toString()) + " (github)";
			userPic.FindChildTraverse("userPicName").SetPanelEvent('onactivate', function(){
				$.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), "https://github.com/"+userPic.FindChildTraverse("userPicName").github);
			});
		})();
	}
}

(function() {
	setMessagesNumber()
	setupCredits()

	$("#descriptionDisplay").visible = true
	$("#showDescriptionButton").checked = true;
})();
