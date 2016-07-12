/*
    ability_costs.js
    
    getCost(abilityName)
        Simple getter method for the ability costs.

        abilityName = String. Name of the ability in the key files.
        Returns cost of the ability.
    
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
GameUI.AbilityCosts.getCost = getCost;

function setCost(data) {
    $.Msg(data.abilityName + " = " + data.cost);
    GameUI.AbilityCosts.costList[data.abilityName] = data.cost;
} GameEvents.Subscribe( "balance_mode_price", setCost);
