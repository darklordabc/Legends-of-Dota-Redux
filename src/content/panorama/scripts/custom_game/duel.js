"use strict";

function UpdateDuelText(data)
{
	$( "#Block").visible = true;
	var temp_text = ""
	temp_text+=data.string
	$( "#DuelTextBlock").text = $.Localize(temp_text) + " " + data.time_string
	$( "#DuelTextBlock").style.color = data.color
}

function HideDuelText() {
	$( "#Block").visible = false;
	$( "#DuelTextBlock").text = "";
}

function Attension_update(data)
{
	$( "#Attension").visible = true
	var temp_text = "";
	temp_text+=data.string;
	$( "#Attension").text = $.Localize(temp_text)
}
function Attension_close()
{
	$( "#Attension").visible = false
}

function SetKillLimit( data)
{
	var temp_text = $.Localize("#pn_kill_limit") + " " + data.string
	$("#KillLimit_text").text = temp_text
	$("#KillLimit_text").text = temp_text
}


(function()
{
    //GameEvents.Subscribe( "countdown", UpdateTimer );
	GameEvents.Subscribe( "duel_text_hide", HideDuelText)
	GameEvents.Subscribe( "duel_text_update", UpdateDuelText)
	GameEvents.Subscribe( "attension_text", Attension_update)
	GameEvents.Subscribe( "attension_close", Attension_close)
	//GameEvents.Subscribe( "SetKillLimit", SetKillLimit )

	HideDuelText();
})();

