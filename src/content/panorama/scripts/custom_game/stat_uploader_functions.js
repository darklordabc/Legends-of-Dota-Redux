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

function RecordPlayerSC( ) {
    var check = (function checkSettingCode() {
        var data = $('#importAndExportEntry').text;

        var decodeData;
        try {
            decodeData = JSON.parse(data);
        } catch(e) {
            return false;
        }
        return data.length > 0;
    })

    if (check() && saveSCTimer == false) {
        saveSCTimer = true;
        $('#importAndExportSaveButton').SetHasClass("disableButtonHalf", true);
        $.Schedule(30.0, function () {
            saveSCTimer = false;
            $('#importAndExportSaveButton').SetHasClass("disableButtonHalf", false);
        })
    } else {
        return false
    }

    var requestParams = {
        Command : "RecordPlayerSC",
        Data: {
            SteamID: util.getSteamID32(),
            SettingsCode : $('#importAndExportEntry').text,
        }
    }

    GameUI.CustomUIConfig().SendRequest( requestParams, function(obj){
        addNotification({"text" : 'importAndExport_success_save'});
    })
}