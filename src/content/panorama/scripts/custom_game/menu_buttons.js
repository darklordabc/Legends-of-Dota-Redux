"use strict";
var isCheatsEnabled = false;

function setupCheats(data){
    isCheatsEnabled = (data.cheats == 1) ? true : false;
}

function toggleCheats() {
    GameEvents.SendEventClientSide('lodOnCheats', {});
}

// Play wants to open changelog
function onBtnOpenChangelog() {
    GameEvents.SendEventClientSide('lodOnChangelog', { });
}

// Play wants to open the hero builder
function onBtnOpenHeroBuilderPressed() {
	GameUI.CustomUIConfig().Util.reviewOptions = false;
	GameUI.CustomUIConfig().Util.reviewOptionsChange();
    GameEvents.SendCustomGameEventToServer('lodOnIngameBuilder', { playerID: Players.GetLocalPlayer() });
}

// Play wants to open the option viewer
function onBtnOpenOptionReviewPressed() {
	GameUI.CustomUIConfig().Util.reviewOptions = true;
	GameUI.CustomUIConfig().Util.reviewOptionsChange();
    GameEvents.SendCustomGameEventToServer('lodOnIngameBuilder', { playerID: Players.GetLocalPlayer() });
}

function enableIngameBuilder() {
	GameUI.CustomUIConfig().Util.builderEnabled = true;
	$('#heroBuilder').visible = true;
}

function openPatreon() {
    $.DispatchEvent('ExternalBrowserGoToURL', 'https://www.patreon.com/darklordabc');
}

function hidePatreonButton() {
    $('#patreonButton').visible = false;
}

(function() {
    var isPremium = GameUI.CustomUIConfig().isPremiumPlayer;
    $('#patreonButton').visible = !isPremium;

	GameUI.CustomUIConfig().Util.builderEnabled = false;
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
