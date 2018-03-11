/*
    ability_costs.js
    
    getCost(abilityName)
        Simple getter method for the ability costs.

        abilityName = String. Name of the ability in the key files.
        Returns cost of the ability.
    
    NO_COST exists so that new tiers can be added easily without requiring
    an inspection of the code for places where the current lowest tier is
    assumed to be 0.

    README:
    
    ADDING NEW TIERS:
    
    To add a new tier, you will have to change code to both this file, the
    game_setup.xml file, and constants.lua file. Here's the necessary
    changes for each file:

    ability_costs.js:
    1)  Set TIER_COUNT to the new amount of tiers.
    2)  Add a new "COST_TIER_X" constant in the Tier cost constants
        section.
    3)  Then, find the "GameUI.AbilityCosts.TIER" array and add the
        new constant before the NO_COST index (at the end).

    game_setup.xml:
    1)  Add another ToggleButton below the rest of the toggles for
        the filters.
    2)  Set its text to "#balance_mode_tier_x" where 'x' is the tier.
        You will need to create the localization texts, too.
    3)  Set the onactivate function to "toggleShowTier('x')" where
        'x' is the new tier.

    constants.lua:
    1)  Find the Constants.TIER array. Add in the new cost value
        where it needs to be.
*/

var BALANCE_MODE_POINTS = 120;

// Tier cost constants:

var TIER_COUNT = 12;

var COST_TIER_ONE    = 120;
var COST_TIER_TWO    = 100;
var COST_TIER_THREE  = 90;
var COST_TIER_FOUR   = 80;
var COST_TIER_FIVE   = 70;
var COST_TIER_SIX    = 60;
var COST_TIER_SEVEN  = 50;
var COST_TIER_EIGHT  = 40;
var COST_TIER_NINE   = 30;
var COST_TIER_TEN    = 20;
var COST_TIER_ELEVEN = 10;
var COST_TIER_TWELVE = 0;
var NO_COST = 0;

// Globals for accessing costs outside of this file:

GameUI.AbilityCosts = GameUI.AbilityCosts || {};
GameUI.AbilityCosts.balanceModeEnabled = false;
GameUI.AbilityCosts.costList = [];
GameUI.AbilityCosts.BALANCE_MODE_POINTS = BALANCE_MODE_POINTS;
GameUI.AbilityCosts.TIER_COUNT = TIER_COUNT;
GameUI.AbilityCosts.TIER = [COST_TIER_ONE, COST_TIER_TWO, COST_TIER_THREE, COST_TIER_FOUR, 
                            COST_TIER_FIVE, COST_TIER_SIX, COST_TIER_SEVEN, COST_TIER_EIGHT,
                            COST_TIER_NINE, COST_TIER_TEN, COST_TIER_ELEVEN,COST_TIER_TWELVE, NO_COST];
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
