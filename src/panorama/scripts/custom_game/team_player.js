"use strict";

// Stub
var setSelectedDropAbility = function(){};
var setSelectedHelperHero = function(){};

// The current hero we hold
var currentSelectedHero = '';

// When player details are changed
function OnPlayerDetailsChanged() {
    var playerID = $.GetContextPanel().GetAttributeInt('playerID', -1);
    var playerInfo = Game.GetPlayerInfo(playerID);
    if (!playerInfo) return;

    $("#playerName").text = playerInfo.player_name;
    $("#playerAvatar").steamid = playerInfo.player_steamid;

    $.GetContextPanel().SetHasClass("player_is_local", playerInfo.player_is_local);
    $.GetContextPanel().SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
}

// When we get hero data
function OnGetHeroData(heroName) {
	// Show the actual hero icon
	var mainPanel = $.GetContextPanel();
	mainPanel.SetHasClass('no_hero_selected', false);

	// Put the hero image in place
	$('#playerHeroImage').heroname = heroName;
	currentSelectedHero = heroName;
}

// When we get the slot count
function OnGetHeroSlotCount(maxSlots) {
	$('#playerSkill1').visible = maxSlots >= 1;
	$('#playerSkill2').visible = maxSlots >= 2;
	$('#playerSkill3').visible = maxSlots >= 3;
	$('#playerSkill4').visible = maxSlots >= 4;
	$('#playerSkill5').visible = maxSlots >= 5;
	$('#playerSkill6').visible = maxSlots >= 6;
}

// When we get build data
function OnGetHeroBuildData(build) {
	for(var i=1; i<=6; ++i) {
		var con = $('#playerSkill' + i);

		if(build[i]) {
			con.abilityname = build[i];
			con.SetAttributeString('abilityname', build[i]);
		}
	}
}

// Hooks the abilities to show what they are
function hookStuff(hookSkillInfo, setSelectedDropAbilityReplace, setSelectedHelperHeroReplace) {
	// Hook it up
	for(var i=1; i<=6; ++i) {
		(function(con) {
			hookSkillInfo(con);
			con.SetAttributeString('abilityname', '');
			//con.SetPanelEvent('onactivate', function() {
	        //    setSelectedDropAbility(con.GetAttributeString('abilityname'), con);
	        //});
		})($('#playerSkill' + i));
	}

	// Store ability
	setSelectedDropAbility = setSelectedDropAbilityReplace;
	setSelectedHelperHero = setSelectedHelperHeroReplace;
}

function onPlayerAbilityClicked(slotID) {
	var con = $('#playerSkill' + slotID);
	setSelectedDropAbility(con.GetAttributeString('abilityname', ''), con);
}

function onPlayerHeroClicked() {
	// Set the selected hero
	setSelectedHelperHero(currentSelectedHero);
}

// When this panel loads
(function()
{
	// Grab the main panel
	var mainPanel = $.GetContextPanel();

    OnPlayerDetailsChanged();
    $.RegisterForUnhandledEvent('DOTAGame_PlayerDetailsChanged', OnPlayerDetailsChanged);

    // Add the events
    mainPanel.OnGetHeroData = OnGetHeroData;
    mainPanel.OnGetHeroSlotCount = OnGetHeroSlotCount;
    mainPanel.OnGetHeroBuildData = OnGetHeroBuildData;
    mainPanel.hookStuff = hookStuff;
})();
