/*
    ability_costs.js
    
    A hard-coded list of ability costs for balance mode (easily maintainable from this file.
    
    To add a new ability cost, use the setCost function.
    
    getCost(abilityName)
        Simple getter method for the ability costs.

        abilityName = String. Name of the ability in the key files.
        Returns cost of the ability.

    setCost(abilityName, cost)
        Simple setter method for the ability costs.

        abilityName = String. The name of the ability in the key files.
        cost = Integer. The cost of the ability. Use the provided constants.
    
    Try to avoid setting spells to COST_TIER_FOUR. Instead, just delete that
    line. A null value will be assumed to be NO_COST.
    
    NO_COST exists so that new tiers can be added easily without requiring
    an inspection of the code for places where the current lowest tier is
    assumed to be 0.
*/

// Tier cost constants:

var COST_TIER_ONE   = 50;
var COST_TIER_TWO   = 30;
var COST_TIER_THREE = 20;
var COST_TIER_FOUR  = 0;
var NO_COST = 0;

// Globals for accessing costs outside of this file:

GameUI.AbilityCosts = GameUI.AbilityCosts || {};
GameUI.AbilityCosts.balanceModeEnabled = false;
GameUI.AbilityCosts.costList = [];
GameUI.AbilityCosts.TIER_ONE = COST_TIER_ONE;
GameUI.AbilityCosts.TIER_TWO = COST_TIER_TWO;
GameUI.AbilityCosts.TIER_THREE = COST_TIER_THREE;
GameUI.AbilityCosts.TIER_FOUR = COST_TIER_FOUR;
GameUI.AbilityCosts.NO_COST = NO_COST;

function getCost(abilityName) {
    var cost = GameUI.AbilityCosts.costList[abilityName];
    cost = (cost)? cost: NO_COST;
    return cost;
}
function setCost(abilityName, cost) {
    GameUI.AbilityCosts.costList[abilityName] = cost;
}

GameUI.AbilityCosts.setCost = setCost;
GameUI.AbilityCosts.getCost = getCost;

// Ability list:

setCost('antimage_mana_break', COST_TIER_FOUR);
setCost('antimage_blink', COST_TIER_THREE);
setCost('antimage_spell_shield', COST_TIER_TWO);
setCost('antimage_mana_void', COST_TIER_ONE);
