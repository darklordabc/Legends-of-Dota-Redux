"use strict";

var util = GameUI.CustomUIConfig().Util;

function OnClientCheckIn(args) {

    var playerInfo = Game.GetLocalPlayerInfo();
    var hostInfo = 0
    if ( playerInfo )
        hostInfo = playerInfo.player_id === GameUI.CustomUIConfig().hostID

    var payload = {
        modIdentifier: args.modID,
        steamID32: util.getSteamID32(),
        isHost: hostInfo, 
        matchID: args.matchID,
        schemaVersion: args.schemaVersion
    };

    $.Msg('Sending: ', payload);

    $.AsyncWebRequest('https://api.getdotastats.com/s2_check_in.php',
        {
            type: 'POST',
            data: {payload: JSON.stringify(payload)},
            success: function (data) {
                $.Msg('GDS Reply: ', data)
            }
        });
}

function Print(msg) {
    $.Msg(msg.content)
}

(function () {
    $.Msg("StatCollection Client Loaded");

    GameEvents.Subscribe("statcollection_client", OnClientCheckIn);
    GameEvents.Subscribe("statcollection_print", Print);

})();