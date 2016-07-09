"use strict";

function toggleChangelog(arg){
	$("#changelogDisplay").visible = !($("#changelogDisplay").visible)
	
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
}

function toggleDescription(arg){
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
}

function toggleUpdates(arg){
	$("#descriptionDisplay").visible = false

	$("#updateDisplay").visible = true

	$("#creditsDisplay").visible = false

}

function toggleCredits(arg){
	$("#descriptionDisplay").visible = false

	$("#updateDisplay").visible = false

	$("#creditsDisplay").visible = true

}

