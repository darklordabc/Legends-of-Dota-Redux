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

function SaveFavBuilds( builds ){
    var requestParams = {
        Command : "SaveFavBuilds",
        Data: {
            SteamID: util.getSteamID32(),
            Builds : JSON.stringify(builds),
        }
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function () {}) );
}

function LoadFavBuilds( ){
    var requestParams = {
        Command : "LoadFavBuilds",
        SteamID: util.getSteamID32(),
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  (function ( data ) {
        var con = $('#pickingPhaseRecommendedBuildContainer');        
        for (var i = 0; i < con.GetChildCount(); i++) {
            var child = con.GetChild(i);
            child.setFavorite(false);
        }

        var rows = JSON.parse(data);
        if (rows.length == 0)
            return;

        var builds = JSON.parse(rows[0].FavBuilds);
        if (builds.length == 0)
        	return;

        for (var i = 0; i < con.GetChildCount(); i++) {
            var child = con.GetChild(i);
            child.setFavorite(builds.indexOf(child.buildID) != -1);
        }
    }) );
}

function LoadBuilds( filter ){
    var requestParams = {
        Command : "LoadBuilds",
        Filter: filter,
    }

    GameUI.CustomUIConfig().SendRequest( requestParams,  function ( data ) {
        var builds = JSON.parse(data);

        // The  container to work with
        var con = $('#pickingPhaseRecommendedBuildContainer');

        for(var build of builds) 
            addRecommendedBuild(con, build);

        LoadFavBuilds();

        $('#buildLoadingIndicator').visible = false;
        con.GetParent().visible = true;
    },
    function(){
        $('#buildLoadingSpinner').visible = false;
        $('#buildLoadingIndicatorText').text = $.Localize('#unableLoadingBuilds');
    });
} 