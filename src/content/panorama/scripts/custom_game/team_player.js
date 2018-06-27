"use strict";
var util = GameUI.CustomUIConfig().Util;

// Stub
//var setSelectedDropAbility = function(){};
//var setSelectedHelperHero = function(){};
//var makeSkillSelectable = function(){};

// The current hero we hold
//var currentSelectedHero = '';

// When player details are changed
function OnPlayerDetailsChanged() {
    var playerID = $.GetContextPanel().GetAttributeInt('playerID', -1);
    var playerInfo = Game.GetPlayerInfo(playerID);
    if (!playerInfo) return;

    if(playerInfo.player_connection_state == 1) {
    	// Bot player
    	$("#playerAvatar").steamid = 76561197988355984;
    } else {
    	// Set Avatar
    	$("#playerAvatar").steamid = playerInfo.player_steamid;
    }

    // Is it a contributor?
    var playerName = playerInfo.player_name;
    if(isContributor(playerInfo.player_steamid)) {
        $("#playerName").AddClass('contributor');
    } else {
        $("#playerName").RemoveClass('contributor');
    }
    $("#playerName").SetPanelEvent('onactivate', function() {
		var playerID = $.GetContextPanel().GetAttributeInt('playerID', -1);
		var playerInfo = Game.GetPlayerInfo(playerID);
		if (!playerInfo || playerInfo.player_connection_state == 1 || Players.GetLocalPlayer() === playerID || GameUI.CustomUIConfig().hostID != Players.GetLocalPlayer()) return;
		GameEvents.SendCustomGameEventToServer('lodChangeHost', {
			oldHost: Players.GetLocalPlayer(),
			newHost: playerID,
			popup: true});
	});

    // Set Name
    $("#playerName").text = playerName;
    $("#playerName").SetAttributeInt('playerID', playerID);

    $.GetContextPanel().SetHasClass("player_is_local", playerInfo.player_is_local);
    $.GetContextPanel().SetHasClass("player_has_host_privileges", GameUI.CustomUIConfig().hostID === playerID);
}

function OnHostChanged(data) {
    GameUI.CustomUIConfig().hostID = data.newHost;
    OnPlayerDetailsChanged();
}

function isContributor(steamID) {
    var premiumData = GameUI.CustomUIConfig().premiumData;
    for (var i in premiumData){
        if (steamID === premiumData[i].steamID64){
            return true;
        }
    }
    var patrons = GameUI.CustomUIConfig().patrons;
    for (var i in patrons){
        if (steamID === patrons[i].steamID64){
            return true;
        }
    }
    return false;
}

// When we get hero data
function OnGetHeroData(heroName) {
	// Show the actual hero icon
	var mainPanel = $.GetContextPanel();
	mainPanel.SetHasClass('no_hero_selected', false);

	// Put the hero image in place
	var heroCon = $('#playerHeroImage');
	heroCon.heroname = heroName;
	heroCon.SetAttributeString('heroName', heroName);
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
		} else {
			con.abilityname = 'life_stealer_empty_1';
			con.SetAttributeString('abilityname', 'life_stealer_empty_1');
		}

		GameUI.CustomUIConfig().hookSkillInfo(con);
	}
}

// Hooks the abilities to show what they are
function hookStuff(hookSkillInfo, makeSkillSelectable, makeHeroSelectable) {
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

	// Make the hero selectable
	makeHeroSelectable($('#playerHeroImage'));

	// Store ability
	//setSelectedHelperHero = setSelectedHelperHeroReplace;
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

/*function onPlayerHeroClicked() {
	// Set the selected hero
	setSelectedHelperHero(currentSelectedHero);
}*/

function setReadyState(newState) {
    $.GetContextPanel().SetHasClass("lodPlayerIsReady", newState == 1);
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
    mainPanel.setReadyState = setReadyState;
        GameEvents.Subscribe('lodOnHostChanged', function(data) {
        OnHostChanged(data);
    });
})();
