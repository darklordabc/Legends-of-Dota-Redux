"use strict";

// When player details are changed
function OnPlayerDetailsChanged() {
    if (GameUI.CustomUIConfig().hostID == undefined) {
        for (var i=0; i<24; ++i){
            var playerInfo = Game.GetPlayerInfo(i);
            if (playerInfo == null) continue;
            if (playerInfo.player_has_host_privileges) {
                GameUI.CustomUIConfig().hostID = playerInfo.player_id;
                GameUI.CustomUIConfig().mainHost = playerInfo.player_id;
            }
        }
    }
    var playerID = $.GetContextPanel().GetAttributeInt('playerID', -1);
    var playerInfo = Game.GetPlayerInfo(playerID);
    if (!playerInfo) return;

    $("#playerName").text = playerInfo.player_name;
    $("#playerAvatar").steamid = playerInfo.player_steamid;

    $.GetContextPanel().SetHasClass("player_is_local", playerInfo.player_is_local);
    $.GetContextPanel().SetHasClass("player_has_host_privileges", GameUI.CustomUIConfig().hostID === playerID);
}

function OnHostChanged(data) {
    GameUI.CustomUIConfig().hostID = data.newHost;
    OnPlayerDetailsChanged();
}

// When this panel loads
(function()
{
    OnPlayerDetailsChanged();
    $.RegisterForUnhandledEvent('DOTAGame_PlayerDetailsChanged', OnPlayerDetailsChanged);
        GameEvents.Subscribe('lodOnHostChanged', function(data) {
        OnHostChanged(data);
    });
})();
