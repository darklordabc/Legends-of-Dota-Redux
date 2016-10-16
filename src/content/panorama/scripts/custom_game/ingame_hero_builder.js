"use strict";

// Have we spawned a hero builder?
var spawnedHeroBuilder = false;

// Play wants to open the hero builder
function onBtnOpenHeroBuilderPressed() {
    GameEvents.SendCustomGameEventToServer('lodOnIngameBuilder', {playerID: Players.GetLocalPlayer()});
}

function showIngameBuilder() {
    if(!spawnedHeroBuilder) {
        spawnedHeroBuilder = true;

        // Spawn the hero builder
        var heroBuilderPanel = $.CreatePanel('Panel', $('#heroBuilderDisplay'), '');
        heroBuilderPanel.BLoadLayout('file://{resources}/layout/custom_game/game_setup.xml', false, false);

        // Boot it into selection mode
        // heroBuilderPanel.SetHasClass('phase_ingame', true);
        heroBuilderPanel.SetHasClass('phase_selection_selected', true);
        heroBuilderPanel.SetHasClass('phase_selection', true);
        if (GameUI.AbilityCosts.balanceModeEnabled) {
            var balanceMode = GameUI.AbilityCosts.balanceModeEnabled === 1 ? true : false;
            heroBuilderPanel.FindChildTraverse("balanceModeFilter").SetHasClass("balanceModeDisabled", !balanceMode);
            for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
                heroBuilderPanel.FindChildTraverse("buttonShowTier" + (i + 1) ).SetHasClass("balanceModeDisabled", !balanceMode);
            }
            heroBuilderPanel.FindChildTraverse("balanceModePointsPreset").SetHasClass("balanceModeDisabled", !balanceMode);
            heroBuilderPanel.FindChildTraverse("balanceModePointsHeroes").SetHasClass("balanceModeDisabled", !balanceMode);
            heroBuilderPanel.FindChildTraverse("balanceModePointsSkills").SetHasClass("balanceModeDisabled", !balanceMode);
        }
        // Hide the hero selection when spawn hero is pressed
        GameEvents.Subscribe('lodNewHeroBuild', function() {
            $('#heroBuilderDisplay').visible = false;
        });
        // Make it visible
        $('#heroBuilderDisplay').visible = true;
    } else {
        $('#heroBuilderDisplay').visible = !$('#heroBuilderDisplay').visible;
    }

}

(function() {
    GameEvents.Subscribe('lodEnableIngameBuilder', function() {
        $('#heroBuilderContainer').AddClass('visible');
    });
    GameEvents.Subscribe('lodShowIngameBuilder', function() {
        showIngameBuilder();
    })
})();