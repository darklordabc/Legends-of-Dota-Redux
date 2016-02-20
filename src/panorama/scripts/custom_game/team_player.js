"use strict";

// Stub
//var setSelectedDropAbility = function(){};
var setSelectedHelperHero = function(){};
var makeSkillSelectable = function(){};

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
function hookStuff(hookSkillInfo, makeSkillSelectable, setSelectedHelperHeroReplace) {
	// Hook it up
	for(var i=1; i<=6; ++i) {
		(function(con) {
			hookSkillInfo(con);
			con.SetAttributeString('abilityname', '');
			//con.SetPanelEvent('onactivate', function() {
	        //    setSelectedDropAbility(con.GetAttributeString('abilityname'), con);
	        //});

			makeSkillSelectable(con);
		})($('#playerSkill' + i));
	}

	// Store ability
	setSelectedHelperHero = setSelectedHelperHeroReplace;
}

function OnGetNewAttribute(newAttr) {
	var attr = 'file://{images}/primary_attribute_icons/primary_attribute_icon_strength.psd';
	if(newAttr == 'agi') {
		attr = 'file://{images}/primary_attribute_icons/primary_attribute_icon_agility.psd';
	} else if(newAttr == 'int') {
		attr = 'file://{images}/primary_attribute_icons/primary_attribute_icon_intelligence.psd';
	}

	// Grab con
	var con = $('#playerAttribute');

	// Set it
	con.SetImage(attr);

	// Show it 
	con.SetHasClass('doNotShow', false);
}

function onPlayerAbilityClicked(slotID) {
	//var con = $('#playerSkill' + slotID);
	//setSelectedDropAbility(con.GetAttributeString('abilityname', ''), con);
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
    mainPanel.OnGetNewAttribute = OnGetNewAttribute;
    mainPanel.hookStuff = hookStuff;
})();
