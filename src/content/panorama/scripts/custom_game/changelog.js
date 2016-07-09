"use strict";

function toggleChangelog(arg){
	$("#changelogDisplay").visible = !($("#changelogDisplay").visible)	
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false	
	$("#creditsDisplay").visible = false
	$("#OptionTextDescription").AddClass("displaySelected");
	$("#OptionTextUpdates").RemoveClass("displaySelected");
	$("#OptionTextCredits").RemoveClass("displaySelected");
}

function toggleDescription(arg){
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
	$("#OptionTextDescription").AddClass("displaySelected");
	$("#OptionTextUpdates").RemoveClass("displaySelected");
	$("#OptionTextCredits").RemoveClass("displaySelected");
}

function toggleUpdates(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = true
	$("#creditsDisplay").visible = false
	$("#OptionTextDescription").RemoveClass("displaySelected");
	$("#OptionTextUpdates").AddClass("displaySelected");
	$("#OptionTextCredits").RemoveClass("displaySelected");

}

function toggleCredits(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = true
	$("#OptionTextDescription").RemoveClass("displaySelected");
	$("#OptionTextUpdates").RemoveClass("displaySelected");
	$("#OptionTextCredits").AddClass("displaySelected");

}

