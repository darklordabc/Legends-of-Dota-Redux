"use strict";

function GetSteamID32() {
    var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
}

function GetDate() {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    return yyyy * 10000 + mm * 100 + dd;
}

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
            SteamID: GetSteamID32(),
            Nickname: encodeURIComponent(info.player_name),
            Message: encodeURIComponent(text),
            TimeStamp: GetDate() 
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
            SteamID: GetSteamID32(),
            SettingsCode : $('#importAndExportEntry').text,
        }
    }

    GameUI.CustomUIConfig().SendRequest( requestParams, function(obj){
        $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', $('#importAndExportLoadButton'), "ImportAndExportTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize("importAndExport_success_save"));
    
        $.Schedule(3.0, function () {
            $.DispatchEvent( 'UIHideCustomLayoutTooltip', $('#importAndExportLoadButton'), "ImportAndExportTooltip");
        });
    })
}

function SaveFavBuilds( builds ){
    var requestParams = {
        Command : "SaveFavBuilds",
        Data: {
            SteamID: GetSteamID32(),
            Builds : JSON.stringify(builds),
        }
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function () {}) );
}

function LoadFavBuilds( ){
    var requestParams = {
        Command : "LoadFavBuilds",
        SteamID: GetSteamID32(),
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function ( data ) {
      $.Msg(data);
    }) );
}

function LoadBuilds( filter ){
    var requestParams = {
        Command : "LoadBuilds",
        Filter: filter,
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function ( data ) {
      $.Msg(data);
    }) );
} 