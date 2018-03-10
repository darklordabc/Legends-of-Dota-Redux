"use strict";

var util = GameUI.CustomUIConfig().Util;

// Have we spawned a hero builder?
var spawnedHeroBuilder = false;

var heroBuilderPanel = null;

function showIngameBuilder(args) {
    if(!spawnedHeroBuilder) {
        spawnedHeroBuilder = true;

        var balanceMode = GameUI.AbilityCosts.balanceModeEnabled == 1 ? true : false;

        // Spawn the hero builder
        // if (args.ingamePicking == true) {
            if (!heroBuilderPanel) {
                heroBuilderPanel = $.CreatePanel('Panel', $('#heroBuilderDisplay'), '');
                heroBuilderPanel.BLoadLayout('file://{resources}/layout/custom_game/game_setup/game_setup.xml', false, false);
            }
        // } else {
        //     try {
        //         heroBuilderPanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CustomUIContainer_GameSetup").GetChild(0).GetChild(0);
        //         if (heroBuilderPanel != null) {
        //             heroBuilderPanel.SetParent($('#heroBuilderDisplay'))
        //         } else {
        //             throw true;
        //         }
        //     } catch (err) {
        //         heroBuilderPanel = $.CreatePanel('Panel', $('#heroBuilderDisplay'), '');
        //         heroBuilderPanel.BLoadLayout('file://{resources}/layout/custom_game/game_setup/game_setup.xml', false, false);
        //     }  
        // }

        // $.Msg(heroBuilderPanel.id);
        $.Schedule(1.0, (function () {
            $('#heroBuilderDisplay').visible = true;
        }))

        heroBuilderPanel.visible = true;
        heroBuilderPanel.isIngameBuilder = true;
        heroBuilderPanel.isInitialIngameBuilder = args.ingamePicking == true;

        util.blockMouseWheel(heroBuilderPanel);

        // Boot it into selection mode
        // heroBuilderPanel.SetHasClass('phase_ingame', true);
        heroBuilderPanel.SetHasClass('phase_selection_selected', true);
        heroBuilderPanel.SetHasClass('phase_selection', true);
		heroBuilderPanel.SetHasClass('ingame_menu', true);
		heroBuilderPanel.SetHasClass('review_selection', false);
		heroBuilderPanel.SetHasClass('builder_enabled', util.builderEnabled);

        heroBuilderPanel.balanceMode = balanceMode;
        heroBuilderPanel.FindChildTraverse("balanceModeFilter").SetHasClass("balanceModeDisabled", true);
        for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
            heroBuilderPanel.FindChildTraverse("buttonShowTier" + (i + 1) ).SetHasClass("balanceModeDisabled", balanceMode == false);
        }
        heroBuilderPanel.FindChildTraverse("balanceModePointsPreset").SetHasClass("balanceModeDisabled", balanceMode == false);
        heroBuilderPanel.FindChildTraverse("balanceModePointsHeroes").SetHasClass("balanceModeDisabled", balanceMode == false);
        heroBuilderPanel.FindChildTraverse("balanceModePointsSkills").SetHasClass("balanceModeDisabled", balanceMode == false);

        heroBuilderPanel.FindChildTraverse("tabsSelector").visible = true;

        heroBuilderPanel.FindChildTraverse("chat").visible = false;

        heroBuilderPanel.showBuilderTab('pickingPhaseMainTab');
        
        heroBuilderPanel.FindChildTraverse("abilityBonusesPanel").visible = args.ingamePicking == true;
        heroBuilderPanel.FindChildTraverse("newAbilitiesPanel").visible = args.ingamePicking == true;
        heroBuilderPanel.FindChildTraverse("balancedBuildPanel").visible = args.ingamePicking == true;

        // Make it visible
        $('#heroBuilderDisplay').visible = true;      
		
		util.reviewOptionsChange();
    } else {
        heroBuilderPanel.visible = true;
        $('#heroBuilderDisplay').visible = !$('#heroBuilderDisplay').visible;
    }

    //heroBuilderPanel.doActualTeamUpdate();
}

(function() {
    GameEvents.Subscribe('lodShowIngameBuilder', function(args) {
        showIngameBuilder(args);
    })
    // Hide the hero selection when spawn hero is pressed
    GameEvents.Subscribe('lodNewHeroBuild', function() {
        $('#heroBuilderDisplay').visible = false;
    });
    GameEvents.SendCustomGameEventToServer("lodCheckIngameBuilder", {})
})();