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

(function() {
    GameEvents.Subscribe('lodEnableIngameBuilder', function() {
        $('#heroBuilder').visible = true;
    });

    GameEvents.Subscribe('lodShowCheatPanel', setupCheats);
})();