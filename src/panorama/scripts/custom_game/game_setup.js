"use strict";

// All options JSON (todo: EXPORT IT)
var allOptions = {
    // Presets, to make selection FAST
    presets: {
        default: true,
        fields: [
            {
                name: 'lodOptionGamemode',
                des: 'lodOptionsPresetGamemode',
                about: 'lodOptionAboutPresetGamemode',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBalancedAllPick',
                        value: 1
                    },
                    {
                        text: 'lodOptionBalancedSingleDraft',
                        value: 2
                    },
                    {
                        text: 'lodOptionBalancedMirrorDraft',
                        value: 3
                    },
                    {
                        text: 'lodOptionBalancedAllRandom',
                        value: 4
                    },
                    {
                        text: 'lodOptionBalancedCustom',
                        value: -1
                    }
                ]
            },
            {
                preset: true,
                name: 'lodOptionBanning',
                des: 'lodOptionsPresetBanning',
                about: 'lodOptionAboutPresetBanning',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBalancedBan',
                        value: 1
                    },
                    {
                        text: 'lodOptionManualBan',
                        value: 2
                    }
                ]
            },
            {
                preset: true,
                name: 'lodOptionSlots',
                des: 'lodOptionsPresetSlots',
                about: 'lodOptionAboutPresetSlots',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBalancedSlots4',
                        value: 4
                    },
                    {
                        text: 'lodOptionBalancedSlots5',
                        value: 5
                    },
                    {
                        text: 'lodOptionBalancedSlots6',
                        value: 6
                    }
                ]
            },
            {
                preset: true,
                name: 'lodOptionUlts',
                des: 'lodOptionsPresetUlts',
                about: 'lodOptionAboutPresetUlts',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBalancedUlts1',
                        value: 1
                    },
                    {
                        text: 'lodOptionBalancedUlts2',
                        value: 2
                    },
                    {
                        text: 'lodOptionBalancedUlts3',
                        value: 3
                    },
                    {
                        text: 'lodOptionBalancedUlts4',
                        value: 4
                    },
                    {
                        text: 'lodOptionBalancedUlts5',
                        value: 5
                    },
                    {
                        text: 'lodOptionBalancedUlts6',
                        value: 6
                    },
                    {
                        text: 'lodOptionBalancedUlts0',
                        value: 0
                    },
                ]
            }
        ]
    },

    // The common stuff people play with
    common_selection: {
        custom: true,
        fields: [
            {
                name: 'lodOptionCommonGamemode',
                des: 'lodOptionDesCommonGamemode',
                about: 'lodOptionAboutCommonGamemode',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionAllPick',
                        value: 1
                    },
                    {
                        text: 'lodOptionSingleDraft',
                        value: 2
                    },
                    {
                        text: 'lodOptionMirrorDraft',
                        value: 3
                    },
                    /*{
                        text: 'lodOptionAllRandom',
                        value: 4
                    }*/
                ]
            },
            {
                name: 'lodOptionCommonMaxSlots',
                des: 'lodOptionDesCommonMaxSlots',
                about: 'lodOptionAboutCommonMaxSlots',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionCommonSlots4',
                        value: 4
                    },
                    {
                        text: 'lodOptionCommonSlots5',
                        value: 5
                    },
                    {
                        text: 'lodOptionCommonSlots6',
                        value: 6
                    }
                ]
            },
            {
                name: 'lodOptionCommonMaxSkills',
                des: 'lodOptionDesCommonMaxSkills',
                about: 'lodOptionAboutCommonMaxSkills',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionCommonSkills12',
                        value: 12
                    },
                    {
                        text: 'lodOptionCommonSkills0',
                        value: 0
                    },
                    {
                        text: 'lodOptionCommonSkills1',
                        value: 1
                    },
                    {
                        text: 'lodOptionCommonSkills2',
                        value: 2
                    },
                    {
                        text: 'lodOptionCommonSkills3',
                        value: 3
                    },
                    {
                        text: 'lodOptionCommonSkills4',
                        value: 4
                    },
                    {
                        text: 'lodOptionCommonSkills5',
                        value: 5
                    },
                    {
                        text: 'lodOptionCommonSkills6',
                        value: 6
                    },
                    {
                        text: 'lodOptionCommonSkills7',
                        value: 7
                    },
                    {
                        text: 'lodOptionCommonSkills8',
                        value: 8
                    },
                    {
                        text: 'lodOptionCommonSkills9',
                        value: 9
                    },
                    {
                        text: 'lodOptionCommonSkills10',
                        value: 10
                    },
                    {
                        text: 'lodOptionCommonSkills11',
                        value: 11
                    },
                    {
                        text: 'lodOptionCommonSkills12',
                        value: 12
                    }
                ]
            },
            {
                name: 'lodOptionCommonMaxUlts',
                des: 'lodOptionDesCommonMaxUlts',
                about: 'lodOptionAboutCommonMaxUlts',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionCommonUlts12',
                        value: 12
                    },
                    {
                        text: 'lodOptionCommonUlts0',
                        value: 0
                    },
                    {
                        text: 'lodOptionCommonUlts1',
                        value: 1
                    },
                    {
                        text: 'lodOptionCommonUlts2',
                        value: 2
                    },
                    {
                        text: 'lodOptionCommonUlts3',
                        value: 3
                    },
                    {
                        text: 'lodOptionCommonUlts4',
                        value: 4
                    },
                    {
                        text: 'lodOptionCommonUlts5',
                        value: 5
                    },
                    {
                        text: 'lodOptionCommonUlts6',
                        value: 6
                    },
                    {
                        text: 'lodOptionCommonUlts7',
                        value: 7
                    },
                    {
                        text: 'lodOptionCommonUlts8',
                        value: 8
                    },
                    {
                        text: 'lodOptionCommonUlts9',
                        value: 9
                    },
                    {
                        text: 'lodOptionCommonUlts10',
                        value: 10
                    },
                    {
                        text: 'lodOptionCommonUlts11',
                        value: 11
                    },
                    {
                        text: 'lodOptionCommonUlts12',
                        value: 12
                    }
                ]
            },
        ]
    },

    // Changing what stuff is banned
    banning: {
        custom: true,
        fields: [
            {
                name: 'lodOptionBanningMaxBans',
                des: 'lodOptionDesBanningMaxBans',
                about: 'lodOptionAboutBanningMaxBans',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBanningMaxBans0',
                        value: 0
                    },
                    {
                        text: 'lodOptionBanningMaxBans1',
                        value: 1
                    },
                    {
                        text: 'lodOptionBanningMaxBans2',
                        value: 2
                    },
                    {
                        text: 'lodOptionBanningMaxBans3',
                        value: 3
                    },
                    {
                        text: 'lodOptionBanningMaxBans5',
                        value: 5
                    },
                    {
                        text: 'lodOptionBanningMaxBans10',
                        value: 10
                    },
                    {
                        text: 'lodOptionBanningMaxBans25',
                        value: 25
                    }
                ]
            },
            {
                name: 'lodOptionBanningBlockTrollCombos',
                des: 'lodOptionDesBanningBlockTrollCombos',
                about: 'lodOptionAboutBanningBlockTrollCombos',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionYes',
                        value: 1
                    },
                    {
                        text: 'lodOptionNo',
                        value: 0
                    }
                ]
            },
            {
                name: 'lodOptionBanningUseBanList',
                des: 'lodOptionDesBanningUseBanList',
                about: 'lodOptionAboutBanningUseBanList',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionYes',
                        value: 1
                    },
                    {
                        text: 'lodOptionNo',
                        value: 0
                    }
                ]
            },
            {
                name: 'lodOptionBanningBanInvis',
                des: 'lodOptionDesBanningBanInvis',
                about: 'lodOptionAboutBanningBanInvis',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionYes',
                        value: 1
                    },
                    {
                        text: 'lodOptionNo',
                        value: 0
                    }
                ]
            },
        ]
    },

    // Changing the speed of the match
    game_speed: {
        custom: true,
        fields: [
            {
                name: 'lodOptionGameSpeedStartingLevel',
                des: 'lodOptionDesGameSpeedStartingLevel',
                about: 'lodOptionAboutGameSpeedStartingLevel',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionLevel1',
                        value: 1
                    },
                    {
                        text: 'lodOptionLevel6',
                        value: 6
                    },
                    {
                        text: 'lodOptionLevel11',
                        value: 11
                    },
                    {
                        text: 'lodOptionLevel16',
                        value: 16
                    },
                    {
                        text: 'lodOptionLevel25',
                        value: 25
                    },
                    {
                        text: 'lodOptionLevel50',
                        value: 50
                    },
                    {
                        text: 'lodOptionLevel75',
                        value: 75
                    },
                    {
                        text: 'lodOptionLevel100',
                        value: 100
                    }
                ]
            },
            {
                name: 'lodOptionGameSpeedMaxLevel',
                des: 'lodOptionDesGameSpeedMaxLevel',
                about: 'lodOptionAboutGameSpeedMaxLevel',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionLevel25',
                        value: 25
                    },
                    {
                        text: 'lodOptionLevel6',
                        value: 6
                    },
                    {
                        text: 'lodOptionLevel11',
                        value: 11
                    },
                    {
                        text: 'lodOptionLevel16',
                        value: 16
                    },
                    {
                        text: 'lodOptionLevel25',
                        value: 25
                    },
                    {
                        text: 'lodOptionLevel50',
                        value: 50
                    },
                    {
                        text: 'lodOptionLevel75',
                        value: 75
                    },
                    {
                        text: 'lodOptionLevel100',
                        value: 100
                    }
                ]
            },
            {
                name: 'lodOptionGameSpeedStartingGold',
                des: 'lodOptionDesGameSpeedStartingGold',
                about: 'lodOptionAboutGameSpeedStartingGold',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionGameSpeedStartingGold0',
                        value: 0
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold250',
                        value: 250
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold500',
                        value: 500
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold1000',
                        value: 1000
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold2500',
                        value: 2500
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold5000',
                        value: 5000
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold10000',
                        value: 10000
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold25000',
                        value: 25000
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold50000',
                        value: 50000
                    },
                    {
                        text: 'lodOptionGameSpeedStartingGold100000',
                        value: 100000
                    },
                ]
            },
        ]
    },

    // Advanced stuff, for pros
    advanced_selection: {
        custom: true,
        fields: [

        ]
    },

    // Buffing of heroes, towers, etc
    buffs: {
        custom: true,
        fields: [

        ]
    },

    // Stuff that is just crazy
    crazyness: {
        custom: true,
        fields: [

        ]
    }
}

// Phases
var PHASE_LOADING = 1;          // Waiting for players, etc
var PHASE_OPTION_SELECTION = 2; // Selection options
var PHASE_BANNING = 3;          // Banning stuff
var PHASE_SELECTION = 4;        // Selecting heroes
var PHASE_DRAFTING = 5;         // Place holder for drafting mode
var PHASE_REVIEW = 6;           // Review Phase
var PHASE_INGAME = 7;           // Game has started

// The current phase we are in
var currentPhase = PHASE_LOADING;
var selectedPhase = PHASE_OPTION_SELECTION;
var endOfTimer = -1;
var allowCustomSettings = false;

// List of all player team panels
var allPlayerPanels = [];

// List of option links
var allOptionLinks = {};

// Prevent double option sending
var lastOptionValues = {};

// Map of optionName -> callback for value change
var optionFieldMap = {};

// Hooks an events and fires for all the keys
function hookAndFire(tableName, callback) {
    // Listen for phase changing information
    CustomNetTables.SubscribeNetTableListener(tableName, callback);

    // Grab the data
    var data = CustomNetTables.GetAllTableValues(tableName);
    for(var i=0; i<data.length; ++i) {
        var info = data[i];
        callback(tableName, info.key, info.value);
    }
}

// Are we the host?
function isHost() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return false;
    return playerInfo.player_has_host_privileges;
}

// Sets an option to a value
function setOption(optionName, optionValue) {
    // Ensure we are the host
    if(!isHost()) return;

    // Don't send an update twice!
    if(lastOptionValues[optionName] && lastOptionValues[optionName] == optionValue) return;

    // Tell the server we changed a setting
    GameEvents.SendCustomGameEventToServer('lodOptionSet', {k:optionName, v: optionValue});
}

// Adds a player to the list of unassigned players
function addUnassignedPlayer(playerID) {
    // Grab the panel to insert into
    var unassignedPlayersContainerNode = $('#unassignedPlayersContainer');
    if (unassignedPlayersContainerNode == null) return;

    // Create the new panel
    var newPlayerPanel = $.CreatePanel('Panel', unassignedPlayersContainerNode, 'unassignedPlayer');
    newPlayerPanel.SetAttributeInt('playerID', playerID);
    newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/unasignedPlayer.xml', false, false);

    // Add this panel to the list of panels we've generated
    allPlayerPanels.push(newPlayerPanel);
}

// Adds a player to a team
function addPlayerToTeam(playerID, panel) {
    // Validate the panel
    if(panel == null) return;

    // Create the new panel
    var newPlayerPanel = $.CreatePanel('Panel', panel, 'teamPlayer');
    newPlayerPanel.SetAttributeInt('playerID', playerID);
    newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/teamPlayer.xml', false, false);

    // Add this panel to the list of panels we've generated
    allPlayerPanels.push(newPlayerPanel);
}

// Build the options categories
function buildOptionsCategories() {
    // Grab the main container for option categories
    var catContainer = $('#optionCategories');
    var optionContainer = $('#optionList');

    // Delete any children
    catContainer.RemoveAndDeleteChildren();
    optionContainer.RemoveAndDeleteChildren();

    // Reset option links
    allOptionLinks = {};

    // Loop over all the option labels
    for(var optionLabelText in allOptions) {
        // Create a new scope
        (function(optionLabelText, optionData) {
            // The button
            var optionCategory = $.CreatePanel('Button', catContainer, 'option_button_' + optionLabelText);
            optionCategory.SetAttributeString('cat', optionLabelText);
            //optionCategory.AddClass('PlayButton');
            //optionCategory.AddClass('RadioBox');
            //optionCategory.AddClass('HeroGridNavigationButtonBox');
            //optionCategory.AddClass('NavigationButtonGlow');
            optionCategory.AddClass('OptionButton');

            var innerPanel = $.CreatePanel('Panel', optionCategory, 'option_button_' + optionLabelText + '_fancy');
            innerPanel.AddClass('OptionButtonFancy');

            var innerPanelTwo = $.CreatePanel('Panel', optionCategory, 'option_button_' + optionLabelText + '_glow');
            innerPanelTwo.AddClass('OptionButtonGlow');

            // Check if this requires custom settings
            if(optionData.custom) {
                optionCategory.AddClass('optionButtonCustomRequired');
            }

            // Button text
            var optionLabel = $.CreatePanel('Label', optionCategory, 'option_button_' + optionLabelText + '_label');
            optionLabel.text = $.Localize(optionLabelText + '_lod');
            optionLabel.AddClass('OptionButtonLabel');

            // The panel
            var optionPanel = $.CreatePanel('Panel', optionContainer, 'option_panel_' + optionLabelText);
            optionPanel.AddClass('OptionPanel');

            // Build the fields
            var fieldData = optionData.fields;

            for(var i=0; i<fieldData.length; ++i) {
                // Create new script scope
                (function() {
                    // Grab info about this field
                    var info = fieldData[i];
                    var fieldName = info.name;
                    var sort = info.sort;
                    var values = info.values;

                    // Create the info
                    var mainSlot = $.CreatePanel('Panel', optionPanel, 'option_panel_main_' + fieldName);
                    mainSlot.AddClass('optionSlotPanel');
                    var infoLabel = $.CreatePanel('Label', mainSlot, 'option_panel_main_' + fieldName);
                    infoLabel.text = $.Localize(info.des);

                    // Is this a preset?
                    if(info.preset) {
                        mainSlot.AddClass('optionSlotPanelNoCustom');
                    }

                    var floatRightContiner = $.CreatePanel('Panel', mainSlot, 'option_panel_field_' + fieldName + '_container');
                    floatRightContiner.AddClass('optionsSlotPanelContainer');

                    // Create stores for the newly created items
                    var hostPanel;
                    var slavePanel = $.CreatePanel('Label', floatRightContiner, 'option_panel_field_' + fieldName + '_slave');
                    slavePanel.AddClass('optionsSlotPanelSlave');
                    slavePanel.text = 'Unknown';

                    switch(sort) {
                        case 'dropdown':
                            // Create the drop down
                            hostPanel = $.CreatePanel('DropDown', floatRightContiner, 'option_panel_field_' + fieldName);
                            hostPanel.AddClass('optionsSlotPanelHost');
                            hostPanel.AccessDropDownMenu().RemoveAndDeleteChildren();

                            // When the data changes
                            hostPanel.SetPanelEvent('oninputsubmit', function() {
                                // Grab the selected one
                                var selected = hostPanel.GetSelected();
                                //var fieldText = selected.GetAttributeString('fieldText', -1);
                                var fieldValue = selected.GetAttributeInt('fieldValue', -1);

                                // Sets an option
                                setOption(fieldName, fieldValue);
                            });

                            // Maps values to panels
                            var valueToPanel = {};

                            for(var j=0; j<values.length; ++j) {
                                var valueInfo = values[j];
                                var fieldText = valueInfo.text;
                                var fieldValue = valueInfo.value;

                                var subPanel = $.CreatePanel('Label', hostPanel, 'option_panel_field_' + fieldName + '_' + fieldText);
                                subPanel.text = $.Localize(fieldText);
                                //subPanel.SetAttributeString('fieldText', fieldText);
                                subPanel.SetAttributeInt('fieldValue', fieldValue);
                                hostPanel.AddOption(subPanel);

                                // Store the map
                                valueToPanel[fieldValue] = subPanel;

                                if(j == 0) {
                                    hostPanel.SetSelected(subPanel);
                                }
                            }

                            // Mapping function
                            optionFieldMap[fieldName] = function(newValue) {
                                for(var i=0; i<values.length; ++i) {
                                    var valueInfo = values[i];
                                    var fieldText = valueInfo.text;
                                    var fieldValue = valueInfo.value;

                                    if(fieldValue == newValue) {
                                        var thePanel = valueToPanel[fieldValue];
                                        if(thePanel) {
                                            // Select that panel
                                            hostPanel.SetSelected(thePanel);

                                            // Update text
                                            slavePanel.text = $.Localize(fieldText);
                                            break;
                                        }
                                    }
                                }
                            }
                        break;
                    }


                })();
            }

            // Fix stuff
            $.CreatePanel('Label', optionPanel, 'option_panel_fixer_' + optionLabelText);

            // Store the reference
            allOptionLinks[optionLabelText] = {
                panel: optionPanel,
                button: optionCategory
            }

            // The function to run when it is activated
            function whenActivated() {
                // Disactivate all other ones
                for(var key in allOptionLinks) {
                    var data = allOptionLinks[key];

                    data.panel.SetHasClass('activeMenu', false);
                    data.button.SetHasClass('activeMenu', false);
                }

                // Activate our one
                optionPanel.SetHasClass('activeMenu', true);
                optionCategory.SetHasClass('activeMenu', true);

                // If we are the host, tell the server which menu we are looking at
                if(isHost()) {
                    GameEvents.SendCustomGameEventToServer('lodOptionsMenu', {v: optionLabelText});
                }
            }

            // When the button is clicked
            optionCategory.SetPanelEvent('onactivate', whenActivated);

            // Check if it is default
            if(optionData.default) {
                whenActivated();
            }
        })(optionLabelText, allOptions[optionLabelText]);
    }
}

// Player presses auto assign
function onAutoAssignPressed() {
    // Auto assign teams
    Game.AutoAssignPlayersToTeams();

    // Lock teams
    Game.SetTeamSelectionLocked(true);
}

// Player presses shuffle
function onShufflePressed() {
    // Shuffle teams
    Game.ShufflePlayerTeamAssignments();
}

// Player presses lock teams
function onLockPressed() {
    // Don't allow a forced start if there are unassigned players
    if (Game.GetUnassignedPlayerIDs().length > 0)
        return;

    // Lock the team selection so that no more team changes can be made
    Game.SetTeamSelectionLocked(true);
}

// Player presses unlock teams
function onUnlockPressed() {
    // Unlock Teams
    Game.SetTeamSelectionLocked(false);
}

// Lock options pressed
function onLockOptionsPressed() {
    // Ensure teams are locked
    if(!Game.GetTeamSelectionLocked()) return;

    // Lock options
    GameEvents.SendCustomGameEventToServer('lodOptionsLocked', {});
}

// Player tries to join radiant
function onJoinRadiantPressed() {
    // Attempt to join radiant
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
}

// Player tries to join dire
function onJoinDirePressed() {
    // Attempt to join dire
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
}

// Player tries to join unassigned
function onJoinUnassignedPressed() {
    // Attempt to join unassigned
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}

//--------------------------------------------------------------------------------------------------
// Update the unassigned players list and all of the team panels whenever a change is made to the
// player team assignments
//--------------------------------------------------------------------------------------------------
function OnTeamPlayerListChanged() {
    // Kill all of the old panels
    for(var i=0; i<allPlayerPanels.length; ++i) {
        // Grab the panel
        var panel = allPlayerPanels[i];

        // Kill the panel
        panel.DeleteAsync(0);
    }
    allPlayerPanels = [];

    // Move all existing player panels back to the unassigned player list
    /*for ( var i = 0; i < g_PlayerPanels.length; ++i )
    {
        var playerPanel = g_PlayerPanels[ i ];
        playerPanel.SetParent( unassignedPlayersContainerNode );
    }*/

    // Create a panel for each of the unassigned players
    var unassignedPlayers = Game.GetUnassignedPlayerIDs();
    for(var i=0; i<unassignedPlayers.length; ++i) {
        // Add this player to the unassigned list
        addUnassignedPlayer(unassignedPlayers[i]);
    }

    // Add radiant players
    var radiantPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
    for(var i=0; i<radiantPlayers.length; ++i) {
        // Add this player to the unassigned list
        addPlayerToTeam(radiantPlayers[i], $('#theRadiantContainer'));
    }

    // Add radiant players
    var direPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
    for(var i=0; i<direPlayers.length; ++i) {
        // Add this player to the unassigned list
        addPlayerToTeam(direPlayers[i], $('#theDireContainer'));
    }

    // Update all of the team panels moving the player panels for the
    // players assigned to each team to the corresponding team panel.
    /*for ( var i = 0; i < g_TeamPanels.length; ++i )
    {
        UpdateTeamPanel( g_TeamPanels[ i ] )
    }*/

    // Set the class on the panel to indicate if there are any unassigned players
    $('#mainSelectionRoot').SetHasClass('unassigned_players', unassignedPlayers.length != 0 );
    $('#mainSelectionRoot').SetHasClass('no_unassigned_players', unassignedPlayers.length == 0 );

    // Set host privledges
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;

    $('#mainSelectionRoot').SetHasClass('player_has_host_privileges', playerInfo.player_has_host_privileges);
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function OnPlayerSelectedTeam( nPlayerId, nTeamId, bSuccess ) {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;

    // Check to see if the event is for the local player
    if (playerInfo.player_id === nPlayerId) {
        // Play a sound to indicate success or failure
        if (bSuccess) {
            Game.EmitSound('ui_team_select_pick_team');
        } else {
            Game.EmitSound('ui_team_select_pick_team_failed');
        }
    }
}

// A phase was changed
function OnPhaseChanged(table_name, key, data) {
    switch(key) {
        case 'phase':
            // Update the current phase
            currentPhase = data.v;

            // Update phase classes
            var masterRoot = $('#mainSelectionRoot');
            masterRoot.SetHasClass('phase_loading', currentPhase == PHASE_LOADING);
            masterRoot.SetHasClass('phase_option_selection', currentPhase == PHASE_OPTION_SELECTION);
            masterRoot.SetHasClass('phase_banning', currentPhase == PHASE_BANNING);
            masterRoot.SetHasClass('phase_selection', currentPhase == PHASE_SELECTION);
            masterRoot.SetHasClass('phase_drafting', currentPhase == PHASE_DRAFTING);
            masterRoot.SetHasClass('phase_review', currentPhase == PHASE_REVIEW);
            masterRoot.SetHasClass('phase_ingame', currentPhase == PHASE_INGAME);

            // Progrss to the new phase
            SetSelectedPhase(currentPhase, true);
        break;

        case 'endOfTimer':
            // Store the end time
            endOfTimer = data.v;
        break;

        case 'activeTab':
            var newActiveTab = data.v;

            for(var key in allOptionLinks) {
                // Grab reference
                var info = allOptionLinks[key];
                var optionButton = info.button;

                // Set active one
                optionButton.SetHasClass('activeHostMenu', key == newActiveTab);
            }
        break;
    }
}

// An option just changed
function OnOptionChanged(table_name, key, data) {
    // Check if there is a mapping function available
    if(optionFieldMap[key]) {
        // Yep, run it!
        optionFieldMap[key](data.v);
    }

    // Check for the custom stuff
    if(key == 'lodOptionGamemode') {
        // Check if we are allowing custom settings
        allowCustomSettings = data.v == -1;
        $('#mainSelectionRoot').SetHasClass('allow_custom_settings', allowCustomSettings);
        $('#mainSelectionRoot').SetHasClass('disallow_custom_settings', !allowCustomSettings);
    }
}

// Changes which phase the player currently has selected
function SetSelectedPhase(newPhase, noSound) {
    if(newPhase > currentPhase) {
        Game.EmitSound('ui_team_select_pick_team_failed');
        //return;   UNCOMMENT ME AFTER DONE DEBUGGING BIIIIIIITTTTTTTTTHHHHHHH
    }

    // Emit the click noise
    if(!noSound) Game.EmitSound('ui_team_select_pick_team');

    // Set the phase
    selectedPhase = newPhase;

    // Update CSS
    var masterRoot = $('#mainSelectionRoot');
    masterRoot.SetHasClass('phase_option_selection_selected', selectedPhase == PHASE_OPTION_SELECTION);
    masterRoot.SetHasClass('phase_banning_selected', selectedPhase == PHASE_BANNING);
    masterRoot.SetHasClass('phase_selection_selected', selectedPhase == PHASE_SELECTION);
    masterRoot.SetHasClass('phase_drafting_selected', selectedPhase == PHASE_DRAFTING);
    masterRoot.SetHasClass('phase_review_selected', selectedPhase == PHASE_REVIEW);
}

//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
function UpdateTimer() {
    /*var gameTime = Game.GetGameTime();
    var transitionTime = Game.GetStateTransitionTime();

    CheckForHostPrivileges();

    var mapInfo = Game.GetMapInfo();
    $( "#MapInfo" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

    if ( transitionTime >= 0 )
    {
        $( "#StartGameCountdownTimer" ).SetDialogVariableInt( "countdown_timer_seconds", Math.max( 0, Math.floor( transitionTime - gameTime ) ) );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", true );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", false );
    }
    else
    {
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", false );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", true );
    }

    var autoLaunch = Game.GetAutoLaunchEnabled();
    $( "#StartGameCountdownTimer" ).SetHasClass( "auto_start", autoLaunch );
    $( "#StartGameCountdownTimer" ).SetHasClass( "forced_start", ( autoLaunch == false ) );*/

    // Allow the ui to update its state based on team selection being locked or unlocked
    $('#mainSelectionRoot').SetHasClass('teams_locked', Game.GetTeamSelectionLocked());
    $('#mainSelectionRoot').SetHasClass('teams_unlocked', Game.GetTeamSelectionLocked() == false);

    // Phase specific stuff
    switch(currentPhase) {
        case PHASE_BANNING:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodBanningTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;

        case PHASE_SELECTION:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodSelectionTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;

        case PHASE_REVIEW:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodReviewTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;
    }

    $.Schedule(0.1, UpdateTimer);
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function() {
    //$( "#mainTeamContainer" ).SetAcceptsFocus( true ); // Prevents the chat window from taking focus by default

    /*var teamsListRootNode = $( "#TeamsListRoot" );

    // Construct the panels for each team
    for ( var teamId of Game.GetAllTeamIDs() )
    {
        var teamNode = $.CreatePanel( "Panel", teamsListRootNode, "" );
        teamNode.AddClass( "team_" + teamId ); // team_1, etc.
        teamNode.SetAttributeInt( "team_id", teamId );
        teamNode.BLoadLayout( "file://{resources}/layout/custom_game/team_select_team.xml", false, false );

        // Add the team panel to the global list so we can get to it easily later to update it
        g_TeamPanels.push( teamNode );
    }*/

    // Automatically assign players to teams.
    Game.AutoAssignPlayersToTeams();

    // Do an initial update of the player team assignment
    OnTeamPlayerListChanged();

    // Start updating the timer, this function will schedule itself to be called periodically
    UpdateTimer();

    // Build the options categories
    buildOptionsCategories();

    // Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
    $.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

    // Register a listener for the event which is broadcast whenever a player attempts to pick a team
    $.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

    // Hook stuff
    hookAndFire('phase_pregame', OnPhaseChanged);
    hookAndFire('options', OnOptionChanged);
})();
