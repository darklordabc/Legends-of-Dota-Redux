"use strict";

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

// When this panel loads
(function()
{
    OnPlayerDetailsChanged();
    $.RegisterForUnhandledEvent('DOTAGame_PlayerDetailsChanged', OnPlayerDetailsChanged);
})();
