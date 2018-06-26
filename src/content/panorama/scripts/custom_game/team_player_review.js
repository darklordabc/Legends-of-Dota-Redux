"use strict";

// Stub
//var setSelectedDropAbility = function(){};
var setSelectedHelperHero = function(){};
var makeSkillSelectable = function(){};

// Should we make everything small?
var shouldMakeSmall = false;

// The hero that we are
var ourHeroName = null;

// Have we already loaded our hero model?
var loadedHeroModel = false;

// When player details are changed
function OnPlayerDetailsChanged() {
    var playerID = $.GetContextPanel().GetAttributeInt('playerID', -1);
    var playerInfo = Game.GetPlayerInfo(playerID);
    if (!playerInfo) return;

    if(playerInfo.player_connection_state == 1) {
        // Bot player
        $("#reviewPhasePlayerAvatar").steamid = 76561197988355984;
        $("#reviewPhasePlayerAvatarBig").steamid = 76561197988355984;
    } else {
        $("#reviewPhasePlayerAvatar").steamid = playerInfo.player_steamid;
        $("#reviewPhasePlayerAvatarBig").steamid = playerInfo.player_steamid;
    }

    // Is it a contributor?
    var playerName = playerInfo.player_name;
    if(isContributor(playerInfo.player_steamid)) {
        $("#playerName").AddClass('contributor');
    } else {
        $("#playerName").RemoveClass('contributor');
    }

    // Set Name
    $("#playerName").text = playerName;

    $.GetContextPanel().SetHasClass("player_is_local", playerInfo.player_is_local);
    $.GetContextPanel().SetHasClass("player_has_host_privileges", GameUI.CustomUIConfig().hostID === playerID);
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
    // Store our hero name
    ourHeroName = heroName;
}

// When review phase starts
function OnReviewPhaseStart() {
    if(ourHeroName != null && !loadedHeroModel) {
        // We have now loaded our hero icon
        loadedHeroModel = true;

        // Show the actual hero icon
        var mainPanel = $.GetContextPanel();
        mainPanel.SetHasClass('no_hero_selected', false);

        // Put the hero image in place
        var con = $('#reviewPhaseHeroImageContainer');

        if ($.GetContextPanel().preloadedHeroPanels != undefined) {
            if ($.GetContextPanel().preloadedHeroPanels[ourHeroName] && $.GetContextPanel().preloadedHeroPanels[ourHeroName].GetParent() != con) {
                $.GetContextPanel().preloadedHeroPanels[ourHeroName].visible = true;
                $.GetContextPanel().preloadedHeroPanels[ourHeroName].SetParent(con);
            } else {
                var heroImage = $.CreatePanel('Panel', con, 'reviewPhaseHeroImageLoader');

                heroImage.BLoadLayoutFromString('<root><Panel><DOTAScenePanel particleonly="false" style="width: 300px; height: 800px; opacity-mask: url(\'s2r://panorama/images/masks/softedge_box_png.vtex\');" unit="' + ourHeroName + '"/></Panel></root>', false, false);
                heroImage.AddClass("avatarScene");
            }
        }
    }
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

        GameUI.CustomUIConfig().hookSkillInfo(con);
	}
}

// Do the highlight
var selectedSlotID = -1;
function doSlotHighlight() {
	for(var i=1; i<=6; ++i) {
		var slot = $('#playerSkill' + i);

		if(selectedSlotID == -1) {
			slot.SetHasClass('lodSelectedDrop', false);
			slot.SetHasClass('lodSelected', false);
		} else {
			slot.SetHasClass('lodSelectedDrop', selectedSlotID != i);
			slot.SetHasClass('lodSelected', selectedSlotID == i);
		}
	}
}

// Implement slot swapping
function makeSwapable(slotID, abcon) {
	abcon.SetPanelEvent('onactivate', function() {
        if(selectedSlotID == -1) {
        	selectedSlotID = slotID;
        } else {
        	if(selectedSlotID != slotID) {
        		// Do the swap slot
        		swapSlots(selectedSlotID, slotID);
        	}

        	// None selected anymore
        	selectedSlotID = -1;
        }

        doSlotHighlight();
    });

    // Dragging
    abcon.SetDraggable(true);

    $.RegisterEventHandler('DragEnter', abcon, function(panelID, draggedPanel) {
        abcon.AddClass('potential_drop_target');
        selectedSlotID = slotID;
    });

    $.RegisterEventHandler('DragLeave', abcon, function(panelID, draggedPanel) {
        $.Schedule(0.1, function() {
            abcon.RemoveClass('potential_drop_target');

            if(draggedPanel.deleted == null && selectedSlotID == slotID) {
                selectedSlotID = -1
            }
        });
    });

    $.RegisterEventHandler('DragStart', abcon, function(panelID, dragCallbacks) {
        var abName = abcon.GetAttributeString('abilityname', '');
        if(abName == null || abName.length <= 0) return false;

        // Create a temp image to drag around
        var displayPanel = $.CreatePanel('DOTAAbilityImage', $.GetContextPanel(), 'dragImage');
        displayPanel.abilityname = abName;
        dragCallbacks.displayPanel = displayPanel;
        dragCallbacks.offsetX = 0;
        dragCallbacks.offsetY = 0;
        displayPanel.SetAttributeString('abilityname', abName);

        // Hide skill info
        $.DispatchEvent('DOTAHideAbilityTooltip');

        selectedSlotID = slotID;
        doSlotHighlight();
    });

    $.RegisterEventHandler('DragEnd', abcon, function(panelId, draggedPanel) {
        // Delete the draggable panel
        draggedPanel.deleted = true;
        draggedPanel.DeleteAsync(0.0);

        if(selectedSlotID != -1) {
        	if(selectedSlotID != slotID) {
        		// Do the swap slot
        		swapSlots(selectedSlotID, slotID);
        	}

        	// None selected anymore
        	selectedSlotID = -1;
        }

        doSlotHighlight();
    });
}

// Swaps two slots
function swapSlots(slot1, slot2) {
    // Push it to the server to validate
    GameEvents.SendCustomGameEventToServer('lodSwapSlots', {
        slot1: slot1,
        slot2: slot2
    });
}

// Hooks the abilities to show what they are
function hookStuff(hookSkillInfo, makeSkillSelectable, setSelectedHelperHeroReplace, canSwap) {
	// Hook it up
	for(var i=1; i<=6; ++i) {
		(function(con) {
			hookSkillInfo(con);
			con.SetAttributeString('abilityname', '');
			//con.SetPanelEvent('onactivate', function() {
	        //    setSelectedDropAbility(con.GetAttributeString('abilityname'), con);
	        //});

			if(canSwap) {
				// Make it swapable
				makeSwapable(i, con);
			}

			//makeSkillSelectable(con);
		})($('#playerSkill' + i));
	}

	// Store ability
	setSelectedHelperHero = setSelectedHelperHeroReplace;
}

function setShouldBeSmall(shouldMakeSmallTemp) {
    // Store the temp
    shouldMakeSmall = shouldMakeSmallTemp;

    // Add the class
    $.GetContextPanel().SetHasClass('tooManyPlayers', shouldMakeSmall);
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
    mainPanel.OnReviewPhaseStart = OnReviewPhaseStart;
    mainPanel.setShouldBeSmall = setShouldBeSmall;
})();
