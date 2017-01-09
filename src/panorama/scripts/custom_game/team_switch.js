"use strict";

var customTeamAssignments = {};
var active = false;
var unbalanced = false;
var disabled = false;
var oldtd = 0;
var debounce = false;

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
    GetTeamInfo();
    if (unbalanced) {
        active = true;
        $('#TeamSwitch_Panel').RemoveClass('hidden');
    }
}
function CloseTeamSwitch() {
    active = false;
    $('#TeamSwitch_Panel').AddClass('hidden');
}

function ReceiveCustomTeamInfo( team_info )
{
    customTeamAssignments = team_info.x;
    dc_timeout = team_info.y;
    SetTeamInfo();
}
GameEvents.Subscribe( 'send_custom_team_info', ReceiveCustomTeamInfo);

function GetTeamInfo() {
    GameEvents.SendCustomGameEventToServer( 'ask_custom_team_info', {playerID: parseInt(Game.GetLocalPlayerInfo().player_id)} );
}

function LeftGame(id) {
    var abandoned = DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED == Game.GetPlayerInfo(id).player_connection_state;
    var timedout;
    for (var dc in dc_timeout) {
        if (dc_timeout[dc] == id) {
            timedout = true;
            break;
        }
    }
        
    return abandoned || timedout;
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
            $('#ListDivider'+i).RemoveClass('hidden');
            $('#Player'+i+'_Icon').heroname = Players.GetPlayerSelectedHero(enemyID);

            i++;
            teamDifference++;
        }
    }
    
    for (; i <= 5; ++i) {
        $('#ListDivider'+i).AddClass('hidden');
    }
    
    for(var allyID of allyIDS) {
        if (LeftGame(allyID)) {
            teamDifference--;
        }
    }
    
    unbalanced = teamDifference >= 2;
    
    if(unbalanced && active == false){
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
