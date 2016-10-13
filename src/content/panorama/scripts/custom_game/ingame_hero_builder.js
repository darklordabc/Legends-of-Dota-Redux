"use strict";

// Have we spawned a hero builder?
var spawnedHeroBuilder = false;

// Play wants to open the hero builder
function onBtnOpenHeroBuilderPressed() {
    if(!spawnedHeroBuilder) {
        spawnedHeroBuilder = true;

        // Spawn the hero builder
        var heroBuilderPanel = $.CreatePanel('Panel', $('#heroBuilderDisplay'), '');
        heroBuilderPanel.BLoadLayout('file://{resources}/layout/custom_game/game_setup.xml', false, false);

        // Boot it into selection mode
        // heroBuilderPanel.SetHasClass('phase_ingame', true);
        heroBuilderPanel.SetHasClass('phase_selection_selected', true);
        heroBuilderPanel.SetHasClass('phase_selection', true)
    }

    // Hide the hero selection when spawn hero is pressed
    GameEvents.Subscribe('lodNewHeroBuild', function() {
        $('#heroBuilderDisplay').visible = false;
    });

    // Make it visible
    $('#heroBuilderDisplay').visible = true;
}

(function() {
    GameEvents.Subscribe('lodEnableIngameBuilder', function() {
        $('#heroBuilderContainer').AddClass('visible');
    });
})();