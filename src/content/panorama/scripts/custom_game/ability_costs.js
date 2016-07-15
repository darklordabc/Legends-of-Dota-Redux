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

var BALANCE_MODE_POINTS = 120;

// Tier cost constants:

var TIER_COUNT = 6;

var COST_TIER_ONE   = 120;
var COST_TIER_TWO   = 80;
var COST_TIER_THREE = 40;
var COST_TIER_FOUR  = 20;
var COST_TIER_FIVE  = 10;
var COST_TIER_SIX   = 0;
var NO_COST = 0;

// Globals for accessing costs outside of this file:

GameUI.AbilityCosts = GameUI.AbilityCosts || {};
GameUI.AbilityCosts.costList = [];
GameUI.AbilityCosts.BALANCE_MODE_POINTS = BALANCE_MODE_POINTS;
GameUI.AbilityCosts.TIER_COUNT = TIER_COUNT;
GameUI.AbilityCosts.TIER = [COST_TIER_ONE, COST_TIER_TWO, COST_TIER_THREE, COST_TIER_FOUR, COST_TIER_FIVE, COST_TIER_SIX, NO_COST];
GameUI.AbilityCosts.NO_COST = NO_COST;

function getCost(abilityName) {
    var cost = GameUI.AbilityCosts.costList[abilityName];
    cost = (cost)? cost: NO_COST;
    return cost;
}
GameUI.AbilityCosts.getCost = getCost;

function setCost(data) {
    GameUI.AbilityCosts.costList[data.abilityName] = data.cost;
} GameEvents.Subscribe( "balance_mode_price", setCost);
