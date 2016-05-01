"use strict";

// Called when we get our row data
function onGetRowData(playerID, data) {
    if(playerID == -1) {
        // Header
        $('#playerName').text = $.Localize('statsPlayerName');
        $('#totalGames').text = $.Localize('statsTotalGames');
        $('#totalWins').text = $.Localize('statsTotalWins');
        $('#totalAbandons').text = $.Localize('statsTotalAbandons');
        $('#totalFails').text = $.Localize('statsTotalFails');
        $('#lastAbandon').text = $.Localize('statsLastAbandoned');

        // Add class
        $.GetContextPanel().SetHasClass('statHeader', true);
    } else {
        var playerInfo = Game.GetPlayerInfo(playerID);

        var allElements = [
            'playerName',
            'totalGames',
            'totalWins',
            'totalAbandons',
            'totalFails',
            'lastAbandon'
        ];

        // Is it the real Ash47?
        var playerName = playerInfo.player_name;
        if(playerInfo.player_steamid == 76561197988355984) {
            for(var i=0; i<allElements.length; ++i) {
                $('#' + allElements[i]).AddClass('theRealAsh47');
            }
        } else {
            // No one can steal my name
            playerName = playerName.replace(/ash47/ig, 'some noob');
            playerName = playerName.replace(/47/ig, '48');

            for(var i=0; i<allElements.length; ++i) {
                $('#' + allElements[i]).RemoveClass('theRealAsh47');
            }
        }



        // Workout when the last abandon was
        var abandonText = $.Localize('statAbandonNever');
        var lat = data.timeSinceLastAbandon;
        if(lat > 0 && data.totalAbandons > 0) {
            if(lat < 60 * 5) {
                abandonText = $.Localize('statAbandonLastMinute');
            } else if(lat < 60 * 60 * 2) {
                abandonText = $.Localize('statAbandonLastHour').replace('{0}', Math.ceil(lat/60));
            } else if(lat < 60 * 60 * 48) {
                abandonText = $.Localize('statAbandonLessThanDay').replace('{0}', Math.ceil(lat/60/60));
            } else {
                abandonText = $.Localize('statAbandonMoreThanOneDay').replace('{0}', Math.ceil(lat/60/60/24));
            }
        }

        $('#playerName').text = playerName;
        $('#totalGames').text = data.totalGames;
        $('#totalWins').text = data.totalWins;
        $('#totalAbandons').text = data.totalAbandons;
        $('#totalFails').text = data.totalFails;
        $('#lastAbandon').text = abandonText;
    }
}

// Create a new scope
(function() {
    // Store exports
    $.GetContextPanel().onGetRowData = onGetRowData;
})();