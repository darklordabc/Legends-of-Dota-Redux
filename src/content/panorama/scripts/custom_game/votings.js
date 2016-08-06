"use strict";

var customTeamAssignments = {};
var active = false;
var unbalanced = false;
var disabled = false;
var oldtd = 0;
var debounce = false;

var votingBox;

var dc_timeout = [];

var handler;

GameEvents.Subscribe('vote_dialog', function () {
    debounce = true;
    handler = $.Schedule(10, function () { debounce = false });
});

GameEvents.Subscribe('player_declined', function () {
    $.CancelScheduled(handler);
    $.Schedule(2, function () { debounce = false });
});

GameEvents.Subscribe('player_team', GetTeamInfo);
GameEvents.Subscribe('player_reconnected', GetTeamInfo);

function TeamSwitchButton (){
    if(!active) {
        ShowTeamSwitch();
    } else {
        CloseTeamSwitch();
    }
}
function ShowTeamSwitch() {
    if (disabled == false) {
        GetTeamInfo();
        if (unbalanced) {
            active = true;
            $('#TeamSwitch_Panel').RemoveClass('TeamSwitch_Panel_Hidden');
        } else {
            $.DispatchEvent('DOTAShowTextTooltip',  $('#TeamSwitch_Button'), "#teamSwitch_tooltip");
        }
    } else {
        $.DispatchEvent('DOTAShowTextTooltip',  $('#TeamSwitch_Button'), "#teamSwitch_cooldown");
    }
}
function CloseTeamSwitch() {
    active = false;
    $('#TeamSwitch_Panel').AddClass('TeamSwitch_Panel_Hidden');
}

function ReceiveCustomTeamInfo( team_info )
{
    customTeamAssignments = team_info.x;
    dc_timeout = team_info.y;
    SetTeamInfo();
}

function GetTeamInfo() {
    GameEvents.SendCustomGameEventToServer( 'ask_custom_team_info', {playerID: parseInt(Game.GetLocalPlayerInfo().player_id)} );
}

function LeftGame(id) {
    var abandoned = DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED == Game.GetPlayerInfo(id).player_connection_state;
    var timedout;
    var nohero = (Players.GetPlayerSelectedHero( id ) == null);
    for (var dc in dc_timeout) {
        if (dc_timeout[dc] == id) {
            timedout = true;
            break;
        }
    }
        
    return abandoned || timedout || nohero;
}

function areAllies(x, y) {
    return customTeamAssignments[x] == customTeamAssignments[y]
}

function areEnemies(x, y) {
    return customTeamAssignments[x] != customTeamAssignments[y]
}

function SetTeamInfo() {
    var playerIDS = Game.GetAllPlayerIDs();
    var localPlayerID = Game.GetLocalPlayerID();
    var enemyIDS = playerIDS.filter(function (id) { return areEnemies(localPlayerID, id) })
    var allyIDS = playerIDS.filter(function (id) { return areAllies(localPlayerID, id )})
    
    var teamDifference = 0;
    var i = 0;

    var boxPanel = $.GetContextPanel().FindChildrenWithClassTraverse("VotingBoxTeamSwitch")[0];

    for (var enemyID of enemyIDS) {
        var enemyInfo = Game.GetPlayerInfo(enemyID);
        if (LeftGame(enemyID)) {

            if (boxPanel) {
                boxPanel.FindChildTraverse('ListDivider'+i).RemoveClass('hidden');
                boxPanel.FindChildTraverse('Player'+i+'_Icon').heroname = Players.GetPlayerSelectedHero(enemyID);
            }

            i++;
            teamDifference++;
        }
    }
    
    if (boxPanel) { 
        for (; i <= 5; ++i) {
            boxPanel.FindChildTraverse('ListDivider'+i).AddClass('hidden');
        } 
    }
    
    for(var allyID of allyIDS) {
        if (LeftGame(allyID)) {
            teamDifference--;
        }
    }
    
    unbalanced = teamDifference >= 2;
    
    if(unbalanced && active == false && $("#VotingDropDownRoot").BHasClass("VotingMenuHidden")){
        if (oldtd < teamDifference) {
            $('#BalanceWarning').RemoveClass('hidden')
            $.Schedule(20, function() { $('#BalanceWarning').AddClass('hidden') });
        };
    }else{
        $('#BalanceWarning').AddClass('hidden');
    }
    oldtd = teamDifference;
}

function AttemptTeamSwitch(index) {
    if (disabled || !unbalanced || debounce) return;

    CloseTeamSwitch();

    var playerIDs = Game.GetAllPlayerIDs();
    var localPlayerID = Game.GetLocalPlayerID();
    var enemyID;
    var k = 0;

    enemyID = playerIDs.filter(function (id) { return areEnemies(localPlayerID, id)  && LeftGame(id)})[index]

    GameEvents.SendCustomGameEventToServer('swapPlayers', {x: localPlayerID, y: enemyID})
    disabled = true;
    $.Schedule(300, function () { disabled = false });
}

function VotingMenuButton() {
    $("#VotingDropDownRoot").ToggleClass("VotingMenuHidden");
    $('#BalanceWarning').AddClass('hidden');
    if (votingBox) {
        votingBox.DeleteAsync(0.0);
        votingBox.RemoveAndDeleteChildren();
    }
}

function CreateVotingMenu() {
    var rootPanel = $("#VotingDropDownRoot");
    rootPanel.SetPanelEvent("onmouseout", (function () {
        rootPanel.AddClass("VotingMenuHidden");
    }));
    rootPanel.SetPanelEvent("onmouseover", (function () {
        rootPanel.RemoveClass("VotingMenuHidden");
    }));

    var votingInfo = GameUI.CustomUIConfig().votingInfo;
    var i = 0;
    for (var votingGroupKey in votingInfo) {
        (function () {
            var votingGroup = votingInfo[votingGroupKey];

            var groupEntry = $.CreatePanel("Panel", rootPanel, votingGroupKey + "Entry");
            groupEntry.BLoadLayoutSnippet("VotingMenuEntry");

            groupEntry.FindChildTraverse("VotingMenuLabel").text = $.Localize( "votings_" + votingGroupKey);

            var groupPanel = $.CreatePanel("Panel", $.GetContextPanel(), votingGroupKey + "Panel");
            groupPanel.AddClass("VotingDropDown");
            groupPanel.AddClass("VotingDropDownSecondaryMargin");
            groupPanel.AddClass("VotingMenuHidden");
            groupPanel.style.marginTop = ((i * 35) + 50) + "px;";

            groupPanel.SetPanelEvent("onmouseover", (function () {
                groupPanel.RemoveClass("VotingMenuHidden");
                rootPanel.RemoveClass("VotingMenuHidden");
                groupEntry.AddClass("hover");
            }));

            groupPanel.SetPanelEvent("onmouseout", (function () {
                groupPanel.AddClass("VotingMenuHidden");
                rootPanel.AddClass("VotingMenuHidden");
                groupEntry.RemoveClass("hover");
            }));

            groupEntry.SetPanelEvent("onmouseover", (function () {
                groupPanel.RemoveClass("VotingMenuHidden");
                groupEntry.AddClass("hover");
            }));

            groupEntry.SetPanelEvent("onmouseout", (function () {
                groupEntry.RemoveClass("hover");
                groupPanel.AddClass("VotingMenuHidden");
            }));

            for (var votingKey in votingGroup) {
                (function () {
                    var votingEntry = $.CreatePanel("Panel", groupPanel, votingKey + "Entry");
                    votingEntry.BLoadLayoutSnippet("VotingMenuEntry");
                    votingEntry.FindChildTraverse("VotingMenuLabel").text = $.Localize( "votings_" + votingKey);
                    votingEntry.votingKey = votingKey;

                    votingEntry.SetPanelEvent("onmouseactivate", (function () {
                        groupPanel.AddClass("VotingMenuHidden");
                        rootPanel.AddClass("VotingMenuHidden");

                        votingBox = $.CreatePanel("Panel", $.GetContextPanel(), "VotingBox");

                        if (votingEntry.votingKey == "switch_team") {
                            votingBox.BLoadLayoutSnippet("VotingBoxTeamSwitch");
                        } else {
                            votingBox.BLoadLayoutSnippet("VotingBoxOption");
                            votingBox.FindChildTraverse("VotingBoxOptionName").text = $.Localize("votings_" + votingEntry.votingKey);
                            votingBox.FindChildTraverse("VotingBoxOptionDescription").text = $.Localize("votings_" + votingEntry.votingKey + "Description");
                            
                            votingBox.min = votingGroup[votingEntry.votingKey]['min'];
                            votingBox.max = votingGroup[votingEntry.votingKey]['max'];

                            if (votingBox.min && votingBox.max) {
                                votingBox.FindChildTraverse("VotingBoxOptionTextEntry").FindChildTraverse("PlaceholderText").text = votingBox.min+"-"+votingBox.max;
                            } else {
                                votingBox.FindChildTraverse("VotingBoxOptionTextEntry").visible = false;
                            }

                            votingBox.FindChildTraverse("VotingBoxSubmitButton").SetPanelEvent('onmouseactivate', (function () {
                                var value = parseInt(votingBox.FindChildTraverse("VotingBoxOptionTextEntry").text);

                                if (value < votingBox.min || value > votingBox.max) {
                                    return;
                                }

                                GameEvents.SendCustomGameEventToServer('start_voting', {value: value, option: votingEntry.votingKey})

                                votingBox.DeleteAsync(0.0);
                                votingBox.RemoveAndDeleteChildren();
                            }));

                            votingBox.FindChildTraverse("VotingBoxCancelButton").SetPanelEvent('onmouseactivate', (function () {
                                votingBox.DeleteAsync(0.0);
                                votingBox.RemoveAndDeleteChildren();
                            }));
                        }
                    }));
                })();
            }
        })();
        i++;
    }
}

(function () {
    GameEvents.Subscribe( 'send_custom_team_info', ReceiveCustomTeamInfo);

    CreateVotingMenu();
})()