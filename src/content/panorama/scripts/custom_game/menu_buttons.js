"use strict";
var isCheatsEnabled = false;

function setupCheats(data){
    isCheatsEnabled = (data.cheats == 1) ? true : false;
}

function toggleCheats(){
    if (!isCheatsEnabled){
        GameEvents.SendCustomGameEventToServer('lodOnCheats', {
        status: 'error',
        });
        return false;
    }

    GameEvents.SendEventClientSide('lodOnCheats', { });
}

// Play wants to open changelog
function onBtnOpenChangelog() {
    GameEvents.SendEventClientSide('lodOnChangelog', { });
}

// Play wants to open the hero builder
function onBtnOpenHeroBuilderPressed() {
    GameEvents.SendCustomGameEventToServer('lodOnIngameBuilder', { playerID: Players.GetLocalPlayer() });
}

function enableIngameBuilder() {
   $('#heroBuilder').visible = true;
}

(function() {
    CustomNetTables.SubscribeNetTableListener('options', function (tableName, key, value) {
        if (key == 'lodEnableIngameBuilder' && value.state == true) {
            enableIngameBuilder()
        }
    });

    var data = CustomNetTables.GetTableValue('options', 'lodEnableIngameBuilder');
    if (data && data.state == true) {
        enableIngameBuilder()
    }
    
    GameEvents.Subscribe('lodShowCheatPanel', setupCheats);
})();