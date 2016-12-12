"use strict";
var screenListener = null;

// Hooks an events and fires for all the keys
function hookAndFire(tableName, callback) {
    // Listen for phase changing information
    CustomNetTables.SubscribeNetTableListener(tableName, callback);

    // Grab the data
    var data = CustomNetTables.GetAllTableValues(tableName);
    if(data != null) {
        for(var i=0; i<data.length; ++i) {
            var info = data[i];
            callback(tableName, info.key, info.value);
        }
    }
}

// When we get player stats
function onGetPlayerStats(table_name, key, data) {
    // Are we dealing with stats?
    if(key != 'stats') return;

    // Cleanup the stats container
    var statsCon = $('#statsContainer');
    statsCon.RemoveAndDeleteChildren();

    // Create the header
    var statsRow = $.CreatePanel('Panel', statsCon, 'stats_row_header');
    statsRow.BLoadLayout( "file://{resources}/layout/custom_game/stats_row.xml", false, false);
    statsRow.onGetRowData(-1);

    var even = true;

    // Loop over the data
    for(var playerID in data) {
        var statsRow = $.CreatePanel('Panel', statsCon, 'stats_row_' + playerID);
        statsRow.BLoadLayout( "file://{resources}/layout/custom_game/stats_row.xml", false, false);
        statsRow.onGetRowData(parseInt(playerID), data[playerID]);

        even = !even;
        statsRow.SetHasClass('evenStatRow', even);
    }

    // Hide the stupid tip
    $.GetContextPanel().SetHasClass('statsFullyLoaded', true);
}

function onHideScreen(table_name, key, data) {
    if (key != 'phase')
        return;

    if (data.v > 1)
        $("#LoDLoadingTip").visible = false;

    // Show screen when voting only on all pick maps
    var mapName = Game.GetMapInfo().map_display_name;
    if ((mapName.match( /5_vs_5/i ) || mapName.match( "3_vs_3" )) && data.v < 3 || data.v < 2)
        return;

    $('#vignette').AddClass('show');

    CustomNetTables.UnsubscribeNetTableListener(screenListener);
}

function setBackground() {
    screenListener = CustomNetTables.SubscribeNetTableListener("phase_pregame", onHideScreen);

    var backgroundPath = "file://{images}/custom_game/loading_screens/";
    var backgroundPanel = $( "#CustomBackground" );

    var backNum = Math.floor(Math.random() * backList.length);
    $('#BackgroundImage').SetImage(backgroundPath + backList[backNum].img);

    // Hide credits if author is empty
    if (!backList[backNum].author)
    {
        $('#BackgroundTitle').GetParent().visible = false;
        return;
    }

    $('#BackgroundTitle').text = backList[backNum].title ? backList[backNum].title : '';
    $('#BackgroundCredit').text = backList[backNum].author;

    if (backList[backNum].url != '')
    {
        $('#BackgroundCredit').GetParent().SetPanelEvent('onactivate', function(){ 
            $.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), backList[backNum].url);
        });
        $('#BackgroundCredit').AddClass('url');
    }
}

(function() {
    // Give a delay, and then hook pregame stuff
    $.Schedule(0.1, function() {
        // Hook getting player data
        hookAndFire('phase_pregame', onGetPlayerStats);
    });

    setBackground(); 

    startTips($("#LoDLoadingTip"));
})();