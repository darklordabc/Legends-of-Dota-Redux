"use strict";

var customTeamAssignments = {};
var active = false;

GameEvents.Subscribe( "player_team", GetTeamInfo);
GameEvents.Subscribe( "player_reconnected", GetTeamInfo);

function TeamSwitchButton (){
    if(!active) {
        ShowTeamSwitch();
    } else {
        CloseTeamSwitch();
    }
}
function ShowTeamSwitch() {
    GetTeamInfo();
    active = true;
    $("#TeamSwitch_Panel").RemoveClass("hidden");
}
function CloseTeamSwitch() {
    active = false;
    $("#TeamSwitch_Panel").AddClass("hidden");
}

function ReceiveCustomTeamInfo( team_info )
{
	customTeamAssignments = team_info;
    SetTeamInfo();
}
GameEvents.Subscribe( "send_custom_team_info", ReceiveCustomTeamInfo);

function GetTeamInfo() {
    GameEvents.SendCustomGameEventToServer( "ask_custom_team_info", {playerID: parseInt(Game.GetLocalPlayerInfo().player_id)} );
}

function LeftGame(id) {
    var connectionState = Game.GetPlayerInfo(id).player_connection_state
    return [DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED,
            DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED].indexOf(connectionState) != -1
}

function SetTeamInfo() {
    var playerIDS = Game.GetAllPlayerIDs();
    var enemyTeam = (customTeamAssignments[Game.GetLocalPlayerInfo().player_id] == DOTATeam_t.DOTA_TEAM_GOODGUYS) ? DOTATeam_t.DOTA_TEAM_BADGUYS : DOTATeam_t.DOTA_TEAM_GOODGUYS;

    var i = 0;
    var teamDifference = 0;
    
    var enemyIDS = playerIDS.filter(function (id) { return customTeamAssignments[id] == enemyTeam })
    var allyIDS = playerIDS.filter(function (id) { return customTeamAssignments[id] != enemyTeam })

    for (var enemyID of enemyIDS) {
        var enemyInfo = Game.GetPlayerInfo(enemyID);
        if (LeftGame(enemyID)) {
            $("#ListDivider"+i).RemoveClass("hidden");
            $("#Player"+i+"_Icon").heroname = Players.GetPlayerSelectedHero(enemyID);

            i++;

            teamDifference++;
        }
    }

    for (; i <= 5; ++i) {
        $("#ListDivider"+i).AddClass("hidden");
    }

    for(var allyID of allyIDS) {
        if (LeftGame(allyID))
        {
            teamDifference--;
        }
    }

    if(Math.abs(teamDifference) >= 2 && active == false){
        $("#BalanceWarning").RemoveClass("hidden");
    }else{
        $("#BalanceWarning").AddClass("hidden");
    }
}

function AttemptTeamSwitch(sentID) {

    var playerIDs = Game.GetAllPlayerIDs();
    var enemyID;
    var k = 0;

    if($("#Player"+sentID+"_Name").text == "DISCONNECTED"){
        for(var playerID in playerIDs){
            if(customTeamAssignments[playerID] != customTeamAssignments[Game.GetLocalPlayerID()]){
                if(k == sentID){
                    enemyID = playerID;
                    break;
                }
                k++;
            }
        }

        var swapTo = (customTeamAssignments[Game.GetLocalPlayerID()] == DOTATeam_t.DOTA_TEAM_GOODGUYS) ? DOTATeam_t.DOTA_TEAM_BADGUYS : DOTATeam_t.DOTA_TEAM_GOODGUYS;
        var enemySwapTo = (customTeamAssignments[enemyID] == DOTATeam_t.DOTA_TEAM_GOODGUYS) ? DOTATeam_t.DOTA_TEAM_BADGUYS : DOTATeam_t.DOTA_TEAM_GOODGUYS;

        GameEvents.SendCustomGameEventToServer( "attemptSwitchTeam", {swapID: Game.GetLocalPlayerInfo().player_id, newTeam: parseInt(swapTo)});
        GameEvents.SendCustomGameEventToServer( "attemptSwitchTeam", {swapID: parseInt(enemyID), newTeam: parseInt(enemySwapTo)});
    }
}
