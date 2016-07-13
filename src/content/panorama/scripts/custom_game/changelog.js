"use strict";

function toggleChangelog(arg){
	$("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"))
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false	
	$("#creditsDisplay").visible = false
	// $("#OptionTextDescription").AddClass("displaySelected");
	// $("#OptionTextUpdates").RemoveClass("displaySelected");
	// $("#OptionTextCredits").RemoveClass("displaySelected");
}

function toggleDescription(arg){
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
	// $("#OptionTextDescription").AddClass("displaySelected");
	// $("#OptionTextUpdates").RemoveClass("displaySelected");
	// $("#OptionTextCredits").RemoveClass("displaySelected");
}

function toggleUpdates(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = true
	$("#creditsDisplay").visible = false
	// $("#OptionTextDescription").RemoveClass("displaySelected");
	// $("#OptionTextUpdates").AddClass("displaySelected");
	// $("#OptionTextCredits").RemoveClass("displaySelected");

}

function toggleCredits(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = true
	// $("#OptionTextDescription").RemoveClass("displaySelected");
	// $("#OptionTextUpdates").RemoveClass("displaySelected");
	// $("#OptionTextCredits").AddClass("displaySelected");

}

(function() {
	var panel = $("#creditsPanel");
      
	for (var steamID3 in GameUI.CustomUIConfig().premiumData) {
		(function () {
			var userPic = $.CreatePanel("Panel", panel, steamID3);
			userPic.BLoadLayoutSnippet("userPic");

			userPic.FindChildTraverse("avatar").steamid = GameUI.CustomUIConfig().premiumData[steamID3]["steamID64"];

			userPic.FindChildTraverse("userPicName").text = $.Localize(steamID3.toString());
			userPic.FindChildTraverse("userPicDescription").text = $.Localize(steamID3.toString()+ "_Description");
		})();
	}

	$("#showDescriptionButton").checked = true;
})();
