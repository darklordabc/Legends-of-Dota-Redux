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

function AttemptTeamSwitch(index) {
    var playerIDs = Game.GetAllPlayerIDs();
    var localPlayerID = Game.GetLocalPlayerID();
    var enemyID;
    var k = 0;


    enemyID = playerIDs.filter(function (id) { return areEnemies(localPlayerID, id)  && LeftGame(id)})[index]

    GameEvents.SendCustomGameEventToServer('swapPlayers', {x: localPlayerID, y: enemyID})
}
