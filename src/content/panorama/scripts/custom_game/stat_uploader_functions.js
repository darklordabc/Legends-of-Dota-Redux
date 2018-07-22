"use strict";

var util = GameUI.CustomUIConfig().Util;

function MarkMessageAsRead( msgID ) {
    var playerID = Players.GetLocalPlayer();
    var info =  Game.GetPlayerInfo(Players.GetLocalPlayer());

    var requestParams = {
        Command: "MarkMessageRead",
        MessageID: msgID
    };

    GameUI.CustomUIConfig().SendRequest( requestParams, (function () {}) );
}

function SendMessage( text ) {
    var playerID = Players.GetLocalPlayer();
    var info =  Game.GetPlayerInfo(Players.GetLocalPlayer());

    var requestParams = {
        Command: "SendPlayerMessage",
        Data: {
            SteamID: util.getSteamID32(),
            Nickname: encodeURIComponent(info.player_name),
            Message: encodeURIComponent(text),
            TimeStamp: util.getDate()
        }
    };

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function () {}) );
}
