"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var util = GameUI.CustomUIConfig().Util;

var LOCAL_WARNING = false;

// Phases
var PHASE_LOADING = 1;          // Waiting for players, etc
var PHASE_OPTION_VOTING = 2;    // Selection options
var PHASE_OPTION_SELECTION = 3; // Selection options
var PHASE_BANNING = 4;          // Banning stuff
var PHASE_SELECTION = 5;        // Selecting heroes
var PHASE_DRAFTING = 6;         // Place holder for drafting mode
var PHASE_RANDOM_SELECTION = 7; // Random build selection (For All Random)
var PHASE_REVIEW = 8;           // Review Phase
var PHASE_SPAWN_HEROES = 9;     // Random build selection (For All Random)
var PHASE_ITEM_PICKING = 10;    // Game has started
var PHASE_INGAME = 11;          // Game has started

var phases = {
    1: {
        class: 'phase_loading'
    },
    2: {
        name: '#lodStageOptionVoting',
        desc: '',
        class: 'phase_option_voting'
    },
    3: {
        name: '#lodStageOptionSelection',
        desc: '',
        class: 'phase_option_selection'
    },
    4: {
        name: '#lodStageBanning',
        desc: '',
        class: 'phase_banning'
    },
    5: {
        name: '#lodStageSelection',
        desc: '',
        class: 'phase_selection'
    },
    6: {
        class: 'phase_drafting'
    },
    7: {
        name: '#lodStageRandomSelection',
        desc: '',
        class: 'phase_all_random'
    },
    8: {
        name: '#lodStageReview',
        desc: '',
        class: 'phase_review'
    },
    9: {
        name: '#lodStageSpawnHeroes',
        desc: '',
        class: 'phase_spawn_heroes'
    },
    10: {
        name: '#lodStageItemPicking',
        desc: '',
        class: 'phase_item_picking'
    },
    11: {
        name: '#lodStageIngame',
        desc: '',
        class: 'phase_ingame'
    }
};

var parent = $.GetContextPanel().GetParent();
while(parent.id != "Hud")
    parent = parent.GetParent();


// Hero data
var heroData = {};
var abilityHeroOwner = {};

// Ability Data
var flagData = {}
var flagDataInverse = {}

// Used to make data transfer smoother
var dataHooks = {};

// Used to hook when players are clicking around
var onLoadTabHook = {};

// Used to store selected heroes and skills
var selectedHeroes = {};
var selectedAttr = {};
var selectedSkills = {};
var readyState = {};

// Hide enemy picks?
var hideEnemyPicks = false;

// Draft stuff
var heroDraft = null;
var abilityDraft = null;
var boosterDraftInitiated = false;

// The current phase we are in
var currentPhase = PHASE_LOADING;
var selectedPhase = PHASE_OPTION_SELECTION;
var endOfTimer = -1;
var freezeTimer = -1;
var lastTimerShow = -1;
var allowCustomSettings = false;

// Current hero & Skill
var currentSelectedHero = '';
var currentSelectedSkill = '';
var currentSelectedSlot = -1;
var currentSelectedAbCon = null;

// List of all player team panels
//var allPlayerPanels = [];
var activeUnassignedPanels = {};
var activePlayerPanels = {};
var activeReviewPanels = {};

// List of hero panels
var heroPanelMap = {};

// List of option links
var allOptionLinks = {};

// Prevent double option sending
var lastOptionValues = {};

// Map of optionName -> callback for value change
var optionFieldMap = {};

// Map of optionName -> Value
var optionValueList = {};

// Map of categories that are allowed to be picked from
var allowedCategories = {};

// Preload hero panels to avoid precache issues
var preloadedHeroPanels = {};

// Should we show banned / disallowed skills?
var showBannedSkills = false;
var showDisallowedSkills = false;
var showTakenSkills = true;
var showNonDraftSkills = false;
var showPerkRelativeSkills = false;
var useSmartGrouping = true;

// A store for all abilities
var abilityStore = {};

// List of banned abilities
var bannedAbilities = {};
var bannedHeroes = {};
var trollCombos = {};

// List of taken abilities
var takenAbilities = {};
var takenTeamAbilities = {};

// Keeping track of bans
var currentHeroBans = 0;
var currentAbilityBans = 0;

// We have not picked a hero
var pickedAHero = false;

// Help new players to pick hero in time
var restrictedToHeroSelection = false;

// Waiting for preache
var waitingForPrecache = true;

// Are we a premium player?
var isPremiumPlayer = false;
GameUI.CustomUIConfig().isPremiumPlayer = false;

// Save code timer
var saveSCTimer = false;

// Auto Load Switch
var autoloaded = false

// Ability - Perk table
var AbilityPerks = {};

var VotingOptionPanels = {};
var constantBalancePointsValue = GameUI.AbilityCosts.BALANCE_MODE_POINTS;

var AbilityUsageData = {data: {}, entries: {}, global: {}, totalGameAbilitiesCount: 1};

// Used to calculate filters (stub function)
var calculateFilters = function(){};
var calculateHeroFilters = function(){};
var calculateBuildsFilters = function(){
    var con = $('#recommendedBuildContainerScrollWrapper');
    for (var ci = 0; ci < con.GetChildCount(); ci++) {
        var conTab = con.GetChild(ci);
        for (var i = 0; i < conTab.GetChildCount(); i++) {
            var child = conTab.GetChild(i);
            child.updateSearchFilter(searchText);
        }
    }
};

// Balance Mode
var balanceMode = CustomNetTables.GetTableValue("options", "lodOptionBalanceMode") || false;

var currentBalance = 0;
var showTier = {};
var patreonMutators = PlayerTables.GetAllTableValues("patreonMutators")
var mutator_of_the_day
// Contains current tab name
var currentTab = '';
util.reviewOptions = false;

// Search filters
var tabsSearchFilter = {};

var inBuildSaveMode = false

// Is ingame builder
$.GetContextPanel().isIngameBuilder = false;

var popularityFilterSlider = $('#popularityFilterSlider');
var popularityFilterDropDown = $('#popularityFilterDropDown');

(function() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (playerInfo.player_has_host_privileges){
        GameUI.CustomUIConfig().hostID = Players.GetLocalPlayer();
        GameUI.CustomUIConfig().mainHost = Players.GetLocalPlayer();
    }
})();

// Hooks an events and fires for all the keys
function hookAndFire(tableName, callback) {
    // Listen for phase changing information
    CustomNetTables.SubscribeNetTableListener(tableName, callback);

    // Grab the data
    var data = CustomNetTables.GetAllTableValues(tableName);
    for(var i=0; i<data.length; ++i) {
        var info = data[i];
        callback(tableName, info.key, info.value);
    }
}

function isPatron(mutator_name) {
    if (Game.IsInToolsMode()) 
        return true
    
    var patrons = CustomNetTables.GetTableValue("phase_pregame", "patrons");
    var isPatron = false;
    if (patrons) {
        for (var patron in patrons) {
            if (patrons[patron].steamID3 == util.getSteamID32() || patrons[patron].steamID64 == Game.GetPlayerInfo(Game.GetLocalPlayerID()).player_steamid) {
                return true;
                break;
            }
        }
    }

    if (mutator_name == mutator_of_the_day) {
        return true;
    }
    
    return false;
}

function openPatreon() {
    $.DispatchEvent('ExternalBrowserGoToURL', 'https://www.patreon.com/darklordabc');
}

function openDiscord() {
    $.DispatchEvent('ExternalBrowserGoToURL', 'https://discord.gg/ZFSjzWV');
}

// Focuses on nothing
function focusNothing() {
    $('#mainSelectionRoot').SetFocus();
}

// Adds a notification
var notifcationTotal = 0;
function addNotification(options) {
    // Grab useful stuff
    var notificationRoot = $('#lodNotificationArea');
    var notificationID = ++notifcationTotal;

    options = options || {};
    var text = options.text || '';
    var params = options.params || [];
    var sort = options.sort || 'lodInfo';
    var list = options.list;
    var duration = options.duration || 5;

    var realText = $.Localize(text);
    for(var key in params) {
        var toAdd = $.Localize(params[key]);

        realText = realText.replace(new RegExp('\\{' + key + '\\}', 'g'), toAdd);
    }
    if (list) {
        var elements = [];
        for (var k in list.elements) {
            elements.push($.Localize(list.elements[k]));
        }
        realText = realText.replace(/{%list%}/g, elements.join(list.separator));
    }


    // Create the panel
    var notificationPanel = $.CreatePanel('Panel', notificationRoot, 'notification_' + notificationID);
    var textContainer = $.CreatePanel('Label', notificationPanel, 'notification_text_' + notificationID);

    // Push the style and text
    notificationPanel.AddClass('lodNotification');
    notificationPanel.AddClass('lodNotificationLoading');
    notificationPanel.AddClass(sort);
    textContainer.text = realText;

    // Delete it after a bit
    $.Schedule(duration, function() {
        notificationPanel.RemoveClass('lodNotificationLoading');
        notificationPanel.AddClass('lodNotificationRemoving');

        $.Schedule(0.5, function() {
            notificationPanel.DeleteAsync(0);
        });
    });
}

// Hooks a change event
function addInputChangedEvent(panel, callback) {
    var shouldListen = false;
    var checkRate = 0.125;
    var currentString = panel.text;

    var inputChangedLoop = function() {
        // Check for a change
        if(currentString != panel.text) {
            // Update current string
            currentString = panel.text;

            // Run the callback
            callback(panel, currentString);
        }

        if(shouldListen) {
            $.Schedule(checkRate, inputChangedLoop);
        }
    }

    panel.SetPanelEvent('onfocus', function() {
        // Enable listening, and monitor the field
        shouldListen = true;
        inputChangedLoop();
    });

    panel.SetPanelEvent('onblur', function() {
        // No longer listen
        shouldListen = false;
    });
}

function hookSliderChange(panel, callback, onComplete) {
    var shouldListen = false;
    var checkRate = 0.03;
    var currentValue = panel.value;

    var inputChangedLoop = function() {
        // Check for a change
        if(currentValue != panel.value) {
            // Update current string
            currentValue = panel.value;

            // Run the callback
            callback(panel, currentValue);
        }

        if(shouldListen) {
            $.Schedule(checkRate, inputChangedLoop);
        }
    }

    panel.SetPanelEvent('onmouseover', function() {
        // Enable listening, and monitor the field
        shouldListen = true;
        inputChangedLoop();
    });

    panel.SetPanelEvent('onmouseout', function() {
        // No longer listen
        shouldListen = false;

        // Check the value once more
        inputChangedLoop();

        // When we complete
        onComplete(panel, currentValue);
    });
}

// Hooks a tab change
function hookTabChange(tabName, callback) {

    onLoadTabHook[tabName] = callback;
}

// Makes skill info appear when you hover the panel that is parsed in
function hookSkillInfo(panel) {
    // Show
    panel.SetPanelEvent('onmouseover', function() {
        var ability = panel.GetAttributeString('abilityname', 'life_stealer_empty_1');

        // If no ability, give life stealer empty
        if(ability == '') {
            ability = 'life_stealer_empty_1';
        }

        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability);
    });

    // Hide
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip');
        $.DispatchEvent('DOTAHideTitleTextTooltip');
    });
}

function setTabsSearchHandler() {
    // Hook searchbox
    addInputChangedEvent($('#lodSearchInput'), function(panel, newValue) {
        // Store the new text
        searchText = newValue.toLowerCase();

        switch (currentTab) {
            case 'pickingPhaseHeroTab':
                // Update list of abs
                calculateHeroFilters();
                break;
            case 'pickingPhaseSkillTab':
                calculateFilters();
                break;
            case 'pickingPhaseMainTab':
                calculateBuildsFilters();
                break;
        }
    });
}

// Hero data has changed
function OnHeroDataChanged(table_name, key, data) {
    heroData[key] = data;

    for(var i=1; i<=16; ++i) {
        if(data['Ability' + i] != null) {
            abilityHeroOwner[data['Ability' + i]] = key;
        }
    }

    // Do the schedule
    if(dataHooks.OnHeroDataChanged == null) dataHooks.OnHeroDataChanged = 0;
    var myHookNumber = ++dataHooks.OnHeroDataChanged;
    $.Schedule(1, function() {
        if(dataHooks.OnHeroDataChanged == myHookNumber) {
            buildHeroList();
        }
    });
}

// Flag data has changed
function OnFlagDataChanged(table_name, key, data) {
    flagDataInverse[key] = data;
    // Do the schedule
    if(dataHooks.OnFlagDataChanged == null) dataHooks.OnFlagDataChanged = 0;
    var myHookNumber = ++dataHooks.OnFlagDataChanged;
    $.Schedule(1, function() {
        if(dataHooks.OnFlagDataChanged == myHookNumber) {
            buildFlagList();
        }
    });
}

// Selected heroes has changed
var allSelectedHeroes = {};
function OnSelectedHeroesChanged(table_name, key, data) {
    // Grab data
    var playerID = data.playerID;
    var heroName = data.heroName;

    // Store the change
    selectedHeroes[playerID] = heroName;

    // Was it an update on our local player?
    if(playerID == Players.GetLocalPlayer()) {
        // Update our hero icon and text
        var heroCon = $('#pickingPhaseSelectedHeroImage');
        heroCon.SetAttributeString('heroName', heroName);
        heroCon.heroname = heroName;

        $('#pickingPhaseSelectedHeroText').text = $.Localize(heroName);

        // Set it so no hero is selected
        $('#pickingPhaseSelectedHeroImageCon').SetHasClass('no_hero_selected', false);

        // We have now picked a hero
        pickedAHero = true;

        if (showPerkRelativeSkills) {
            calculateFilters();
        }
    }

    // Shows which heroes have been taken
    showTakenHeroes();
    updateHeroPreviewFilters();
    updateRecommendedBuildFilters();

    if(activePlayerPanels[playerID]) {
        activePlayerPanels[playerID].OnGetHeroData(heroName);
    }

    if(activeReviewPanels[playerID]) {
        activeReviewPanels[playerID].OnGetHeroData(heroName);

        if(currentPhase == PHASE_REVIEW) {
            activeReviewPanels[playerID].OnReviewPhaseStart();
        }
    }
}

// Shows which heroes have been taken
function showTakenHeroes() {
    // Calculate which heroes are taken
    allSelectedHeroes = {};
    for(var playerID in selectedHeroes) {
        allSelectedHeroes[selectedHeroes[playerID]] = true;
    }

    // Mark them as taken
    for(var heroName in heroPanelMap) {
        var panel = heroPanelMap[heroName];
        panel.SetHasClass('takenHero', allSelectedHeroes[heroName] != null);
    }
}

// Selected primary attribute changes
function OnSelectedAttrChanged(table_name, key, data) {
    // Grab data
    var playerID = data.playerID;
    var newAttr = data.newAttr;

    // Store the change
    selectedAttr[playerID] = newAttr;

    // Was it an update on our local player?
    if(playerID == Players.GetLocalPlayer()) {
        // Update which attribute is selected
        $('#pickingPhaseSelectHeroStr').SetHasClass('selectedAttribute', newAttr == 'str');
        $('#pickingPhaseSelectHeroAgi').SetHasClass('selectedAttribute', newAttr == 'agi');
        $('#pickingPhaseSelectHeroInt').SetHasClass('selectedAttribute', newAttr == 'int');
    }

    // Push the attribute
    if(activePlayerPanels[playerID]) {
        activePlayerPanels[playerID].OnGetNewAttribute(newAttr);
    }

    if(activeReviewPanels[playerID]) {
        activeReviewPanels[playerID].OnGetNewAttribute(newAttr);
    }
}

// Selected abilities has changed
function OnSelectedSkillsChanged(table_name, key, data) {
    var playerID = data.playerID;

    // Store the change
    selectedSkills[playerID] = data.skills;

    // Grab max slots
    var maxSlots = optionValueList['lodOptionCommonMaxSlots'] || 6;
    var defaultSkill = 'life_stealer_empty_1';

    if(playerID == Players.GetLocalPlayer()) {
        for(var i=1; i<=maxSlots; ++i) {
            // Default to no skills
            if(!selectedSkills[playerID][i]) {
                var ab = $('#lodYourAbility' + i);
                ab.abilityname = defaultSkill;
                ab.SetAttributeString('abilityname', defaultSkill);
                hookSkillInfo(ab);

                var abCost = ab.GetChild(0);

                if (balanceMode) {
                    // Clear the labels
                    if (abCost) {
                        for (var j = 0; j < GameUI.AbilityCosts.TIER_COUNT; ++j) {
                            abCost.SetHasClass('tier' + (j+1), false);
                        }
                        abCost.text = "";
                    }
                }

                if (typeof($.GetContextPanel().balanceMode) == "boolean") {
                    if (abCost) {
                        abCost.visible = $.GetContextPanel().balanceMode;
                    }
                }
            }
        }
        var balance = constantBalancePointsValue;
        var tickedAbilitiesCount = 0;
        var activeAbilities = 0;

        var threshold = optionValueList.lodOptionNewAbilitiesThreshold || 20;
        var fetchedAbilityData = AbilityUsageData.data;
        var realAbilitiesThreshold = Math.ceil(AbilityUsageData.totalGameAbilitiesCount * (1 - threshold * 0.01));
        var enableAlternativeThreshold = Object.keys(AbilityUsageData.entries).length >= realAbilitiesThreshold;

        var isBelowThreshold = enableAlternativeThreshold ? (function(ability) {
            var rarity = AbilityUsageData.entries[ability] == null ? 1 : AbilityUsageData.entries[ability];
            return rarity > 1 - threshold * 0.01;
        }) : (function(ability) {
            return AbilityUsageData.entries[ability] == null;
        });

        var globalThreshold = optionValueList.lodOptionGlobalNewAbilitiesThreshold || 75;
        var isGlobalBelowThreshold = (function(ability) {
            return getAbilityGlobalPickPopularity(ability) > 1 - globalThreshold * 0.01;
        });

        for (var i = 1; i <= 6; i++) {
            $('#newAbilitiesTick' + i).RemoveClass('OwnBonus');
            $('#newAbilitiesTick' + i).RemoveClass('GlobalBonus');
        }

        for(var key in selectedSkills[playerID]) {
            var ab = $('#lodYourAbility' + key);
            var abName = selectedSkills[playerID][key];
            var isNewAbility = false;
            var isGlobalNewAbility = false;

            if(ab != null) {
                ab.abilityname = abName;
                ab.SetAttributeString('abilityname', abName);
                hookSkillInfo(ab);

                var abCost = ab.GetChild(0);

                if (isBelowThreshold(abName)) {
                    isNewAbility = true;
                    tickedAbilitiesCount++;
                } else if (isGlobalBelowThreshold(abName)) {
                    isGlobalNewAbility = true;
                    tickedAbilitiesCount++;
                }

                if (balanceMode) {
                    // Set the label to the cost of the ability
                    var filterInfo = getSkillFilterInfo(abName);

                    if (abCost) {
                        for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
                            abCost.SetHasClass('tier' + (i + 1), filterInfo.cost == GameUI.AbilityCosts.TIER[i]);
                        }
                        abCost.text = (filterInfo.cost != GameUI.AbilityCosts.NO_COST)? filterInfo.cost: "";
                        balance -= filterInfo.cost;
                    }
                }

                if (typeof($.GetContextPanel().balanceMode) == "boolean") {
                    if (abCost) {
                        abCost.visible = $.GetContextPanel().balanceMode;
                    }
                }
                if (!flagDataInverse[abName] || !flagDataInverse[abName].passive) {
                    activeAbilities++;
                }
            }

            $('#newAbilitiesTick' + key).SetHasClass('OwnBonus', isNewAbility);
            if (!isNewAbility && isGlobalNewAbility) {
                $('#newAbilitiesTick' + key).AddClass('GlobalBonus');
            }
        }
        $('#newAbilitiesPanel').SetHasClass('OneOrMore', tickedAbilitiesCount > 0);
        $('#balancedBuildTick').AddClass('Enabled'); // Forces panorama to update this panel. Without this panorama for some reason not updates #newAbilitiesPanel.
        $('#balancedBuildTick').SetHasClass('Enabled', activeAbilities >= 3);


        // Update current price
        currentBalance = balance;
        if (balanceMode) {
            $('#balanceModePointsPreset').SetDialogVariableInt( 'points', currentBalance );
            $('#balanceModePointsHeroes').SetDialogVariableInt( 'points', currentBalance );
            $('#balanceModePointsSkills').SetDialogVariableInt( 'points', currentBalance );
        }
    }

    // Push the build
    if(activePlayerPanels[playerID]) {
        activePlayerPanels[playerID].OnGetHeroBuildData(data.skills);
    }

    if(activeReviewPanels[playerID]) {
        activeReviewPanels[playerID].OnGetHeroBuildData(data.skills);
    }

    // Update which skills are taken
    updateTakenSkills();
}

// Updates which skills have been taken
function updateTakenSkills() {
    var myTeam = (Game.GetPlayerInfo(Players.GetLocalPlayer()) || {}).player_team_id || -1;

    // Reset taken skills
    takenTeamAbilities = {};
    takenAbilities = {};

    // Loop over each build
    for(var playerID in selectedSkills) {
        var build = selectedSkills[playerID];

        var theTeam = (Game.GetPlayerInfo(parseInt(playerID)) || {}).player_team_id || -1;

        for(var slotID in build) {
            var abilityName = build[slotID];

            // This ability is taken
            takenAbilities[abilityName] = true;

            if(myTeam == theTeam) {
                takenTeamAbilities[abilityName] = true;
            }
        }
    }

    // Rebuild the visible skills
    if (currentTab == "pickingPhaseMainTab") {
        updateRecommendedBuildFilters();
    } else if (currentTab == "pickingPhaseSkillTab") {
        calculateFilters();
    } else {
        updateHeroPreviewFilters();
    }
}

// A ban was sent through
function OnSkillBanned(table_name, key, data) {
    var heroName = data.heroName;
    var abilityName = data.abilityName;
    var playerInfo = data.playerInfo;

    if(heroName != null) {
        // Store the ban
        bannedHeroes[heroName] = true;

        // setSelectedHelperHero(currentSelectedHero, true);

        // Recalculate filters
        calculateHeroFilters();
        updateHeroPreviewFilters();
        updateRecommendedBuildFilters();
    }

    if(abilityName != null) {
        // Store the ban
        bannedAbilities[abilityName] = true;

        // Recalculate filters
        calculateFilters();
        updateHeroPreviewFilters();
        updateRecommendedBuildFilters();
    }

    if(data.playerID != null) {
        // Someone's ban info
        if(data.playerID == Players.GetLocalPlayer()) {
            // Our banning info

            // Store new values
            currentHeroBans = data.currentHeroBans;
            currentAbilityBans = data.currentAbilityBans;

            // Recalculate
            recalculateBanLimits();
        }
    }
}

// Server just sent the ready state
function OnGetReadyState(table_name, key, data) {
    // Store it
    readyState = data;

    // Process it
    for(var playerID in data) {
        var panel = activePlayerPanels[playerID];
        if(panel) {
            panel.setReadyState(data[playerID])
        }

        var panel = activeReviewPanels[playerID];
        if(panel) {
            panel.setReadyState(data[playerID])
        }

        // Is it our local player?
        if(playerID == Players.GetLocalPlayer()) {
            $('#heroBuilderLockButton').SetHasClass('makeThePlayerNoticeThisButton', data[playerID] == 0);
            $('#heroBuilderLockButtonBans').SetHasClass('makeThePlayerNoticeThisButton', data[playerID] == 0);
            $('#heroBuilderLockButtonBans').SetHasClass('hideThisButton', data[playerID] == 1);

            $('#bansImportAndExportSaveButton').visible = data[playerID] == 0;
            $('#bansImportAndExportLoadButton').visible = data[playerID] == 0;

            $('#allRandomLockButton').visible = data[playerID] == 0;
            $('#reviewReadyButton').visible = data[playerID] == 0;
        }
    }
}

// Server just sent us random build data
var allRandomBuildContainers = {};
var allRandomSelectedBuilds = {
    hero: 0,
    build: 0
};
function OnGetRandomBuilds(table_name, key, data) {
    if(data.selected != null) {
        OnSelectedRandomBuildChanged(table_name, key, data);
        return;
    }

    // See who's data we just got
    var playerID = data.playerID;
    if(playerID == Players.GetLocalPlayer()) {
        // It's our data!
        var builds = data.builds;

        // ASSUMPTION: This event will only fire ONCE!

        var con = $('#allRandomBuildsContainer');

        for(var buildID in builds) {
            var theBuild = builds[buildID];

            // Create the container
            var buildCon = $.CreatePanel('Panel', con, 'allRandomBuild' + buildID);
            buildCon.BLoadLayout('file://{resources}/layout/custom_game/all_random_build.xml', false, false);
            buildCon.setBuild(buildID, theBuild.heroName, theBuild.build);
            buildCon.hook(hookSkillInfo);

            allRandomBuildContainers[buildID] = buildCon;
        }

        updateAllRandomHighlights();
    }
}

// The build we selected changed
function OnSelectedRandomBuildChanged(table_name, key, data) {
    // See who's data we just got
    var playerID = data.playerID;

    if(playerID == Players.GetLocalPlayer()) {
        allRandomSelectedBuilds.hero = data.hero;
        allRandomSelectedBuilds.build = data.build;
        updateAllRandomHighlights();
    }
}

// Server just sent us a draft array
function OnGetDraftArray(table_name, key, data) {
    if (key.match("booster") != null && Players.GetLocalPlayer() == parseInt(key.replace(key.match("booster"), ""))) {
        var con = $("#boosterDraftPile")
        if (data.draftArray) {
            $("#boosterDraftPileDragLabel").visible = false;
            for (var abName in data.draftArray) {
                if (data.draftArray[abName]) {
                    if (!con.FindChildTraverse("pile_" + abName)) {
                        var rootCon = $.CreatePanel('Panel', con, "pileRootCon_" + abName);
                        var abcon = $.CreatePanel('DOTAAbilityImage', rootCon, "pile_" + abName);
                        abcon.abilityname = abName;                        abcon.abilityname = abName;
                        abcon.SetAttributeString('abilityname', abName);
                        hookSkillInfo(abcon);
                    }
                }
            }

            if (Object.keys(data.draftArray).length == 10) {
                $("#boosterDraftBoosters").visible = false;
            } else {
                for (var i = 0; i < Object.keys(data.draftArray).length; i++) {
                    try {
                        if (boosterDraftInitiated) {
                            $("#boosterDraftBoosters").Children()[9-i].DeleteAsync(0.0);
                            $("#boosterDraftBoosters").Children()[8-i].SetHasClass("current", true);
                        }
                    } catch (err) {}
                }
            }

            $("#tabsSelector").visible = true;
        }
    } else {
        var draftID = data.draftID;

        var myDraftID = 0;

        var playerID = Players.GetLocalPlayer();
        var myInfo = Game.GetPlayerInfo(playerID);
        var myTeamID = myInfo.player_team_id;
        var myTeamPlayers = Game.GetPlayerIDsOnTeam(myTeamID);

        var maxPlayers = 24;
        for(var i=0; i<maxPlayers; ++i) {
            if(i == playerID) break;

            var info = Game.GetPlayerInfo(i);

            if(info != null && myTeamID == info.player_team_id) {
                ++myDraftID;
            }
        }

        // Ensure we don't get a weird value for draftID
        myDraftID = myDraftID % 5;

        // Are we playing single draft or booster draft?
        if(optionValueList['lodOptionCommonGamemode'] == 5 || optionValueList['lodOptionCommonGamemode'] == 6) {
            // DraftID is just our playerID
            myDraftID = playerID;
        }

        // Is this data for us?
        if(myDraftID != draftID) return;

        // Init booster draft
        if (isBoosterDraftGamemode()) {
            showBuilderTab('pickingPhaseSkillTab');

            if (!boosterDraftInitiated && !data.boosterDraftDone) {
                $("#boosterDraftPile").visible = true;
                $("#pickingPhaseBuild").visible = false;

                $("#boosterDraftBoosters").visible = true;
                for (var i = 0; i < 10; i++) {
                    var newBooster = $.CreatePanel("Panel", $("#boosterDraftBoosters"), "booster"+(i+1))
                    newBooster.BLoadLayoutSnippet("BoosterPack");
                }

                $("#boosterDraftBoosters").Children()[$("#boosterDraftBoosters").Children().length-1].SetHasClass("current", true);

                var boosters = $("#boosterDraftBoosters").Children();
                var players = 0;
                for (var i = 0; i < 23; i++) {
                    var info = Game.GetPlayerInfo(i);
                    if (info) {
                        players++;
                    }
                }

                var i = 0;
                for (var k in boosters) {
                    boosters[k].FindChildTraverse("booster").style.hueRotation = Math.floor(((360/players) * i)) + "deg;";
                    i++;
                }

                var hookSet = function(setName) {
                    var enterNumber = 0;
                    var draftingArea = $('#boosterDraftPile');

                    var draftingDragEnter = function(panelID, draggedPanel) {
                        draftingArea.AddClass('potential_drop_target');

                        draggedPanel.SetAttributeInt("draftThis", 1);

                        // Prevent annoyingness
                        ++enterNumber;
                    };

                    var draftingDragLeave = function(panelID, draggedPanel) {
                        var myNumber = ++enterNumber;

                        $.Schedule(0.1, function() {
                            // draggedPanel.SetAttributeInt("draftThis", 0);
                            if(myNumber == enterNumber) {
                                draftingArea.RemoveClass('potential_drop_target');

                                if(draggedPanel.deleted == null) {
                                    draggedPanel.SetAttributeInt("draftThis", 0);
                                }
                            }
                        });
                    };

                    draftingArea.SetPanelEvent("onactivate", function () {
                        if (currentSelectedAbCon) {
                            var abName = currentSelectedAbCon.GetAttributeString('abilityname', '');
                            selectBoosterDraftAbility(abName);
                        }
                    })

                    $.RegisterEventHandler('DragEnter', $(setName), draftingDragEnter);
                    $.RegisterEventHandler('DragLeave', $(setName), draftingDragLeave);
                    // $.RegisterEventHandler('DragEnd', $(setName), draftingDragEnd);

                    boosterDraftInitiated = true;
                };

                hookSet('#boosterDraftPile');

                // $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', $('#boosterDraftBoosters'), "BoosterDraftTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize("boosterDraftTip1"));
                // $.Schedule(3.0, function () {
                //     $.DispatchEvent( 'UIHideCustomLayoutTooltip', $('#boosterDraftBoosters'), "BoosterDraftTooltip");
                // });

                $("#pickingPhaseMainTabRoot").enabled = false;
                $("#pickingPhaseHeroTabRoot").enabled = false;

                $.Schedule(0.5, function () {
                    showBuilderTab('pickingPhaseSkillTab');
                    $("#pickingPhaseSkillTabContent").visible = true;
                })
            } else if (data.boosterDraftDone) {
                $("#boosterDraftBoosters").visible = false;
                $("#boosterDraftPile").visible = false;
                $("#pickingPhaseBuild").visible = true;

                $("#pickingPhaseHeroTabRoot").enabled = true;

                $.Schedule(0.5, function () {
                    showBuilderTab('pickingPhaseSkillTab');
                    $("#pickingPhaseSkillTabContent").visible = true;
                })
            }
        }

        var draftArray = data.draftArray;
        heroDraft = draftArray.heroDraft;
        abilityDraft = draftArray.abilityDraft;

        var showAbilities = (function () {
            if (Object.keys(abilityStore).length < 1) {
                $.Schedule(0.1, showAbilities)
                return;
            }

            Game.EmitSound("BoosterDraft.Round");

            for (var g in abilityStore) {
                abilityStore[g].SetHasClass("hide", true);
            }

            var i = 0.0;
            var delay = 0.01;
            for (var g in abilityStore) {
                (function () {
                    var p = abilityStore[g];
                    $.Schedule(i, function () {
                        p.SetHasClass("hide", !abilityDraft[p.abilityname]);
                    });
                    if (abilityDraft[p.abilityname]) {
                        i = i + delay;
                    }
                })();
            }
        });
        showAbilities();

        $("#pickingPhaseSkillTabContent").visible = true;

        if (useSmartGrouping) {
            toggleHeroGrouping();
            $('#buttonHeroGrouping').checked = false;
        }

        // Run the calculations
        calculateFilters();
        calculateHeroFilters();
        updateHeroPreviewFilters();
        updateRecommendedBuildFilters();

        // Show the button to show non-draft abilities
        $('#toggleShowDraftAblilities').visible = true;
    }
}

function selectBoosterDraftAbility(abName) {
    if(abName != null && abName.length > 0 && abilityDraft[abName]) {
        chooseNewAbility(-1, abName);
        Game.EmitSound("BoosterDraft.Pick");

        $("#boosterDraftPile").SetHasClass('lodSelectedDrop', false);
    }
}

// Update the highlights
function updateAllRandomHighlights() {
    for(var buildID in allRandomBuildContainers) {
        var con = allRandomBuildContainers[buildID];
        con.setSelected(buildID == allRandomSelectedBuilds.hero, buildID == allRandomSelectedBuilds.build);
    }
}

// When the lock build button is pressed
function onLockBuildButtonPressed() {
    $('#heroBuilderLockButton').SetHasClass('pressed', !$('#heroBuilderLockButton').BHasClass('pressed'));

    // Tell the server we clicked it
    GameEvents.SendCustomGameEventToServer('lodReady', {});
}

function onBacktrackButton() {
    util.reviewOptions = !util.reviewOptions;

    fixBacktrackUI();
}

function fixBacktrackUI() {
    var masterRoot = $.GetContextPanel();
    if (masterRoot != null) {
        masterRoot.SetHasClass('phase_option_selection_selected', selectedPhase == PHASE_OPTION_SELECTION || util.reviewOptions);
        masterRoot.SetHasClass('review_selection', util.reviewOptions);
        masterRoot.SetHasClass('phase_selection_selected', (selectedPhase == PHASE_SELECTION || selectedPhase == PHASE_INGAME) && !util.reviewOptions);

        $('#backtrackBtnTxt').text = $.Localize((util.reviewOptions)? 'reviewReturn': 'reviewOptions');
    }
}

// Sets up the hero builder tab
function setupBuilderTabs() {
    var mainPanel = $('#tabsSelector');
    $.Each(mainPanel.Children(), function(tabElement) {
        var tabLink = tabElement.GetAttributeString('link', '-1');

        if(tabLink != '-1') {
            tabElement.SetPanelEvent('onactivate', function() {
                showBuilderTab(tabLink);

                // No skills selected anymore
                if (currentPhase != PHASE_BANNING) {
                    setSelectedDropAbility();
                }

                // Deselect any hero
                if (currentPhase != PHASE_BANNING) {
                    setSelectedHelperHero();
                }

                // Focus to nothing
                focusNothing();
            });
        }
    });

    var mainContentPanel = $('#pickingPhaseTabsContent');
    $.Each(mainContentPanel.Children(), function(panelTab) {
        if(panelTab.BHasClass('pickingPhaseTabContent')) {
            panelTab.visible = false;
        }
    });

    if (currentPhase == PHASE_SELECTION) {
        showBuilderTab("pickingPhaseMainTab");
    }

    // Show the main tab only
    // #warning
    // showBuilderTab('pickingPhaseSkillsTab');

    // Default to no selected preview hero
    setSelectedHelperHero();

    for(var i=1;i<=6; ++i) {
        (function(con, slotID) {
            // Hook abilitys that should show info
            hookSkillInfo(con);

            con.SetDraggable(true);

            // Allow for dropping
            $.RegisterEventHandler('DragEnter', con, function(panelID, draggedPanel) {
                // Are we dragging an ability?
                if(draggedPanel.GetAttributeString('abilityname', '') != '') {
                    con.AddClass('potential_drop_target');
                    draggedPanel.SetAttributeInt('activeSlot', slotID);
                }
            });

            $.RegisterEventHandler('DragLeave', con, function(panelID, draggedPanel) {
                $.Schedule(0.01, function() {
                    con.RemoveClass('potential_drop_target');

                    if(draggedPanel.deleted == null && draggedPanel.GetAttributeInt('activeSlot', -1) == slotID) {
                        draggedPanel.SetAttributeInt('activeSlot', -1);
                    }
                });
            });

            // TODO: Allow for slot swapping
            $.RegisterEventHandler('DragStart', con, function(panelID, dragCallbacks) {
                var abName = con.GetAttributeString('abilityname', '');

                if(abName == null || abName.length <= 0) return false;

                //setSelectedDropAbility(abName, con);

                // Create a temp image to drag around
                var displayPanel = $.CreatePanel('DOTAAbilityImage', $.GetContextPanel(), 'dragImage');
                displayPanel.abilityname = abName;
                dragCallbacks.displayPanel = displayPanel;
                dragCallbacks.offsetX = 0;
                dragCallbacks.offsetY = 0;
                displayPanel.SetAttributeString('abilityname', abName);

                // Select this slot
                currentSelectedSlot = slotID;

                // Do the highlight
                highlightDropSlots();

                // Hide skill info
                $.DispatchEvent('DOTAHideAbilityTooltip');
                $.DispatchEvent('DOTAHideTitleTextTooltip');
            });

            $.RegisterEventHandler('DragEnd', con, function(panelId, draggedPanel) {
                // Delete the draggable panel
                draggedPanel.deleted = true;
                draggedPanel.DeleteAsync(0.0);

                var dropSlot = draggedPanel.GetAttributeInt('activeSlot', -1);
                if(dropSlot != -1 && dropSlot != slotID) {
                    swapSlots(dropSlot, slotID);
                } else if (dropSlot == -1) {
                    removeAbility(slotID);
                }

                // Highlight nothing
                setSelectedDropAbility();
            });
        })($('#lodYourAbility' + i), i);
    }

    for(var i=1;i<=16; ++i) {
        var abCon = $('#buildingHelperHeroPreviewSkill' + i);
        hookSkillInfo(abCon);
        makeSkillSelectable(abCon);
        var label = $.CreatePanel('Label', abCon, 'buildingHelperSkillTabCost' + i);
        label.SetHasClass('skillCostLarge', true);
    }

    // Hook drag and drop stuff for heroes
    var heroDragEnter = function(panelID, draggedPanel) {
        // Are we dragging an ability?
        if(draggedPanel.GetAttributeString('heroName', '') != '') {
            heroDropCon.AddClass('potential_drop_target');
            heroDropConBlank.AddClass('potential_drop_target');
            draggedPanel.SetAttributeInt('canSelectHero', 1);
        }
    };

    var heroDragLeave = function(panelID, draggedPanel) {
        $.Schedule(0.1, function() {
            heroDropCon.RemoveClass('potential_drop_target');
            heroDropConBlank.RemoveClass('potential_drop_target');

            if(draggedPanel.deleted == null) {
                draggedPanel.SetAttributeInt('canSelectHero', 0);
            }
        });
    };

    var heroDropCon = $('#pickingPhaseSelectedHeroImage');
    $.RegisterEventHandler('DragEnter', heroDropCon, heroDragEnter);
    $.RegisterEventHandler('DragLeave', heroDropCon, heroDragLeave);

    // Display info about the hero on hover
    hookHeroInfo(heroDropCon);

    var heroDropConBlank = $('#pickingPhaseSelectedHeroImageNone');
    $.RegisterEventHandler('DragEnter', heroDropConBlank, heroDragEnter);
    $.RegisterEventHandler('DragLeave', heroDropConBlank, heroDragLeave);

    $('#pickingPhaseSelectedHeroImageCon').SetPanelEvent("onactivate", function () {
        onYourHeroRandomed();
    })

    $('#pickingPhaseSelectedHeroImageCon').SetPanelEvent("oncontextmenu", function () {
        onYourHeroRandomed();
    })

    $('#pickingPhaseSelectedHeroText').hittest = false;

    // Hook banning
    //var theSet = '';
    var hookSet = function(setName) {
        var enterNumber = 0;
        var banningArea = $('#pickingPhaseBans');

        var banningDragEnter = function(panelID, draggedPanel) {
            banningArea.AddClass('potential_drop_target');
            draggedPanel.SetAttributeInt('banThis', 1);

            // Prevent annoyingness
            ++enterNumber;
        };

        var banningDragLeave = function(panelID, draggedPanel) {
            var myNumber = ++enterNumber;

            $.Schedule(0.1, function() {
                if(myNumber == enterNumber) {
                    banningArea.RemoveClass('potential_drop_target');

                    if(draggedPanel.deleted == null) {
                        draggedPanel.SetAttributeInt('banThis', 0);
                    }
                }
            });
        };

        $.RegisterEventHandler('DragEnter', $(setName), banningDragEnter);
        $.RegisterEventHandler('DragLeave', $(setName), banningDragLeave);
    };

    hookSet('#pickingPhaseBans');
}

// Builds the hero list
function buildHeroList() {
    Game.SetTeamSelectionLocked(false);
    var strHeroes = [];
    var agiHeroes = [];
    var intHeroes = [];

    for(var heroName in heroData) {
        var info = heroData[heroName];

        if (info.Enabled == 1) {
            switch(info.AttributePrimary) {
                case 'DOTA_ATTRIBUTE_STRENGTH':
                    strHeroes.push(heroName);
                break;

                case 'DOTA_ATTRIBUTE_AGILITY':
                    agiHeroes.push(heroName);
                break;

                case 'DOTA_ATTRIBUTE_INTELLECT':
                    intHeroes.push(heroName);
                break;
            }
        }

    // QUICKER DEBUGGING CHANGE
    if (Game.IsInToolsMode() && autoloaded == false) {
        autoloaded = true
        Game.SetTeamSelectionLocked(true);
        LoadOptions()
    }

    }

    function doInsertHeroes(container, heroList) {
        // Sort the hero list
        heroList.sort();

        // Insert it
        for(var i=0; i<heroList.length; ++i) {
            (function() {
                var heroName = heroList[i];

                // Create the panel
                var newPanel = $.CreatePanel('Panel', container, 'heroSelector_' + heroName);
                newPanel.BLoadLayout('file://{resources}/layout/custom_game/game_setup/game_setup_hero.xml', false, false);
                // Make the hero selectable
                makeHeroSelectable(newPanel);

                newPanel.setHeroName(heroName, generateFormattedHeroStatsString, heroData[heroName]);

                /*newPanel.SetAttributeString('heroName', heroName);
                newPanel.heroname = heroName;
                newPanel.heroimagestyle = 'portrait';*/

                /*newPanel.SetPanelEvent('onactivate', function() {
                    // Set the selected helper hero
                    setSelectedHelperHero(heroName);
                });*/

                // Store it
                heroPanelMap[heroName] = newPanel;
            })();
        }
    }

    // Reset the hero map
    heroPanelMap = {};

    // Insert heroes
    doInsertHeroes($('#strHeroContainer'), strHeroes);
    doInsertHeroes($('#agiHeroContainer'), agiHeroes);
    doInsertHeroes($('#intHeroContainer'), intHeroes);

    // Update which heroes are taken
    showTakenHeroes();
    updateHeroPreviewFilters();
    updateRecommendedBuildFilters();
}

// Build the flags list
function buildFlagList() {
    flagData = {};

    for(var abilityName in flagDataInverse) {
        var flags = flagDataInverse[abilityName];

        for(var flag in flags) {
            if(flagData[flag] == null) flagData[flag] = {};

            flagData[flag][abilityName] = flags[flag];
        }
    }
}

function setSelectedHelperHero(heroName, dontUnselect) {
    var previewCon = $('#buildingHelperHeroPreview');

    if (currentPhase == PHASE_BANNING) {
        $( "#balanceModePointsPreset" ).SetHasClass("balanceModeDisabled", true);
        $( "#balanceModePointsHeroes" ).SetHasClass("balanceModeDisabled", true);
    }

    // Validate hero name
    if(heroName == null || heroName.length <= 0 || !heroData[heroName]) {
        $('#banningHeroContainer').SetHasClass('disableButton', true);
        previewCon.visible = false;
        return;
    } else {
        $('#banningHeroContainer').SetHasClass('disableButton', false);
    }

    $('#banningHeroContainer').SetHasClass('disableButton', bannedHeroes[heroName] == true); //bannedHeroes[heroName] == true

    // Set this as the selected one
    currentSelectedHero = heroName;

    // Show the preview
    previewCon.visible = true;
    $('#buildingHelperHeroPreviewHero').heroname = heroName;
    $('#buildingHelperHeroPreviewHeroName').text = $.Localize(heroName);

    // Grab the info
    var info = heroData[heroName];

    for(var i=1; i<=16; ++i) {
        var abName = info['Ability' + i];
        var abCon = $('#buildingHelperHeroPreviewSkill' + i);

        // Ensure it is a valid ability, and we have flag data about it
        if(abName != null && abName != '' && flagDataInverse[abName]) {
            abCon.visible = true;
            abCon.abilityname = abName;
            abCon.SetAttributeString('abilityname', abName);
        } else {
            abCon.visible = false;
        }

        hookSkillInfo(abCon);
    }

    // Highlight drop slots correctly
    if(!dontUnselect) {
        // No abilities selected anymore
        setSelectedDropAbility();
    }

    // Update the filters for this hero
    updateHeroPreviewFilters();

    if (currentPhase == PHASE_BANNING) {
        // Update the banning skill icon
        $('#lodBanThisHero').heroname = heroName;
        $('#banningAbilityContainer').SetHasClass('disableButton', true);

        $('#buildingHelperHeroPreviewHeroSelect').SetHasClass('disableButton', true);

        $('#balanceModePointsHeroes').visible = false;
    }
    else {
        $('#buildingHelperHeroPreviewHeroSelect').SetHasClass('disableButton', false);

        $('#balanceModePointsHeroes').visible = true;

        // Jump to the right tab
        // showBuilderTab('pickingPhaseHeroTab');
    }
}

// They try to set a new hero
function onNewHeroSelected() {
    // Push data to the server
    chooseHero(currentSelectedHero);

    // Unselect selected skill
    setSelectedDropAbility();
}

// They try to ban a hero
function onHeroBanButtonPressed() {
    banHero(currentSelectedHero);
}

// They tried to set a new primary attribute
function setPrimaryAttr(newAttr) {
    choosePrimaryAttr(newAttr);
}

// Highlights slots for dropping
function highlightDropSlots() {
    // If no slot selected, default slots
    if(currentSelectedSlot == -1) {
        for(var i=1; i<=6; ++i) {
            var ab = $('#lodYourAbility' + i);

            ab.SetHasClass('lodSelected', false);
            ab.SetHasClass('lodSelectedDrop', false);
        }
    } else {
        for(var i=1; i<=6; ++i) {
            var ab = $('#lodYourAbility' + i);

            if(currentSelectedSlot == i) {
                ab.SetHasClass('lodSelected', true);
                ab.SetHasClass('lodSelectedDrop', false);
            } else {
                ab.SetHasClass('lodSelected', false);
                ab.SetHasClass('lodSelectedDrop', true);
            }
        }
    }

    // If no skill is selected, highlight nothing
    if(currentSelectedSkill == '') return;

    // Count the number of ultimate abiltiies
    var theCount = 0;
    var theMax = optionValueList['lodOptionCommonMaxUlts'];
    var isUlt = isUltimateAbility(currentSelectedSkill);
    var playerID = Players.GetLocalPlayer();
    if(!isUlt) {
        theMax = optionValueList['lodOptionCommonMaxSkills'];
    }
    var alreadyHas = false;

    // Check our build
    var ourBuild = selectedSkills[playerID] || {};

    for(var slotID in ourBuild) {
        var abilityName = selectedSkills[playerID][slotID];

        if(isUltimateAbility(abilityName) == isUlt) {
            ++theCount;
        }

        if(currentSelectedSkill == abilityName) {
            alreadyHas = true;
        }
    }

    var easyAdd = theCount < theMax;

    // Decide which slots can be dropped into
    for(var i=1; i<=6; ++i) {
        var ab = $('#lodYourAbility' + i);

        // Do we already have this ability?
        if(alreadyHas) {
            ab.SetHasClass('lodSelectedDrop', currentSelectedSkill == ourBuild[i]);
        } else {
            ab.SetHasClass('lodSelectedDrop', (easyAdd || (ourBuild[i] != null && isUlt == isUltimateAbility(ourBuild[i]))));
        }
    }

    if (isBoosterDraftGamemode()) {
        $("#boosterDraftPile").SetHasClass('lodSelectedDrop', true);
    }
}

// Decides if the given ability is an ult or not
function isUltimateAbility(abilityName) {
    return (flagDataInverse[abilityName] || {}).isUlt != null;
}

// Sets the currently selected ability for dropping
function setSelectedDropAbility(abName, abcon) {
    if (currentPhase == PHASE_BANNING && abName) {
        $('#banningHeroContainer').SetHasClass('disableButton', true);
    }

    abName = abName || '';

    // Was there a slot selected?
    if(currentSelectedSlot != -1) {
        var theSlot = currentSelectedSlot;
        currentSelectedSlot = -1;

        if(abName.length > 0) {
            chooseNewAbility(theSlot, abName);
        }
        highlightDropSlots();
        return;
    }


    // Remove the highlight from the old ability icon
    if(currentSelectedAbCon != null) {
        currentSelectedAbCon.SetHasClass('lodSelected', false);
        currentSelectedAbCon = null;
    }

    if(currentSelectedSkill == abName || abName == '') {
        // Nothing selected
        currentSelectedSkill = '';

        // Update the banning skill icon
        $('#banningAbilityContainer').SetHasClass('disableButton', true);

        setSelectedHelperHero(currentSelectedHero, true);

        if (isBoosterDraftGamemode()) {
            $("#boosterDraftPile").SetHasClass('lodSelectedDrop', false);
        }
    } else {
        // Do a selection
        currentSelectedSkill = abName;
        currentSelectedAbCon = abcon;

        // Highlight ability
        if(abcon != null) {
            abcon.SetHasClass('lodSelected', true);
        }

        // Update the banning skill icon
        $('#lodBanThisSkill').abilityname = abName;
        $('#banningAbilityContainer').SetHasClass('disableButton', false);
    }

    // Highlight which slots we can drop it into
    highlightDropSlots();
}

// They clicked on a skill
/*function onHeroAbilityClicked(heroAbilityID) {
    // Focus nothing
    focusNothing();

    var abcon = $('#buildingHelperHeroPreviewSkill' + heroAbilityID);
    var ab = abcon.abilityname;

    // Push the event
    setSelectedDropAbility(ab, abcon);
}*/

// They click on the banning button
function onBanButtonPressed() {
    // Focus nothing
    focusNothing();

    // Check what action should be performed
    if(currentSelectedSkill != '') {
        // They are trying to select a new skill
        banAbility(currentSelectedSkill);

        // Done
        return;
    }
}

function onYourHeroRandomed() {
    // Focus nothing
    focusNothing();

    GameEvents.SendCustomGameEventToServer("lodChooseRandomHero", {})
}

function onYourAbilityIconRandomed(slot) {
    // Focus nothing
    focusNothing();

    GameEvents.SendCustomGameEventToServer("lodChooseRandomAbility", {"slot" : slot})
}

// They clicked on one of their ability icons
function onYourAbilityIconPressed(slot) {
    // Focus nothing
    focusNothing();

    // Check what action should be performed
    if(currentSelectedSkill != '') {
        // They are trying to select a new skill
        chooseNewAbility(slot, currentSelectedSkill);

        // Done
        return;
    }

    // allow swapping of skills
    if(currentSelectedSlot == -1) {
        // Select this slot
        currentSelectedSlot = slot;

        // Do the highlight
        highlightDropSlots();
    } else {
        // Attempt to drop the slot

        // Is it a different slot?
        if(currentSelectedSlot == slot) {
            // Same slot, just deselect
            currentSelectedSlot = -1;

            // Do the highlight
            highlightDropSlots();
            return;
        }

        // Different slot, do the swap
        swapSlots(currentSelectedSlot, slot);

        // Same slot, just deselect
        currentSelectedSlot = -1;

        // Do the highlight
        highlightDropSlots();
    }
}

function showBuilderTab(tabName) {
    // Update search filters
    tabsSearchFilter[currentTab] = $('#lodSearchInput').text;
    currentTab = tabName;

    $('#lodSearchInput').SetFocus();
    $('#lodSearchInput').text = tabsSearchFilter[currentTab] == undefined ? '' : tabsSearchFilter[currentTab];

    // Hide all panels
    if (!inBuildSaveMode) {
        var mainPanel = $('#pickingPhaseTabs');
        mainPanel.SetFocus();

        $.Each(mainPanel.Children(), function(panelTab) {
            if (currentPhase == PHASE_BANNING && panelTab.id == "pickingPhaseHeroTab") {
                return;
            }

            panelTab.visible = false;

            var tab = $('#' + panelTab.id + "Root");
            if (tab) {
                tab.SetHasClass("tabHighlight", panelTab.id == tabName);
            }
        });
    }

    var mainContentPanel = $('#pickingPhaseTabsContent');
    $.Each(mainContentPanel.Children(), function(panelTab) {
        panelTab.visible = false;
    });

    // Show our tab
    var ourTab = $('#' + tabName);
    if(!inBuildSaveMode && ourTab != null) ourTab.visible = true;

    // Try to move the hero preview
    var heroPreview = $('#buildingHelperHeroPreview');
    var heroPreviewCon = $('#' + tabName + 'HeroPreview');
    if(heroPreviewCon != null) {
        heroPreview.SetParent(heroPreviewCon);
    }

    var ourTabContent = $('#' + tabName + 'Content');
    if(ourTabContent != null) ourTabContent.visible = true;

    // Process hooks
    if(onLoadTabHook[tabName]) {
        onLoadTabHook[tabName](tabName);
    }

    if (currentPhase == PHASE_BANNING) {
        $( "#pickingPhaseHeroTab" ).visible = currentTab != "pickingPhaseSkillTab";
    }
}

function toggleHeroGrouping() {
    useSmartGrouping = !useSmartGrouping;

    // Update filters
    calculateFilters();
}

function toggleShowBanned() {
    showBannedSkills = !showBannedSkills;

    // Update filters
    calculateFilters();
}

function toggleShowDisallowed() {
    showDisallowedSkills = !showDisallowedSkills;

    // Update filters
    calculateFilters();
}

function toggleShowPerkRelative() {
    showPerkRelativeSkills = !showPerkRelativeSkills;

    // Update filters
    calculateFilters();
}

function toggleShowTaken() {
    showTakenSkills = !showTakenSkills;

    // Update filters
    calculateFilters();
}

function toggleShowDraftSkills() {
    showNonDraftSkills = !showNonDraftSkills;

    // Update filters
    calculateFilters();
}
function toggleShowTier(tier) {
    var tierNum = parseInt(tier) - 1;
    showTier[tierNum] = !showTier[tierNum];

    // Update filters
    calculateFilters();
}

// Makes the given hero container selectable
function makeHeroSelectable(heroCon) {
    heroCon.SetPanelEvent('oncontextmenu', function() {
        var heroName = heroCon.GetAttributeString('heroName', '');
        if(heroName == null || heroName.length <= 0) return;

        GameEvents.SendCustomGameEventToServer("lodGameSetupPing", {"originalContent" : heroName, "content" : $.Localize(heroName), "type" : "hero"});
    });

    heroCon.SetPanelEvent('onactivate', function() {
        var heroName = heroCon.GetAttributeString('heroName', '');
        if(heroName == null || heroName.length <= 0) return;

        if (GameUI.IsAltDown()) {
            GameEvents.SendCustomGameEventToServer("lodGameSetupPing", {"originalContent" : heroName, "content" : $.Localize(heroName), "type" : "hero"});
            return false;
        }

        setSelectedHelperHero(heroName);
    });

    // Dragging
    heroCon.SetDraggable(true);

    $.RegisterEventHandler('DragStart', heroCon, function(panelID, dragCallbacks) {
        var heroName = heroCon.GetAttributeString('heroName', '');
        if(heroName == null || heroName.length <= 0) return;

        // Create a temp image to drag around
        var displayPanel = $.CreatePanel('DOTAHeroImage', $.GetContextPanel(), 'dragImage');
        displayPanel.heroname = heroName;
        dragCallbacks.displayPanel = displayPanel;
        dragCallbacks.offsetX = 0;
        dragCallbacks.offsetY = 0;
        displayPanel.SetAttributeString('heroName', heroName);

        // Hide skill info
        $.DispatchEvent('DOTAHideAbilityTooltip');
        $.DispatchEvent('DOTAHideTitleTextTooltip');

        // Highlight drop cell
        $('#pickingPhaseSelectedHeroImage').SetHasClass('lodSelectedDrop', true)
        $('#pickingPhaseSelectedHeroImageNone').SetHasClass('lodSelectedDrop', true)

        // Banning
        $('#pickingPhaseBans').SetHasClass('lodSelectedDrop', true)
    });

    $.RegisterEventHandler('DragEnd', heroCon, function(panelId, draggedPanel) {
        // Delete the draggable panel
        draggedPanel.deleted = true;
        draggedPanel.DeleteAsync(0.0);

        // Highlight drop cell
        $('#pickingPhaseSelectedHeroImage').SetHasClass('lodSelectedDrop', false);
        $('#pickingPhaseSelectedHeroImageNone').SetHasClass('lodSelectedDrop', false);

        // Banning
        $('#pickingPhaseBans').SetHasClass('lodSelectedDrop', false)

        var heroName = draggedPanel.GetAttributeString('heroName', '');
        if(heroName == null || heroName.length <= 0) return;

        // Can we select this as our hero?
        if(draggedPanel.GetAttributeInt('canSelectHero', 0) == 1) {
            chooseHero(heroName);
        }

        // Are we banning a hero?
        if(draggedPanel.GetAttributeInt('banThis', 0) == 1) {
            banHero(heroName);
        }
    });

    // Hook the hero info display
    hookHeroInfo(heroCon);
}

function hookHeroInfo(heroCon) {
    // Show hero info
    heroCon.SetPanelEvent('onmouseover', function() {
        var heroName = heroCon.GetAttributeString('heroName', '');
        var info = heroData[heroName];

        var displayNameTitle = $.Localize(heroName);
        var heroStats = generateFormattedHeroStatsString(heroName, info);

        // Show the tip
        $.DispatchEvent('DOTAShowTitleTextTooltipStyled', heroCon, displayNameTitle, heroStats, "testStyle");
    });

    // Hide hero info
    heroCon.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip');
        $.DispatchEvent('DOTAHideTitleTextTooltip');
    });
}

function makeSkillSelectable(abcon) {
    abcon.SetPanelEvent('oncontextmenu', function() {
        var abName = abcon.GetAttributeString('abilityname', '');
        if(abName == null || abName.length <= 0) return false;

        GameEvents.SendCustomGameEventToServer("lodGameSetupPing", {"originalContent" : abName, "content" : $.Localize("DOTA_Tooltip_ability_"+abName), "type" : "ability"});
    });

    abcon.SetPanelEvent('onactivate', function() {
        var abName = abcon.GetAttributeString('abilityname', '');
        if(abName == null || abName.length <= 0) return false;

        if (GameUI.IsAltDown()) {
            GameEvents.SendCustomGameEventToServer("lodGameSetupPing", {"originalContent" : abName, "content" : $.Localize("DOTA_Tooltip_ability_"+abName), "type" : "ability"});
            return false;
        }

        // Mark it as dropable
        setSelectedDropAbility(abName, abcon);

        // Find the owning hero
        var heroOwner = abilityHeroOwner[abName];
        if(heroOwner != null) {
            if (currentPhase != PHASE_BANNING)
                setSelectedHelperHero(heroOwner, true);
        }
    });

    // Dragging
    abcon.SetDraggable(true);

    $.RegisterEventHandler('DragStart', abcon, function(panelID, dragCallbacks) {
        var abName = abcon.GetAttributeString('abilityname', '');
        if(abName == null || abName.length <= 0) return false;

        setSelectedDropAbility(abName, abcon);

        // Create a temp image to drag around
        var displayPanel = $.CreatePanel('DOTAAbilityImage', $.GetContextPanel(), 'dragImage');
        displayPanel.abilityname = abName;
        dragCallbacks.displayPanel = displayPanel;
        dragCallbacks.offsetX = 0;
        dragCallbacks.offsetY = 0;
        displayPanel.SetAttributeString('abilityname', abName);

        // Hide skill info
        $.DispatchEvent('DOTAHideAbilityTooltip');
        $.DispatchEvent('DOTAHideTitleTextTooltip');

        // Banning
        $('#pickingPhaseBans').SetHasClass('lodSelectedDrop', true)
    });

    $.RegisterEventHandler('DragEnd', abcon, function(panelId, draggedPanel) {
        // Delete the draggable panel
        draggedPanel.deleted = true;
        draggedPanel.DeleteAsync(0.0);

        var dropSlot = draggedPanel.GetAttributeInt('activeSlot', -1);
        if(dropSlot != -1) {
            var abName = draggedPanel.GetAttributeString('abilityname', '');
            if(abName != null && abName.length > 0) {
                chooseNewAbility(dropSlot, abName);
            }
        }

        // Highlight nothing
        setSelectedDropAbility();

        // Are we banning a hero?
        if(draggedPanel.GetAttributeInt('banThis', 0) == 1) {
            var abName = draggedPanel.GetAttributeString('abilityname', '');
            if(abName != null && abName.length > 0) {
                banAbility(abName);
            }
        }

        if(isBoosterDraftGamemode() && draggedPanel.GetAttributeInt('draftThis', 0) == 1) {
            var abName = draggedPanel.GetAttributeString('abilityname', '');
            selectBoosterDraftAbility(abName);
        }

        // Banning
        $('#pickingPhaseBans').SetHasClass('lodSelectedDrop', false)
    });
}

function getHeroFilterInfo(heroName) {
    var shouldShow = true;

    // Are we using a draft array?
    if(shouldShow && heroDraft != null) {
        // Is this hero in our draft array?
        if(heroDraft[heroName] == null) {
            shouldShow = false;
        }
    }

    // Filter banned heroes
    if(shouldShow && bannedHeroes[heroName]) {
        shouldShow = false;
    }

    return {
        shouldShow: shouldShow,
        banned: bannedHeroes[heroName] != undefined,
        takenHero: allSelectedHeroes[heroName] != null
    };
}

// When the hero tab is shown
var firstHeroTabCall = true;
var heroFilterInfo = {};
function OnHeroTabShown(tabName) {
    // Only run this code once
    if(firstHeroTabCall) {
        calculateHeroFilters = function() {
            var searchParts = searchText.split(/\s/g);

            for(var heroName in heroPanelMap) {
                var info = getHeroFilterInfo(heroName);
                var shouldShow = info.shouldShow;
                var banned = info.banned;

                // Filter by melee / ranged
                if(shouldShow && heroFilterInfo.classType) {
                    var info = heroData[heroName];
                    if(info) {
                        if(info.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK' && heroFilterInfo.classType == 'ranged' || info.AttackCapabilities == 'DOTA_UNIT_CAP_RANGED_ATTACK' && heroFilterInfo.classType == 'melee') {
                            shouldShow = false;
                        }
                    }
                }

                // Filter by hero name
                if(shouldShow && searchText.length > 0) {
                    // Check each part
                    for(var i=0; i<searchParts.length; ++i) {
                        if($.Localize(heroName).toLowerCase().indexOf(searchParts[i]) == -1 && heroName.indexOf(searchParts[i]) == -1) {
                            shouldShow = false;
                            break;
                        }
                    }
                }

                var con = heroPanelMap[heroName];
                con.SetHasClass('should_hide_this_hero', !shouldShow);
                con.SetHasClass('banned', banned);
            }
        }

        // Calculate hero filters
        calculateHeroFilters();
    }

    // No longer the first call
    firstHeroTabCall = false;
}

function onHeroFilterPressed(filterName) {
    switch(filterName) {
        case 'melee':
            if(heroFilterInfo.classType) {
                if(heroFilterInfo.classType == 'melee') {
                    delete heroFilterInfo.classType;
                } else {
                    heroFilterInfo.classType = 'melee';
                }
            } else {
                heroFilterInfo.classType = 'melee';
            }
        break;

        case 'ranged':
            if(heroFilterInfo.classType) {
                if(heroFilterInfo.classType == 'ranged') {
                    delete heroFilterInfo.classType;
                } else {
                    heroFilterInfo.classType = 'ranged';
                }
            } else {
                heroFilterInfo.classType = 'ranged';
            }
        break;

        case 'clear':
            delete heroFilterInfo.classType;
        break;
    }

    $('#heroPickingFiltersMelee').SetHasClass('lod_hero_filter_selected', heroFilterInfo.classType == 'melee');
    $('#heroPickingFiltersRanged').SetHasClass('lod_hero_filter_selected', heroFilterInfo.classType == 'ranged');
    $('#heroPickingFiltersClear').visible = heroFilterInfo.classType != null;

    // Calculate filters:
    calculateHeroFilters();
}

// When the main selection tab is shown
var firstBuildTabCall = true;
function OnMainSelectionTabShown() {
    if(firstBuildTabCall) {
        LoadBuilds();

        // Only do this once
        firstBuildTabCall = false;
    }
}

function LoadMoreBuilds() {
    var cont = $pickingPhaseRecommendedBuildContainer();
    var cc = cont[0].GetChildCount();
    if (cc > 0) LoadBuilds(cont, cc - 1);
}

function $pickingPhaseRecommendedBuildContainer() {
    var panel;
    $.Each($('#recommendedBuildContainerScrollWrapper').Children(), function(_panel) {
        if (_panel.BHasClass('selected')) {
            panel = _panel;
            return false;
        }
    });
    return [panel, panel.id.replace('pickingPhaseRecommendedBuildContainer', '').toLowerCase()];
}

function SelectBuildSortingOrder(order) {
    var uOrder = order.charAt(0).toUpperCase() + order.slice(1);
    $.Each($('#buildSortingProperties').Children(), function(panel) {
        panel.SetHasClass('selected', panel.id === 'buildSortingProperty' + uOrder);
    });
    $.Each($('#recommendedBuildContainerScrollWrapper').Children(), function(panel) {
        var selected = panel.id === 'pickingPhaseRecommendedBuildContainer' + uOrder;
        panel.SetHasClass('selected', selected);
        if (selected && panel.GetChildCount() === 0) {
            LoadBuilds();
        }
    });
}

// Adds a build to the main selection tab
var recBuildCounter = 0;
function addRecommendedBuild(rootPanel, build) {
    var buildCon = $.CreatePanel('Panel', rootPanel, 'recBuild_' + (++recBuildCounter));
    buildCon.BLoadLayout('file://{resources}/layout/custom_game/game_setup/recommended_build.xml', false, false);
    buildCon.balanceMode = $.GetContextPanel().balanceMode;
    buildCon.setBuildData(makeHeroSelectable, hookSkillInfo, makeSkillSelectable, build, constantBalancePointsValue);
    buildCon.updateFilters(getSkillFilterInfo, getHeroFilterInfo);
}

// Updates the filters applied to recommended builds
function updateRecommendedBuildFilters() {
    // Loop over all recommended builds
    $.Each($pickingPhaseRecommendedBuildContainer()[0].Children(), function(con) {
        con.updateFilters(getSkillFilterInfo, getHeroFilterInfo);
    })
}

// Updates the filters applied to the hero preview
function updateHeroPreviewFilters() {
    // Prepare the filter info
    prepareFilterInfo();

    // Remove any search text
    searchParts = [];
    for(var i=1; i<=16; ++i) {
        var abCon = $('#buildingHelperHeroPreviewSkill' + i);
        // Is it visible?
        if(abCon.visible) {
            // Grab ability name
            var abilityName = abCon.GetAttributeString('abilityname', '');

            // Grab filters
            var filterInfo = getSkillFilterInfo(abilityName);

            // Apply filters
            abCon.SetHasClass('disallowedSkill', filterInfo.disallowed);
            abCon.SetHasClass('bannedSkill', filterInfo.banned);
            abCon.SetHasClass('takenSkill', filterInfo.taken);
            abCon.SetHasClass('notDraftable', filterInfo.cantDraft);
            abCon.SetHasClass('trollCombo', filterInfo.trollCombo);
            //abCon.SetHasClass('notPerkRelative', filterInfo.notPerkRelative);

            if (balanceMode) {
                // Set the label to the cost of the ability
                var abCost = abCon.GetChild(0);
                if (abCost) {
                    for (var j = 0; j < GameUI.AbilityCosts.TIER_COUNT; ++j) {
                        abCost.SetHasClass('tier' + (j + 1), filterInfo.cost == GameUI.AbilityCosts.TIER[j]);
                    }
                    abCost.text = (filterInfo.cost != GameUI.AbilityCosts.NO_COST)? filterInfo.cost: "";
                }
            }
        }
    }

    // Should we filter the hero image?
    var heroImageCon = $('#buildingHelperHeroPreviewHero');
    var heroFilterInfo = getHeroFilterInfo('npc_dota_hero_' + heroImageCon.heroname);

    heroImageCon.SetHasClass('should_hide_this_hero', !heroFilterInfo.shouldShow);
    heroImageCon.SetHasClass('banned', heroFilterInfo.banned);
    heroImageCon.SetHasClass('takenHero', heroFilterInfo.takenHero);

    var heroImageText = $('#buildingHelperHeroPreviewHeroName');
    heroImageText.SetHasClass('should_hide_this_hero', !heroFilterInfo.shouldShow);
    heroImageText.SetHasClass('takenHero', heroFilterInfo.takenHero);
}

function isTrollCombo(abilityName, banned) {
    if (banned || optionValueList['lodOptionBanningBlockTrollCombos'] != 1) {
        return false;
    }

    var playerID = Players.GetLocalPlayer();
    var ourBuild = selectedSkills[playerID] || {};

    for(var slotID in ourBuild) {
        var currAbil = selectedSkills[playerID][slotID];
        if( currAbil != null && trollCombos[currAbil] != null ) {
            // Check through troll combo lists
            if ( trollCombos[currAbil][abilityName] != null ) {
                // Ability should be banned
                return true;
            }
        }
    }
    return false;
}

// Gets skill filter info
function getSkillFilterInfo(abilityName) {
    var shouldShow = true;
    var disallowed = false;
    var banned = false;
    var taken = false;
    var cantDraft = false;
    var notPerkRelative = false;
    var trollCombo = true;
    var cost = 0;

    var cat = (flagDataInverse[abilityName] || {}).category;

    // Check if the category is banned
    if(!allowedCategories[cat]) {
        // Skill is disallowed
        disallowed = true;

        // If we should show banned skills
        if(!showDisallowedSkills) {
            shouldShow = false;
        }
    }
    var heroName = selectedHeroes[Players.GetLocalPlayer()] || "";
    if (heroName != null && heroData[heroName] != null && heroData[heroName].HeroPerk != null) {
        var HeroPerk = heroData[heroName].HeroPerk;
        var abilityPerks = AbilityPerks[abilityName] == null ? [] : AbilityPerks[abilityName].split("|")
        var heroPerks = HeroPerk == null ? [] : HeroPerk.split(" | ");
        if (heroPerks.indexOf(abilityName) == -1 && abilityPerks.every(function(v) {return heroPerks.indexOf(v) == -1;})) {
            notPerkRelative = true;
            if(showPerkRelativeSkills) {
                shouldShow = false;
            }
        }
    }


    // Check for bans
    if(bannedAbilities[abilityName]) {
        // Skill is banned
        banned = true;

        if(!showBannedSkills) {
            shouldShow = false;
        }
    }

    // Check for Troll Combo
    trollCombo = isTrollCombo(abilityName, banned)

    // Mark taken abilities
    if(takenAbilities[abilityName]) {
        if(uniqueSkillsMode == 1 && takenTeamAbilities[abilityName]) {
            // Team based unique skills
            // Skill is taken
            taken = true;

            if(!showTakenSkills) {
                shouldShow = false;
            }
        } else if(uniqueSkillsMode == 2) {
            // Global unique skills
            // Skill is taken
            taken = true;

            if(!showTakenSkills) {
                shouldShow = false;
            }
        }
    }

    if (activeTabs["mostused"]) {
        var mostUsed = AbilityUsageData.data[abilityName];
        cat = !!mostUsed ? "mostused" : "nothing";
    }

    // Check if the tab is active
    if(shouldShow && activeTabs[cat] == null) {
        shouldShow = false;
    }

    // Check if the search category is active
    if(shouldShow && searchCategory.length > 0) {
        if(!flagDataInverse[abilityName][searchCategory]) {
            shouldShow = false;
        }
    }

    // Check if hte search text is active
    if(shouldShow && searchText.length > 0) {
        var localAbName = $.Localize('DOTA_Tooltip_ability_' + abilityName).toLowerCase();
        var owningHeroName = abilityHeroOwner[abilityName] || '';
        var localOwningHeroName = $.Localize(owningHeroName).toLowerCase();

        for(var i=0; i<searchParts.length; ++i) {
            var prt = searchParts[i];
            if(localAbName.indexOf(prt) == -1 && localOwningHeroName.indexOf(prt) == -1 && abilityName.indexOf(prt) == -1) {
                shouldShow = false;
                break;
            }
        }
    }

    var popularityFilterValue = popularityFilterSlider.value;

    var isInverseFilter = popularityFilterDropDown.GetSelected().id === 'popularityFilterMode2';
    if (shouldShow && popularityFilterValue !== (isInverseFilter ? 0 : 100)) {
        shouldShow = isInverseFilter ?
            getAbilityGlobalPickPopularity(abilityName) >= 1 - popularityFilterValue * 0.01 :
            getAbilityGlobalPickPopularity(abilityName) <= popularityFilterValue * 0.01;
    }

    // Check draft array
    if(abilityDraft != null) {
        if(!abilityDraft[abilityName]) {
            // Skill cant be drafted
            cantDraft = true;

            if(!showNonDraftSkills) {
                shouldShow = false;
            }
        }
    }

    // Check if Balance Mode and set the skill cost
    if (balanceMode) {
        cost = GameUI.AbilityCosts.getCost(abilityName);
        // Loop over all the tiers and break when found
        for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
            if (cost == GameUI.AbilityCosts.TIER[i]) {
                shouldShow = showTier[i] && shouldShow;
                break;
            }
        }
    }

    return {
        mostUsed: mostUsed,
        shouldShow: shouldShow,
        disallowed: disallowed,
        banned: banned,
        taken: taken,
        cantDraft: cantDraft,
        trollCombo: trollCombo,
        notPerkRelative: notPerkRelative,
        cost: cost
    };
}

// Updates some of the filters ready for skill filtering
function prepareFilterInfo() {
    // Check on unique skills mode
    uniqueSkillsMode = optionValueList['lodOptionAdvancedUniqueSkills'] || 0;
    uniqueBotsSkillsMode = optionValueList['lodOptionBotsUniqueSkills'] || 0;

    // Grab what to search for
    searchParts = searchText.split(/\s/g);
}

// When the skill tab is shown
var firstSkillTabCall = true;
var searchText = '';
var searchCategory = '';
var activeTabs = {};
var uniqueSkillsMode = 0;
var uniqueBotsSkillsMode = 1;
var searchParts = [];
var groupBlocks = {};
function OnSkillTabShown(tabName) {
    if(firstSkillTabCall) {
        // Empty the skills tab
        var con = $('#pickingPhaseSkillTabContentSkills');

        // Used to provide unique handles
        var unqiueCounter = 0;

        // TODO: Clear filters


        // Filter processor
        searchText = '';
        searchCategory = '';

        activeTabs = {
            main: true,
            neutral: isDraftGamemode(),
            custom: true,
            imba: isIMBA(),
            superop: true,
            mostused: false
        };

        calculateFilters = function() {
            // Array used to sort abilities
            var toSort = [];

            // Prepare skill filters
            prepareFilterInfo();

            // Hide all hero owner blocks
            for(var groupName in groupBlocks) {
                groupBlocks[groupName].visible = false;
                groupBlocks[groupName].SetHasClass('manySkills', false);
            }

            // Counters for how many skills are in a block
            var blockCounts = {};
            var subSorting = {};

            // Loop over all abilties
            for(var abilityName in abilityStore) {
                var ab = abilityStore[abilityName];

                if(ab != null) {
                    var filterInfo = getSkillFilterInfo(abilityName);

                    ab.visible = filterInfo.shouldShow;
                    ab.SetHasClass('disallowedSkill', filterInfo.disallowed);
                    ab.SetHasClass('bannedSkill', filterInfo.banned);
                    ab.SetHasClass('takenSkill', filterInfo.taken);
                    ab.SetHasClass('notDraftable', filterInfo.cantDraft);

                    if (balanceMode) {
                        // Set the label to the cost of the ability
                        var abCost = ab.GetChild(0);
                        for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
                            abCost.SetHasClass('tier' + (i + 1), filterInfo.cost == GameUI.AbilityCosts.TIER[i]);
                        }
                        abCost.text = (filterInfo.cost != GameUI.AbilityCosts.NO_COST)? filterInfo.cost: "";
                    }

                    if(filterInfo.shouldShow) {
                        if(useSmartGrouping && !activeTabs["mostused"]) {
                            var theOwner = abilityHeroOwner[abilityName];
                            var neutralGroup = flagDataInverse[abilityName].group;

                            // Group it
                            var groupKey = theOwner != null ? theOwner : neutralGroup;

                            if(groupKey) {
                                var groupCon = groupBlocks[groupKey];
                                if(groupCon == null) {
                                    groupCon = $.CreatePanel('Panel', con, 'group_container_' + groupKey);
                                    groupCon.SetHasClass('grouped_skills', true);
                                    groupCon.SetHasClass('draftSkills', isDraftGamemode() && currentPhase != PHASE_BANNING)
                                }

                                groupBlocks[groupKey] = groupCon;

                                toSort.push({
                                    txt: groupKey,
                                    con: groupCon,
                                    category: flagDataInverse[abilityName]["category"],
                                    hasOwner: theOwner != null,
                                    grouped: true
                                });

                                // Making the layout much nicer
                                blockCounts[groupKey] = !blockCounts[groupKey] ? 1 : blockCounts[groupKey] + 1;

                                if(blockCounts[groupKey] == 2) {
                                    groupCon.SetHasClass('manySkills', true);
                                }

                                if(subSorting[groupKey] == null) {
                                    subSorting[groupKey] = [];
                                }

                                subSorting[groupKey].push({
                                    txt: abilityName,
                                    con: ab
                                });

                                // Set that it is an ulty
                                if(isUltimateAbility(abilityName)) {
                                    ab.SetHasClass('ultimateAbility', true);
                                }

                                abilityStore[abilityName].SetParent(groupCon);
                                groupCon.visible = true;
                            } else {
                                toSort.push({
                                    txt: abilityName,
                                    con: ab
                                });
                            }

                        } else {
                            var groupKey = AbilityUsageData.data[abilityName];
                            $.Msg(groupKey, " ",abilityName);
                            abilityStore[abilityName].uses = groupKey;
                            if (activeTabs["mostused"] && groupKey) {
                                if(subSorting[groupKey] == null) {
                                    subSorting[groupKey] = [];
                                }

                                subSorting[groupKey].push({
                                    txt: abilityName,
                                    con: ab
                                });
                            }

                            toSort.push({
                                txt: abilityName,
                                con: ab
                            });

                            // Ensure correct parent is set
                            abilityStore[abilityName].SetParent(con);
                        }
                    }
                }
            }

            var categorySorting = [];
            categorySorting["main"] = 1;
            categorySorting["neutral"] = 2;
            categorySorting["custom"] = 3;
            categorySorting["superop"] = 4;
            categorySorting["imba"] = 5;

            if (activeTabs["mostused"]) {
                for (var uses in subSorting)
                {
                    var sortGroup = subSorting[uses];

                    var subCon = con;
                    for(var i=1; i < sortGroup.length; ++i) {
                        var left = sortGroup[i-1];
                        var right = sortGroup[i];

                        subCon.MoveChildAfter(right.con, left.con);
                    }
                }
            } else {
                // Do the main sort
                toSort.sort(function(a, b) {
                    var txtA = a.txt;
                    var txtB = b.txt;

                    var catA = categorySorting[a.category];
                    var catB = categorySorting[b.category];

                    if(a.grouped != b.grouped) {
                        if(a.grouped) return -1;
                        return 1;
                    }

                    // Check if ability is custom and is attached to some hero
                    if ((a.category == "custom" && a.hasOwner) || (b.category == "custom" && b.hasOwner)) {
                        return helperSort(txtA,txtB)
                    } else {
                        if(catA < catB) {
                            return -1;
                        } else if(catA > catB) {
                            return 1;
                        } else {
                            return helperSort(txtA,txtB)
                        }
                    }
                });

                for(var i=1; i<toSort.length; ++i) {
                    var left = toSort[i-1];
                    var right = toSort[i];

                    con.MoveChildAfter(right.con, left.con);
                }

                // Do sub sorts
                for(var heroName in subSorting) {
                    var sortGroup = subSorting[heroName];

                    sortGroup.sort(function(a, b) {
                        var txtA = a.txt;
                        var txtB = b.txt;

                        var isUltA = isUltimateAbility(txtA);
                        var isUltB = isUltimateAbility(txtB);

                        if(isUltA & !isUltB) {
                            return 1;
                        }

                        if(!isUltA & isUltB) {
                            return -1;
                        }

                        if(txtA < txtB) {
                            return -1;
                        } else if(txtA > txtB) {
                            return 1;
                        } else {
                            return 0;
                        }
                    });

                    var subCon = groupBlocks[heroName];
                    for(var i=1; i<sortGroup.length; ++i) {
                        var left = sortGroup[i-1];
                        var right = sortGroup[i];

                        subCon.MoveChildAfter(right.con, left.con);
                    }
                }
            }
        }

        // Add input categories
        var dropdownCategories = $('#lodSkillCategoryHolder');
        dropdownCategories.RemoveAllOptions();
        dropdownCategories.SetPanelEvent('oninputsubmit', function() {
            // Update the category
            var sel = dropdownCategories.GetSelected();
            if(sel != null) {
                searchCategory = dropdownCategories.GetSelected().GetAttributeString('category', '');

                // Update the visible abilties
                calculateFilters();
            }
        });

        // Add header
        var categoryHeader = $.CreatePanel('Label', dropdownCategories, 'skillTabCategory' + (++unqiueCounter));
        categoryHeader.text = $.Localize('lod_cat_none');
        dropdownCategories.AddOption(categoryHeader);
        dropdownCategories.SetSelected('skillTabCategory' + unqiueCounter);

        // Add categories
        for(var category in flagData) {
            if(category == 'category' || category == 'group') continue;

            var dropdownLabel = $.CreatePanel('Label', dropdownCategories, 'skillTabCategory' + (++unqiueCounter));
            dropdownLabel.text = $.Localize('lod_cat_' + category);
            dropdownLabel.SetAttributeString('category', category);
            dropdownCategories.AddOption(dropdownLabel);
        }


        // Start to add skills

        for(var abName in flagDataInverse) {
            // Create a new scope
            (function(abName) {
                // Create the image
                var abcon = $.CreatePanel('DOTAAbilityImage', con, 'skillTabSkill' + (++unqiueCounter));
                var label = $.CreatePanel('Label', abcon, 'skillTabCost' + (++unqiueCounter));
                abcon.abilityname = abName;
                abcon.SetAttributeString('abilityname', abName);
                abcon.SetHasClass('lodMiniAbility', true);
                hookSkillInfo(abcon);
                label.SetHasClass('skillCostSmall', true);

                if (typeof($.GetContextPanel().balanceMode) === "boolean") {
                    label.visible = $.GetContextPanel().balanceMode;
                }
                // abcon.SetHasClass('disallowedSkill', true);

                makeSkillSelectable(abcon);

                if (currentPhase == PHASE_SELECTION && isDraftGamemode()) {
                    if (label) {
                        label.SetHasClass('skillCostLarge', true);
                        label.SetHasClass('skillCostSmall', false);
                    }
                    abcon.AddClass("hide");
                    abcon.AddClass("lodDraftAbility");
                }

                // Store a reference to it
                abilityStore[abName] = abcon;
            })(abName);
        }

        /*
            Add Skill Tab Buttons
        */

        var tabButtonsContainer = $('#pickingPhaseTabFilterThingo');

        // List of tabs to show
        var tabList = [
            'main',
            'neutral',
            'custom',
            'imba',
            'superop',
            'mostused'
        ];

        // Used to store tabs to highlight them correctly
        var storedTabs = {};

        //var widthStyle = Math.floor(100 / tabList.length) + '%';

        for(var i=0; i<tabList.length; ++i) {
            // New script scope!
            (function() {
                var tabName = tabList[i];
                var tabButton = $.CreatePanel('Panel', tabButtonsContainer, 'tabButton_' + tabName);
                tabButton.AddClass('SettingsNavBarButton');

                // Add tabs separator
                if (i < tabList.length - 1) {
                    var separator = $.CreatePanel('Label', tabButtonsContainer, '');
                    separator.text = '/';
                    separator.AddClass('SettingsTabSeparator');
                }

                if(activeTabs[tabName]) {
                    tabButton.AddClass('lodSkillTabActivated');
                }

                // Add the text
                var tabLabel = $.CreatePanel('Label', tabButton, 'tabButton_text_' + tabName);
                tabLabel.text = $.Localize('lodCategory_' + tabName);

                tabButton.SetPanelEvent('onactivate', function() {
                    // When it is activated!

                    if(GameUI.IsControlDown() && tabName != "mostused" && !activeTabs["mostused"]) {
                        if(activeTabs[tabName]) {
                            delete activeTabs[tabName];
                        } else {
                            activeTabs[tabName] = true;
                        }

                        for (var g in abilityStore) {
                            abilityStore[g].SetHasClass("lodDraftAbility", isDraftGamemode() && currentPhase == PHASE_SELECTION);
                        }
                    } else {
                        // Reset active tabs
                        activeTabs = {};
                        activeTabs[tabName] = true;

                        for (var g in abilityStore) {
                            abilityStore[g].SetHasClass("lodDraftAbility", tabName == "mostused" || (isDraftGamemode() && currentPhase == PHASE_SELECTION));
                        }
                    }

                    // Fix highlights
                    for(var theTabName in storedTabs) {
                        var theTab = storedTabs[theTabName];
                        theTab.SetHasClass('lodSkillTabActivated', activeTabs[theTabName] == true);
                    }

                    // Recalculate which skills should be shown
                    calculateFilters();
                });

                // Store it
                storedTabs[tabName] = tabButton;
            })();
        }

        // Do initial calculation:
        calculateFilters();
    }

    // No longewr the first call
    firstSkillTabCall = false;
}

function helperSort(a,b){
    if(a < b) {
        return -1;
    } else if(a > b) {
        return 1;
    } else {
        return 0;
    }
}

// Are we the host?
function isHost() {
    var playerID = Players.GetLocalPlayer();
    return playerID === GameUI.CustomUIConfig().hostID;
}

// Sets an option to a value
function setOption(optionName, optionValue) {
    // Ensure we are the host
    if(!isHost()) return;

    // Don't send an update twice!
    if(lastOptionValues[optionName] && lastOptionValues[optionName] == optionValue) return;

    // Tell the server we changed a setting
    GameEvents.SendCustomGameEventToServer('lodOptionSet', {
        k: optionName,
        v: optionValue
    });
}

// Updates our selected hero
function chooseHero(heroName) {
    GameEvents.SendCustomGameEventToServer('lodChooseHero', {
        heroName:heroName
    });
}

// Tries to ban a hero
function banHero(heroName) {
    // setSelectedHelperHero();

    GameEvents.SendCustomGameEventToServer('lodBan', {
        heroName:heroName
    });
}

// Updates our selected primary attribute
function choosePrimaryAttr(newAttr) {
    GameEvents.SendCustomGameEventToServer('lodChooseAttr', {
        newAttr:newAttr
    });
}

// Attempts to ban an ability
function banAbility(abilityName) {
    var theSkill = abilityName;

    // No skills are selected anymore
    setSelectedDropAbility();

    // Push it to the server to validate
    GameEvents.SendCustomGameEventToServer('lodBan', {
        abilityName: abilityName
    });
}

// Updates our selected abilities
function chooseNewAbility(slot, abilityName) {
    var theSkill = abilityName;

    // No skills are selected anymore
    setSelectedDropAbility();

    // Can't select nothing
    if(theSkill.length <= 0) return;

    // Push it to the server to validate
    GameEvents.SendCustomGameEventToServer('lodChooseAbility', {
        slot: slot,
        abilityName: abilityName
    });
}

function removeAbility(slot) {
    GameEvents.SendCustomGameEventToServer('lodRemoveAbility', {
        slot: slot
    });
}
// Swaps two slots
function swapSlots(slot1, slot2) {
    // Push it to the server to validate
    GameEvents.SendCustomGameEventToServer('lodSwapSlots', {
        slot1: slot1,
        slot2: slot2
    });
}

// Adds a player to the list of unassigned players
function addUnassignedPlayer(playerID) {
    // Grab the panel to insert into
    var unassignedPlayersContainerNode = $('#unassignedPlayersContainer');
    if (unassignedPlayersContainerNode == null) return;

    // Create the new panel
    var newPlayerPanel = activeUnassignedPanels[playerID];

    if(newPlayerPanel == null) {
        newPlayerPanel = $.CreatePanel('Panel', unassignedPlayersContainerNode, 'unassignedPlayer');
        newPlayerPanel.SetAttributeInt('playerID', playerID);
        newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/unassigned_player.xml', false, false);
    } else {
        newPlayerPanel.visible = true;
    }

    // Store it
    activeUnassignedPanels[playerID] = newPlayerPanel;

    // Do we need to hide the team panel?
    if(activePlayerPanels[playerID] != null) {
        activePlayerPanels[playerID].visible = false;
    }

    if(activeReviewPanels[playerID] != null) {
        activeReviewPanels[playerID].visible = false;
    }

    // Add this panel to the list of panels we've generated
    //allPlayerPanels.push(newPlayerPanel);
}

// Adds a player to a team
function addPlayerToTeam(playerID, panel, reviewContainer, shouldMakeSmall) {
    // Validate the panel
    if(panel == null || reviewContainer == null) return;

    // Hide the unassigned container
    if(activeUnassignedPanels[playerID] != null) {
        activeUnassignedPanels[playerID].visible = false;
    }

    /*
        Create the panel at the top of the screen
    */

    // Create the new panel if we need one
    var newPlayerPanel = activePlayerPanels[playerID];

    if(newPlayerPanel == null) {
        newPlayerPanel = $.CreatePanel('Panel', panel, 'teamPlayer' + playerID);
        newPlayerPanel.SetAttributeInt('playerID', playerID);
        newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/team_player.xml', false, false);
        newPlayerPanel.hookStuff(hookSkillInfo, makeSkillSelectable, makeHeroSelectable);
    } else {
        newPlayerPanel.SetParent(panel);
        newPlayerPanel.visible = true;
    }

    // Check max slots
    var maxSlots = optionValueList['lodOptionCommonMaxSlots'];
    if(maxSlots != null) {
        newPlayerPanel.OnGetHeroSlotCount(maxSlots);
    }

    // Check for hero icon
    if(selectedHeroes[playerID] != null) {
        newPlayerPanel.OnGetHeroData(selectedHeroes[playerID]);
    }

    // Check for skill data
    if(selectedSkills[playerID] != null) {
        newPlayerPanel.OnGetHeroBuildData(selectedSkills[playerID]);
    }

    // Check for attr data
    if(selectedAttr[playerID] != null) {
        newPlayerPanel.OnGetNewAttribute(selectedAttr[playerID]);
    }

    // Check for ready state
    if(readyState[playerID] != null) {
        newPlayerPanel.setReadyState(readyState[playerID]);
    }

    // Add this panel to the list of panels we've generated
    //allPlayerPanels.push(newPlayerPanel);
    activePlayerPanels[playerID] = newPlayerPanel;

    /*
        Create the panel in the review screen
    */

    // Create the new panel
    var newPlayerPanel = activeReviewPanels[playerID];

    if(newPlayerPanel == null) {
        newPlayerPanel = $.CreatePanel('Panel', reviewContainer, 'reviewPlayer' + playerID);
        newPlayerPanel.SetAttributeInt('playerID', playerID);
        newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/team_player_review.xml', false, false);
        newPlayerPanel.hookStuff(hookSkillInfo, makeSkillSelectable, setSelectedHelperHero, playerID == Players.GetLocalPlayer());

        newPlayerPanel.preloadedHeroPanels = preloadedHeroPanels;

        // Update z-index to fix skills hiding
        if ( /radiant/i.test(reviewContainer.id) )
            newPlayerPanel.style.zIndex = 20 - playerID;
    } else {
        newPlayerPanel.SetParent(reviewContainer);
        newPlayerPanel.visible = true;
    }

    newPlayerPanel.setShouldBeSmall(shouldMakeSmall);

    // Check max slots
    var maxSlots = optionValueList['lodOptionCommonMaxSlots'];
    if(maxSlots != null) {
        newPlayerPanel.OnGetHeroSlotCount(maxSlots);
    }

    // Check for hero icon
    if(selectedHeroes[playerID] != null) {
        newPlayerPanel.OnGetHeroData(selectedHeroes[playerID]);

        if(currentPhase == PHASE_REVIEW) {
            newPlayerPanel.OnReviewPhaseStart();
        }
    }

    // Check for skill data
    if(selectedSkills[playerID] != null) {
        newPlayerPanel.OnGetHeroBuildData(selectedSkills[playerID]);
    }

    // Check for attr data
    if(selectedAttr[playerID] != null) {
        newPlayerPanel.OnGetNewAttribute(selectedAttr[playerID]);
    }

    // Check for ready state
    if(readyState[playerID] != null) {
        newPlayerPanel.setReadyState(readyState[playerID]);
    }

    // Add this panel to the list of panels we've generated
    //allPlayerPanels.push(newPlayerPanel);
    activeReviewPanels[playerID] = newPlayerPanel;
}

function buildBasicOptionsCategories() {
    var optionContainer = $('#optionBasic');
    var mutatorList = {};
    var gamemodeList = {};
    var mutators;

    var patreon_mutators = CustomNetTables.GetTableValue("phase_pregame", "patreon_features").Mutators;
    

    var addMutators = function(destionationPanel) {
        mutatorList = {};
        mutators.forEach(function(item, i) {
            var name;
            if(item.about) {
                name = item.about;
            } else {
                //$.Msg(item.states);
                name = Object.keys(item.states)[0];
            }

            var optionMutator = $.CreatePanel('Panel', destionationPanel, 'mutator_' + name);
            optionMutator.AddClass('mutator');

            if (item.states !== undefined) {
                var circleWrapper = $.CreatePanel('Panel', optionMutator, 'circleWrapper_' + i);
                circleWrapper.AddClass('circleWrapper');
            }

            var images = {};
            function addImage(state) {
                if (!images[state]) {
                    var optionMutatorImage = $.CreatePanel('Panel', optionMutator, state);
                    optionMutatorImage.BLoadLayoutSnippet("MutatorImage")
                    optionMutatorImage.style.backgroundImage = "url('file://{images}/custom_game/mutators/mutator_" + state + ".png');";
                    // optionMutatorImage.visible = false;
                    images[state] = optionMutatorImage;
                }
            }
            if (item.states) {
                var states = Object.keys(item.states);
                for (var i = 0; i < states.length; i++) {
                    addImage(states[i])
                }
            }
            addImage(item.about)
            if (item.default) {
                for (var i = 0; i < Object.keys(item.default).length; i++) {
                    addImage(Object.keys(item.default)[i])
                }
            }

            function getNextItem(returnString) {
                var nextItem;
                var found = false;
                var i = 0;

                for(var state in item.states) {
                    if(typeof item.states[state] === 'object') {
                        for(var option in item.states[state]) {
                            if(item.states[state][option] === optionValueList[option]) {
                                found = true;
                            } else {
                                found = false;
                                break;
                            }
                        }

                        if(found) {
                            if(item.states[Object.keys(item.states)[i+1]] !== undefined) {
                                nextItem = item.states[Object.keys(item.states)[i+1]];
                                break;
                            } else {
                                if(item.default !== undefined) {
                                    nextItem = item.default;
                                } else {
                                    nextItem = item.states[Object.keys(item.states)[0]];
                                }
                            }
                        } else {
                            nextItem = item.states[Object.keys(item.states)[0]];
                        }
                     } else if(item.states[state] === optionValueList[item.name]) {
                        if(item.states[Object.keys(item.states)[i+1]] !== undefined) {
                            nextItem = item.states[Object.keys(item.states)[i+1]];
                        } else {
                            if(item.default !== undefined) {
                                nextItem = item.default[Object.keys(item.default)[0]];
                            } else {
                                nextItem = item.states[Object.keys(item.states)[0]];
                            }
                        }

                        break;
                    }

                    i++;
                }

                if(nextItem === undefined) {
                    nextItem = item.states[Object.keys(item.states)[0]];
                }

                if (returnString) {
                    var stateName;
                    var found;
                    if(optionMutator.default !== undefined) {
                        if(Object.keys(optionMutator.default).length > 1) {
                            var match;
                            for (var option in optionMutator.default) {
                                if(optionMutator.default[option] === optionValueList[option]) {
                                    match = true;
                                } else {
                                    match = false;
                                    break;
                                }
                            }

                            if(match) {
                                found = false;
                            }
                        } else {
                            for (var defaultState in optionMutator.default) break;
                            if(optionMutator.default[defaultState] === optionValueList[item.name]) {
                                found = false;
                            }
                        }
                    }
                    for(var state in optionMutator.states) {
                        if(typeof optionMutator.states[state] === 'object') {
                            var matches = 0;
                            for(var option in optionMutator.states[state]) {
                                if(optionMutator.states[state][option] === optionValueList[option]) {
                                    matches++;
                                }

                                if(matches === Object.keys(optionMutator.states[state]).length) {
                                    found = true;
                                    break;
                                } else {
                                    found = false;
                                }
                            }

                            if(found) {
                                stateName = state;
                                break;
                            }
                        } else if(optionMutator.states[state] === optionValueList[item.name]) {
                            stateName = Object.keys(optionMutator.states).filter(function(key) {return optionMutator.states[key] === optionValueList[item.name]
                            })[0];

                            found = true;
                            break;
                        } else {
                            found = false;
                        }
                    }
                    if (!stateName) {
                        stateName = optionMutator.default;
                        if (Object.keys(stateName).length == 1) { //
                            for (var s in stateName) {
                                stateName = s;
                                break;
                            }
                        } else if (typeof(stateName) !== "string") {
                            stateName = optionMutator.about;
                        }
                    }

                    return stateName;
                }

                return nextItem;
            }

            function getPrevItem(returnString) {
                var nextItem;
                var found = false;
                var i = 0;

                for(var state in item.states) {
                    if(typeof item.states[state] === 'object') {
                        for(var option in item.states[state]) {
                            if(item.states[state][option] === optionValueList[option]) {
                                found = true;
                            } else {
                                found = false;
                                break;
                            }
                        }

                        if(found) {
                            if(item.states[Object.keys(item.states)[i-1]] !== undefined) {
                                nextItem = item.states[Object.keys(item.states)[i-1]];
                                break;
                            } else {
                                if(item.default !== undefined) {
                                    nextItem = item.default;
                                } else {
                                    nextItem = item.states[Object.keys(item.states)[Object.keys(item.states).length - 1]];
                                }
                            }
                        } else {
                            nextItem = item.states[Object.keys(item.states)[Object.keys(item.states).length - 1]];
                        }
                     } else if(item.states[state] === optionValueList[item.name]) {
                        if(item.states[Object.keys(item.states)[i-1]] !== undefined) {
                            nextItem = item.states[Object.keys(item.states)[i-1]];
                        } else {
                            if(item.default !== undefined) {
                                nextItem = item.default[Object.keys(item.default)[Object.keys(item.default).length - 1]];
                            } else {
                                nextItem = item.states[Object.keys(item.states)[Object.keys(item.states).length - 1]];
                            }
                        }

                        break;
                    }

                    i++;
                }

                if(nextItem === undefined) {
                    nextItem = item.states[Object.keys(item.states)[Object.keys(item.states).length - 1]];
                }

                if (returnString) {
                    var stateName;
                    var found;
                    if(optionMutator.default !== undefined) {
                        if(Object.keys(optionMutator.default).length > 1) {
                            var match;
                            for (var option in optionMutator.default) {
                                if(optionMutator.default[option] === optionValueList[option]) {
                                    match = true;
                                } else {
                                    match = false;
                                    break;
                                }
                            }

                            if(match) {
                                found = false;
                            }
                        } else {
                            for (var defaultState in optionMutator.default) break;
                            if(optionMutator.default[defaultState] === optionValueList[item.name]) {
                                found = false;
                            }
                        }
                    }
                    for(var state in optionMutator.states) {
                        if(typeof optionMutator.states[state] === 'object') {
                            var matches = 0;
                            for(var option in optionMutator.states[state]) {
                                if(optionMutator.states[state][option] === optionValueList[option]) {
                                    matches++;
                                }

                                if(matches === Object.keys(optionMutator.states[state]).length) {
                                    found = true;
                                    break;
                                } else {
                                    found = false;
                                }
                            }

                            if(found) {
                                stateName = state;
                                break;
                            }
                        } else if(optionMutator.states[state] === optionValueList[item.name]) {
                            stateName = Object.keys(optionMutator.states).filter(function(key) {return optionMutator.states[key] === optionValueList[item.name]
                            })[0];

                            found = true;
                            break;
                        } else {
                            found = false;
                        }
                    }
                    if (!stateName) {
                        stateName = optionMutator.default;
                        if (Object.keys(stateName).length == 1) { //
                            for (var s in stateName) {
                                stateName = s;
                                break;
                            }
                        } else if (typeof(stateName) !== "string") {
                            stateName = optionMutator.about;
                        }
                    }

                    return stateName;
                }

                return nextItem;
            }

            optionMutator.getNextItem = getNextItem;
            optionMutator.getPrevItem = getPrevItem;

            optionMutator.getNextState = (function (state) {
                if(item.about) {
                    return item.about;
                } else {
                    var states = Object.keys(item.states);
                    var flag = false;
                    for (var i = 0; i < states.length; i++) {
                        if (flag == true) {
                            return states[i];
                        }
                        if (states[i] == state) {
                            flag = true;
                        }
                    }
                    if (flag && Object.keys(item.default)[0]) {
                        return Object.keys(item.default)[0];
                    }
                    return states[0];
                }
            })

            var onActivate = (function(e) {
                if (item.patreon && !isPatron(item.name)) {
                    openPatreon();
                    return;
                }
                var fieldValue = optionMutator.GetAttributeInt('fieldValue', -1);
                if (item.name == "lodOptionCommonGamemode" && !allowCustomSettings) {
                    return;
                }
                if (item.values !== undefined) {
                    var state;
                    if(optionMutator.BHasClass('active')) {
                        state = 'disabled';
                    } else {
                        state = 'enabled';
                    }

                    for (var option in item.values[state]) {
                        var value = item.values[state][option];
                        setOption(option, value)
                    }
                } else if (item.states !== undefined) {
                    var nextItem = getNextItem();

                    if(typeof nextItem === 'object') {
                        for(var option in nextItem) {
                            setOption(option, nextItem[option]);
                        }
                    } else {
                        setOption(item.name, nextItem);
                    }
                } else {
                    if(optionMutator.BHasClass('active')) {
                        setOption(item.name, 0);
                    } else {
                        setOption(item.name, 1);
                    }
                }
            })

            var onContextMenu = (function(e) {
                if (item.patreon && !isPatron(item.name)) {
                    openPatreon();
                    return;
                }
                var fieldValue = optionMutator.GetAttributeInt('fieldValue', -1);
                if (item.name == "lodOptionCommonGamemode" && !allowCustomSettings) {
                    return;
                }
                if (item.values !== undefined) {
                    var state;
                    if(optionMutator.BHasClass('active')) {
                        state = 'disabled';
                    } else {
                        state = 'enabled';
                    }

                    for (var option in item.values[state]) {
                        var value = item.values[state][option];
                        setOption(option, value)
                    }
                } else if (item.states !== undefined) {
                    var nextItem = getPrevItem();

                    if(typeof nextItem === 'object') {
                        for(var option in nextItem) {
                            setOption(option, nextItem[option]);
                        }
                    } else {
                        setOption(item.name, nextItem);
                    }
                } else {
                    if(optionMutator.BHasClass('active')) {
                        setOption(item.name, 0);
                    } else {
                        setOption(item.name, 1);
                    }
                }
            })

            // When the mutators changes
            optionMutator.SetPanelEvent('onactivate', onActivate);
            optionMutator.SetPanelEvent('oncontextmenu', onContextMenu);

            var infoLabel = $.CreatePanel('Label', optionMutator, 'optionMutatorLabel_' + i);
            infoLabel.AddClass('mutatorLabel');

            if(item.states) {
                infoLabel.text = $.Localize(Object.keys(item.states)[0]);
            } else  {
                infoLabel.text = $.Localize(item.about);
            }

            if(item.values) {
                for(var value in item.values.enabled) {
                    optionMutator.SetAttributeString('optionList', '');
                    optionMutator.optionList = item.values.enabled;
                    mutatorList[value] = optionMutator;
                }
            } else if (item.states) {
                optionMutator.SetAttributeString('states', '');
                optionMutator.images = images;
                optionMutator.label = infoLabel;
                optionMutator.states = {};
                for(var state in item.states) {
                    if(typeof item.states[state] === 'object') {
                        optionMutator.states[state] = item.states[state];
                        for(var option in item.states[state]) {
                            mutatorList[option] = optionMutator;
                        }
                    } else {
                        optionMutator.states[state] = item.states[state];
                    }
                }

                if(item.default) {
                    if(item.about) {
                        optionMutator.about = item.about;
                    }

                    optionMutator.default = item.default;
                }

                mutatorList[item.name] = optionMutator;
            } else {
                mutatorList[item.name] = optionMutator;
            }

            if (item.patreon) {
                optionMutator.AddClass('patreonMutator');
                patreonMutators = CustomNetTables.GetTableValue("phase_pregame", "patreon_features").Options;
                var mutatorOfTheDay = CustomNetTables.GetTableValue("phase_pregame", "mutatorOfTheDay").value;
                var count_ = 0;
                var found_ = false;
                
                for (var mutatorname in patreonMutators) {
                    if (mutatorOfTheDay === count_) {
                        
                        if (mutatorname == item.name) {
                            mutatorOfTheDay = mutatorname;
                            mutator_of_the_day = mutatorname
                            // TODO
                            //mainSlot.AddClass('patreonMutatorOfTheDay');
                            found_ = true;
                            //break;
                        }
                    }
                    count_++;
                }

                if (!isPatron(item.name))
                {   
                    if (found_ == false) {
                        var images = optionMutator.FindChildrenWithClassTraverse("mutatorImage");
                        for (var c in images) {
                            images[c].style.saturation = "0.1;";
                        }
                    } else {
                        var images = optionMutator.FindChildrenWithClassTraverse("mutatorImage");
                        for (var c in images) {
                            // Do something
                        }
                    }
                }


                
                if (found_ == false) {
                    var extraPanel = $.CreatePanel('Image', optionMutator, '');
                    extraPanel.SetImage('s2r://panorama/images/custom_game/patreon_small_png.vtex');
                    extraPanel.AddClass('patreonExtra');

                    extraPanel.SetPanelEvent('onmouseover', function() {
                        $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', extraPanel, 'MutatorTooltip', "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + "lodPatreonFeature" );
                    });
                    extraPanel.SetPanelEvent('onmouseout', function() {
                        $.DispatchEvent( 'UIHideCustomLayoutTooltip', extraPanel, 'MutatorTooltip' );
                    });
                } else {
                    var extraPanel = $.CreatePanel('Image', optionMutator, '');
                    extraPanel.SetImage('s2r://panorama/images/custom_game/mutators/free_today_png.vtex');
                    extraPanel.AddClass('patreonExtra');
                }
            }

            if (item.hasOwnProperty('extraInfo')) {
                var extraPanel = $.CreatePanel('Image', optionMutator, '');
                extraPanel.SetImage('s2r://panorama/images/custom_game/infotooltip_png.vtex');
                extraPanel.AddClass('mutatorExtra');

                if (item.patreon) {

                }

                extraPanel.SetPanelEvent('onmouseover', function() {
                    $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', extraPanel, 'MutatorTooltip', "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + item.extraInfo );
                });
                extraPanel.SetPanelEvent('onmouseout', function() {
                    $.DispatchEvent( 'UIHideCustomLayoutTooltip', extraPanel, 'MutatorTooltip' );
                });
            }
        });
    }

    // Loop over all the option labels
    for(var optionLabelText in basicOptions) {
        // Create a new scope
        (function(optionLabelText, optionData) {
             // Build the fields
            var fieldData = optionData.fields;

            // The panel
            var optionPanel = $('#scroller');

            if(optionData.custom) {
                optionPanel.AddClass('optionButtonCustomRequired');
            }

            if(optionData.bot && !CustomNetTables.GetTableValue("phase_pregame", "forceBots")) {
                optionPanel.AddClass('optionButtonBotRequired');
            }

            for(var i=0; i<fieldData.length; ++i) {
                // Create new script scope
                (function() {
                    // Grab info about this field
                    var info = fieldData[i];
                    var fieldName = info.name;
                    var sort = info.sort;
                    var values = info.values;

                    if(fieldData[i].name === 'lodOptionGamemode') {
                        var length = fieldData[i].values.length;
                        fieldData[i].values.forEach(function(item, i) {
                            var optionMode = $.CreatePanel('Panel', optionPanel, 'option_' + i);
                            optionMode.SetAttributeInt('fieldValue', item.value);
                            optionMode.AddClass('option');

                            // When the mode changes
                            optionMode.SetPanelEvent('onactivate', function() {
                                var fieldValue = optionMode.GetAttributeInt('fieldValue', -1);
                                setOption(fieldName, fieldValue);
                            });

                            var optionModeLabel = $.CreatePanel('Label', optionMode, 'optionModeLabel_' + i);
                            optionModeLabel.AddClass('optionLabel');
                            optionModeLabel.text = $.Localize(item.text);

                            var optionModeDescription = $.CreatePanel('Label', optionMode, 'optionModeDescription_' + i);
                            optionModeDescription.AddClass('optionDescription');
                            optionModeDescription.text = $.Localize(item.about);

                            var optionModeImage = $.CreatePanel('Image', optionMode, 'optionModeImage_' + i);
                            optionModeImage.AddClass('optionImage');
                            optionModeImage.SetImage('file://{images}/custom_game/options/option' + i + '.png');

                            gamemodeList[item.value] = optionMode;

                            optionFieldMap[fieldName] = function(newValue) {
                                $.Each(optionPanel.Children(), function(elem) {
                                    if(elem.BHasClass('active') && !elem.BHasClass('mutator')) {
                                        elem.RemoveClass('active');
                                    }
                                });

                                gamemodeList[newValue].AddClass('active');
                            }
                        });

                        mutators = fieldData[i].mutators;
                    }
                })();
            }

            // Store the reference
            allOptionLinks[optionLabelText] = {
                panel: optionPanel
            }

            // The function to run when it is activated
            function whenActivated() {
                // Disactivate all other ones
                for(var key in allOptionLinks) {
                    var data = allOptionLinks[key];

                    data.panel.SetHasClass('activeMenu', false);
                }

                // Activate our one
                optionPanel.SetHasClass('activeMenu', true);

                // If we are the host, tell the server which menu we are looking at
                if(isHost()) {
                    GameEvents.SendCustomGameEventToServer('lodOptionsMenu', {v: optionLabelText});
                }
            }

            // Check if it is default
            if(optionData.default) {
                whenActivated();
            }
        })(optionLabelText, basicOptions[optionLabelText]);
    }

    addMutators($('#mutatorPanel'));

    return mutatorList;
}

// Build the options categories
function buildAdvancedOptionsCategories( mutatorList ) {
    // Grab the main container for option categories
    var catContainer = $('#optionCategories');
    var optionContainer = $('#optionAdvanced');
    var gamemodeList = {};
    var mutators;

    // Reset option links
    allOptionLinks = {};

    var setMutator = function(field, state) {
        mutatorList[field].label.text = $.Localize(state);

        for (var s in mutatorList[field].images) {
            mutatorList[field].images[s].visible = s == state;
        }

        // if (!mutatorList[field].f) {
        //     mutatorList[field].f = true;

        // } else {
        //     var tempImage = mutatorList[field].image;
        //     mutatorList[field].image = mutatorList[field].cachedImage;
        //     mutatorList[field].cachedImage = tempImage;

        //     mutatorList[field].image.visible = true;
        //     mutatorList[field].cachedImage.visible = false;
        // }

        // mutatorList[field].cachedImage.style.backgroundImage = "url('file://{images}/custom_game/mutators/mutator_" + mutatorList[field].getNextState(state) + ".png');";
    }

    var checkMutators = function(field, hostPanel) {
        if(mutatorList[field]) {
            var found = true;
            if(mutatorList[field].optionList) {
                var options = mutatorList[field].optionList;

                for(var value in options) {
                    if(optionValueList[value] != options[value]) {
                        found = false;
                        break;
                    }
                }

                if(found) {
                    mutatorList[field].AddClass('active');
                } else {
                    mutatorList[field].RemoveClass('active');
                }
            } else if (mutatorList[field].states) {
                mutatorList[field].RemoveClass('active');

                if(mutatorList[field].default !== undefined) {
                    if(Object.keys(mutatorList[field].default).length > 1) {
                        var match;
                        for (var option in mutatorList[field].default) {
                            if(mutatorList[field].default[option] === optionValueList[option]) {
                                match = true;
                            } else {
                                match = false;
                                break;
                            }
                        }

                        if(match) {
                            setMutator(field, mutatorList[field].about);
                            found = false;
                        }
                    } else {
                        for (var defaultState in mutatorList[field].default) break;
                        if(mutatorList[field].default[defaultState] === optionValueList[field]) {
                            setMutator(field, defaultState);
                            found = false;
                        }
                    }
                }

                if(found) {
                    var stateName;
                    found = true;
                    for(var state in mutatorList[field].states) {
                        if(typeof mutatorList[field].states[state] === 'object') {
                            var matches = 0;
                            for(var option in mutatorList[field].states[state]) {
                                if(mutatorList[field].states[state][option] === optionValueList[option]) {
                                    matches++;
                                }

                                if(matches === Object.keys(mutatorList[field].states[state]).length) {
                                    found = true;
                                    break;
                                } else {
                                    found = false;
                                }
                            }

                            if(found) {
                                stateName = state;
                                break;
                            }
                        } else if(mutatorList[field].states[state] === optionValueList[field]) {
                            stateName = Object.keys(mutatorList[field].states).filter(function(key) {return mutatorList[field].states[key] === optionValueList[field]
                            })[0];

                            found = true;
                            break;
                        } else {
                            found = false;
                        }
                    }
                }

                if(found) {
                    setMutator(field, stateName);
                    mutatorList[field].AddClass('active');
                }
            } else {
                if(optionValueList[field]) {
                    mutatorList[field].AddClass('active');
                } else {
                    mutatorList[field].RemoveClass('active');
                }
            }
        }
    }

    var changeGamemode = function(value) {

    }

    // Loop over all the option labels
    for(var optionLabelText in advancedOptions) {
        // Create a new scope
        (function(optionLabelText, optionData) {
            // The button
            var optionCategory = $.CreatePanel('Panel', catContainer, 'option_button_' + optionLabelText);
            optionCategory.SetAttributeString('cat', optionLabelText);
            //optionCategory.AddClass('PlayButton');
            //optionCategory.AddClass('RadioBox');
            //optionCategory.AddClass('HeroGridNavigationButtonBox');
            //optionCategory.AddClass('NavigationButtonGlow');
            optionCategory.AddClass('OptionButton');

            var innerPanel = $.CreatePanel('Panel', optionCategory, 'option_button_' + optionLabelText + '_fancy');
            innerPanel.AddClass('OptionButtonFancy');

            var innerPanelTwo = $.CreatePanel('Panel', optionCategory, 'option_button_' + optionLabelText + '_glow');
            innerPanelTwo.AddClass('OptionButtonGlow');

            // Check if this requires custom settings
            if(optionData.custom) {
                optionCategory.AddClass('optionButtonCustomRequired');
            }

            // Check for bot settings
            if(optionData.bot && !CustomNetTables.GetTableValue("phase_pregame", "forceBots")) {
                optionCategory.AddClass('optionButtonBotRequired');
            }

            // Button text
            var optionLabel = $.CreatePanel('Label', optionCategory, 'option_button_' + optionLabelText + '_label');
            optionLabel.text = $.Localize(optionLabelText + '_lod');
            optionLabel.AddClass('OptionButtonLabel');

            // The panel
            var optionPanel = $.CreatePanel('Panel', optionContainer, 'option_panel_' + optionLabelText);
            optionPanel.AddClass('OptionPanel');

            if(optionData.custom) {
                optionPanel.AddClass('optionButtonCustomRequired');
            }

            if(optionData.bot && !CustomNetTables.GetTableValue("phase_pregame", "forceBots")) {
                optionPanel.AddClass('optionButtonBotRequired');
            }

            // Patreon
            var patreon_options = CustomNetTables.GetTableValue("phase_pregame", "patreon_features").Options;

            // Build the fields
            var fieldData = optionData.fields;
            if (optionLabelText === 'items') {
                InitializeItemList(optionPanel);
            } else {
                for(var i=0; i<fieldData.length; ++i) {
                    // Create new script scope
                    (function() {
                        // Grab info about this field
                        var info = fieldData[i];
                        var fieldName = info.name;
                        var sort = info.sort;
                        var values = info.values;

                        if(fieldData[i].name === 'lodOptionGamemode') {
                            var length = fieldData[i].values.length;
                            fieldData[i].values.forEach(function(item, i) {
                                var optionMode = $.CreatePanel('Panel', optionPanel, 'option_' + i);
                                optionMode.SetAttributeInt('fieldValue', item.value);
                                optionMode.AddClass('option');

                                // When the mode changes
                                optionMode.SetPanelEvent('onactivate', function() {
                                    var fieldValue = optionMode.GetAttributeInt('fieldValue', -1);
                                    setOption(fieldName, fieldValue);
                                });

                                var optionModeLabel = $.CreatePanel('Label', optionMode, 'optionModeLabel_' + i);
                                optionModeLabel.AddClass('optionLabel');
                                optionModeLabel.text = $.Localize(item.text);

                                var optionModeDescription = $.CreatePanel('Label', optionMode, 'optionModeDescription_' + i);
                                optionModeDescription.AddClass('optionDescription');
                                optionModeDescription.text = $.Localize(item.about);

                                var optionModeImage = $.CreatePanel('Image', optionMode, 'optionModeImage_' + i);
                                optionModeImage.AddClass('optionImage');
                                optionModeImage.SetImage('file://{images}/custom_game/options/option' + i + '.png');

                                gamemodeList[item.value] = optionMode;

                                optionFieldMap[fieldName] = function(newValue) {
                                    $.Each(optionPanel.Children(), function(elem) {
                                        if(elem.BHasClass('active') && !elem.BHasClass('mutator')) {
                                            elem.RemoveClass('active');
                                        }
                                    });

                                    gamemodeList[newValue].AddClass('active');
                                }
                            });

                            mutators = fieldData[i].mutators;
                        } else {
                            // Create the info
                            var mainSlot = $.CreatePanel('Panel', optionPanel, 'option_panel_main_' + fieldName);
                            mainSlot.AddClass('optionSlotPanel');
                            var infoLabel = $.CreatePanel(sort === 'shopTree' ? 'ToggleButton' : 'Label', mainSlot, 'option_panel_main_' + fieldName);
                            infoLabel.text = $.Localize(info.des);
                            infoLabel.AddClass('optionSlotPanelLabel');

                            

                            if (patreon_options[fieldName]) {
                                patreonMutators = CustomNetTables.GetTableValue("phase_pregame", "patreon_features").Options;
                                var mutatorOfTheDay = CustomNetTables.GetTableValue("phase_pregame", "mutatorOfTheDay").value;
                                var count_ = 0;
                                var found_ = false;
                                
                                for (var mutatorname in patreonMutators) {
                                    if (mutatorOfTheDay === count_) {
                                        
                                        if (mutatorname == fieldName) {
                                            mutatorOfTheDay = mutatorname;
                                            mutator_of_the_day = mutatorname
                                            // TODO
                                            //mainSlot.AddClass('patreonMutatorOfTheDay');
                                            found_ = true;
                                            //break;
                                        }
                                    }
                                    count_++;
                                }
                                if (found_ == false) {
                                    mainSlot.AddClass('patreon');
                                } else {
                                    mainSlot.RemoveClass('patreonMutator');
                                }
                                
                            }

                            mainSlot.SetPanelEvent('onmouseover', function() {
                                $.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', mainSlot, "OptionTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize(info.about));
                            });

                            mainSlot.SetPanelEvent('onmouseout', function() {
                                $.DispatchEvent( 'UIHideCustomLayoutTooltip', mainSlot, "OptionTooltip");
                            });

                            var floatRightContiner = $.CreatePanel('Panel', mainSlot, 'option_panel_field_' + fieldName + '_container');
                            floatRightContiner.AddClass('optionsSlotPanelContainer');

                            // Create stores for the newly created items
                            var hostPanel;
                            var slavePanel = $.CreatePanel('Label', floatRightContiner, 'option_panel_field_' + fieldName + '_slave');
                            slavePanel.AddClass('optionsSlotPanelSlave');
                            slavePanel.AddClass('optionSlotPanelLabel');
                            slavePanel.text = 'Unknown';

                            if (patreon_options[fieldName] && !isPatron(fieldName)) {
                                slavePanel.text = $.Localize("lodPatreonFeature");
                                slavePanel.RemoveClass('optionsSlotPanelSlave');
                                slavePanel.style.color = "#FF661A;";
                                infoLabel.style.color = "#FF661A;";
                            } else {
                                switch(sort) {
                                    case 'dropdown':
                                        // Create the drop down
                                        hostPanel = $.CreatePanel('DropDown', floatRightContiner, 'option_panel_field_' + fieldName);
                                        hostPanel.AddClass('optionsSlotPanelHost');

                                        // Maps values to panels
                                        var valueToPanel = {};

                                        for(var j=0; j<values.length; ++j) {
                                            var valueInfo = values[j];
                                            var fieldText = valueInfo.text;
                                            var fieldValue = valueInfo.value;

                                            var subPanel = $.CreatePanel('Label', hostPanel.AccessDropDownMenu(), 'option_panel_field_' + fieldName + '_' + fieldText);
                                            subPanel.text = $.Localize(fieldText);
                                            //subPanel.SetAttributeString('fieldText', fieldText);
                                            subPanel.SetAttributeInt('fieldValue', fieldValue);
                                            hostPanel.AddOption(subPanel);

                                            // Store the map
                                            valueToPanel[fieldValue] = 'option_panel_field_' + fieldName + '_' + fieldText;

                                            if(j == values.length-1) {
                                                hostPanel.SetSelected(valueToPanel[fieldValue]);
                                            }
                                        }

                                        // Mapping function
                                        optionFieldMap[fieldName] = function(newValue) {
                                            for(var i=0; i<values.length; ++i) {
                                                var valueInfo = values[i];
                                                var fieldText = valueInfo.text;
                                                var fieldValue = valueInfo.value;

                                                if(fieldValue == newValue) {
                                                    var thePanel = valueToPanel[fieldValue];
                                                    if(thePanel) {
                                                        // Select that panel
                                                        hostPanel.SetSelected(thePanel);

                                                        // Update text
                                                        slavePanel.text = $.Localize(fieldText);
                                                        break;
                                                    }
                                                }
                                            }

                                            checkMutators(fieldName, hostPanel);
                                        }

                                        // When the data changes
                                        hostPanel.SetPanelEvent('oninputsubmit', function() {
                                            // Grab the selected one
                                            var selected = hostPanel.GetSelected();
                                            //var fieldText = selected.GetAttributeString('fieldText', -1);
                                            var fieldValue = selected.GetAttributeInt('fieldValue', -1);

                                            // Sets an option
                                            setOption(fieldName, fieldValue);
                                        });
                                    break;

                                    case 'range':
                                        // Create the Container
                                        hostPanel = $.CreatePanel('Panel', floatRightContiner, 'option_panel_field_' + fieldName);
                                        hostPanel.BLoadLayout('file://{resources}/layout/custom_game/slider.xml', false, false);
                                        hostPanel.AddClass('optionsSlotPanelHost');

                                        var sliderStep = info.step;
                                        var sliderMin = info.min;
                                        var sliderMax = info.max;
                                        var sliderDefault = info.default;

                                        var sliderPanel = hostPanel.FindChildInLayoutFile('slider');
                                        sliderPanel.min = sliderMin;
                                        sliderPanel.max = sliderMax;
                                        sliderPanel.increment = sliderStep;
                                        sliderPanel.value = sliderDefault;
                                        sliderPanel.SetShowDefaultValue(true);

                                        var onGetNewSliderValue = function(newValue, shouldNetwork, ignoreSlider, ignoreText) {
                                            // Validate the new value
                                            newValue = Math.floor(newValue / sliderStep) * sliderStep;

                                            if(newValue < sliderMin) {
                                                newValue = sliderMin;
                                            }

                                            if(newValue > sliderMax) {
                                                newValue = sliderMax;
                                            }

                                            // Update Slider Position
                                            if(!ignoreSlider) {
                                                sliderPanel.value = newValue;
                                            }

                                            // Update text value
                                            if(!ignoreText) {
                                                inputValuePanel.text = newValue;
                                            }

                                            // Update slave text
                                            slavePanel.text = newValue;

                                            // Should we network it?
                                            if(shouldNetwork) {
                                                // Set it
                                                setOption(fieldName, newValue);
                                            }
                                        }

                                        hookSliderChange(sliderPanel, function(panel, newValue) {
                                            onGetNewSliderValue(newValue, false, true, false);
                                        }, function(panel, newValue) {
                                            onGetNewSliderValue(newValue, true, true, false);
                                        });

                                        var inputValuePanel = hostPanel.FindChildInLayoutFile('entry');
                                        inputValuePanel.text = sliderDefault;

                                        addInputChangedEvent(inputValuePanel, function(panel, newValue) {
                                            newValue = parseInt(newValue);
                                            if(isNaN(newValue)) {
                                                newValue = sliderMin;
                                            }

                                            onGetNewSliderValue(newValue, false, false, true);
                                        });

                                        inputValuePanel.SetPanelEvent('onblur', function() {
                                            var newValue = inputValuePanel.text;

                                            newValue = parseInt(newValue);
                                            if(isNaN(newValue)) {
                                                newValue = sliderMin;
                                            }

                                            onGetNewSliderValue(newValue, true);
                                        });

                                        optionFieldMap[fieldName] = function(newValue) {
                                            onGetNewSliderValue(newValue, false);
                                            checkMutators(fieldName, hostPanel);
                                        }
                                    break;

                                    case 'toggle':
                                        // Create the toggle box
                                        hostPanel = $.CreatePanel('ToggleButton', floatRightContiner, 'option_panel_field_' + fieldName);
                                        hostPanel.AddClass('optionsSlotPanelHost');
                                        hostPanel.AddClass('optionsHostToggleSelector');

                                        // When the checkbox has been toggled
                                        var checkboxToggled = function() {
                                            // Check if it is checked or not
                                            setOption(fieldName, hostPanel.checked);
                                            if (info.requiresServerCheck) hostPanel.checked = false;
                                            hostPanel.text = values[hostPanel.checked ? 1 : 0].text;
                                            slavePanel.text = $.Localize(values[hostPanel.checked ? 1 : 0].text);
                                        }

                                        // When the data changes
                                        hostPanel.SetPanelEvent('onactivate', checkboxToggled);

                                        // Mapping function
                                        optionFieldMap[fieldName] = function(newValue) {
                                            hostPanel.checked = newValue == 1;

                                            if(hostPanel.checked) {
                                                hostPanel.text = $.Localize(values[1].text);
                                                slavePanel.text = $.Localize(values[1].text);
                                            } else {
                                                hostPanel.text = $.Localize(values[0].text);
                                                slavePanel.text = $.Localize(values[0].text);
                                            }

                                            checkMutators(fieldName, hostPanel);
                                        }

                                        // When the main slot is pressed
                                        mainSlot.SetPanelEvent('onactivate', function() {
                                            if(!hostPanel.visible) return;

                                            hostPanel.checked = !hostPanel.checked;
                                            checkboxToggled();
                                        });
                                    break;
                                }
                            }
                        }
                    })();
                }
            }

            // Fix stuff
            $.CreatePanel('Label', optionPanel, 'option_panel_fixer_' + optionLabelText);

            // Store the reference
            allOptionLinks[optionLabelText] = {
                panel: optionPanel,
                button: optionCategory
            }

            // The function to run when it is activated
            function whenActivated() {
                $.GetContextPanel().AddClass('ignore_custom_message');
                // Disactivate all other ones
                for(var key in allOptionLinks) {
                    var data = allOptionLinks[key];

                    data.panel.SetHasClass('activeMenu', false);
                    data.button.SetHasClass('activeMenu', false);
                }

                // Activate our one
                optionPanel.SetHasClass('activeMenu', true);
                optionCategory.SetHasClass('activeMenu', true);

                // If we are the host, tell the server which menu we are looking at
                if(isHost()) {
                    GameEvents.SendCustomGameEventToServer('lodOptionsMenu', {v: optionLabelText});
                }
            }

            // When the button is clicked
            optionCategory.SetPanelEvent('onactivate', whenActivated);

            // Check if it is default
            if(optionData.default) {
                whenActivated();
            }
        })(optionLabelText, advancedOptions[optionLabelText]);
    }
}

// Player presses auto assign
function onAutoAssignPressed() {
    if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().mainHost) {
        // Auto assign teams
        Game.AutoAssignPlayersToTeams();
        // Lock teams
        Game.SetTeamSelectionLocked(true);
    } else if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().hostID) {
        GameEvents.SendCustomGameEventToServer('lodOnChangeLock', {
            command: 'assign'});
    }
}

// Player presses shuffle
function onShufflePressed() {
    if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().mainHost) {
        // Shuffle teams
        Game.ShufflePlayerTeamAssignments();
    } else if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().hostID) {
        GameEvents.SendCustomGameEventToServer('lodOnChangeLock', {
            command: 'shuffle'});
    }
}

// Player presses lock teams
function onLockPressed() {
    // Don't allow a forced start if there are unassigned players
    if (Game.GetUnassignedPlayerIDs().length > 0)
        return;
    if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().mainHost)
    {
        // Lock the team selection so that no more team changes can be made
        Game.SetTeamSelectionLocked(true);
    } else if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().hostID) {
        GameEvents.SendCustomGameEventToServer('lodOnChangeLock', {
            command: 'lock'});
    }
}

// Player presses unlock teams
function onUnlockPressed() {
    if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().mainHost)
    {
        // Unlock Teams
        Game.SetTeamSelectionLocked(false);
    } else if (Game.GetLocalPlayerID() === GameUI.CustomUIConfig().hostID) {
        GameEvents.SendCustomGameEventToServer('lodOnChangeLock', {
            command: 'unlock'});
    }
}

// Lock options pressed
function onLockOptionsPressed() {
    // Ensure teams are locked
    if(!Game.GetTeamSelectionLocked()) return;

    GameEvents.SendCustomGameEventToServer('lodOptionsLocked', {});
}

// Player tries to join radiant
function onJoinRadiantPressed() {
    // Attempt to join radiant
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
}

// Player tries to join dire
function onJoinDirePressed() {
    // Attempt to join dire
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
}

// Player tries to join unassigned
function onJoinUnassignedPressed() {
    // Attempt to join unassigned
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}

// Does the actual update
function doActualTeamUpdate() {
    // Create a panel for each of the unassigned players
    var unassignedPlayers = Game.GetUnassignedPlayerIDs();
    for(var i=0; i<unassignedPlayers.length; ++i) {
        // Add this player to the unassigned list
        addUnassignedPlayer(unassignedPlayers[i]);
    }

    var theCon;
    var theConMain;

    var radiantTopContainer = $('#theRadiantContainer');

    var reviewRadiantContainer = $('#reviewRadiantTeam');
    var reviewRadiantTopContainer = $('#reviewPhaseRadiantTeamTop');
    var reviewRadiantBotContainer = $('#reviewPhaseRadiantTeamBot');

    // Add radiant players
    var radiantPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
    for(var i=0; i<radiantPlayers.length; ++i) {
        theConMain = radiantTopContainer;
        if(radiantPlayers.length <= 5) {
            theCon = reviewRadiantContainer;
        } else {
            if(i < 5) {
                theCon = reviewRadiantTopContainer;
            } else {
                theCon = reviewRadiantBotContainer;
            }
        }

        // Add this player to radiant
        addPlayerToTeam(radiantPlayers[i], theConMain, theCon, radiantPlayers.length > 5);
    }

    // Do we have more than 5 players on radiant?
    //radiantTopContainer.SetHasClass('tooManyPlayers', radiantPlayers.length > 5);
    reviewRadiantContainer.SetHasClass('tooManyPlayers', radiantPlayers.length > 5);

    // Fix align when tooManyPlayers
    reviewRadiantTopContainer.visible = radiantPlayers.length > 5;
    reviewRadiantBotContainer.visible = radiantPlayers.length > 5;

    var direTopContainer = $('#theDireContainer');

    var reviewDireContainer = $('#reviewDireTeam');
    var reviewDireTopContainer = $('#reviewPhaseDireTeamTop');
    var reviewDireBotContainer = $('#reviewPhaseDireTeamBot');

    // Add radiant players
    var direPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
    for(var i=0; i<direPlayers.length; ++i) {
        theConMain = direTopContainer;

        if(direPlayers.length <= 5) {
            theCon = reviewDireContainer;
        } else {
            if(i < 5) {
                theCon = reviewDireTopContainer;
            } else {
                theCon = reviewDireBotContainer;
            }
        }

        // Add this player to dire
        addPlayerToTeam(direPlayers[i], theConMain, theCon, direPlayers.length > 5);
    }

    // Do we have more than 5 players on radiant?
    //direTopContainer.SetHasClass('tooManyPlayers', direPlayers.length > 5);
    reviewDireContainer.SetHasClass('tooManyPlayers', direPlayers.length > 5);

    // Fix align when tooManyPlayers
    reviewDireTopContainer.visible = direPlayers.length > 5;
    reviewDireBotContainer.visible = direPlayers.length > 5;

    // Update all of the team panels moving the player panels for the
    // players assigned to each team to the corresponding team panel.
    /*for ( var i = 0; i < g_TeamPanels.length; ++i )
    {
        UpdateTeamPanel( g_TeamPanels[ i ] )
    }*/

    // Set the class on the panel to indicate if there are any unassigned players
    $('#mainSelectionRoot').SetHasClass('unassigned_players', unassignedPlayers.length != 0 );
    $('#mainSelectionRoot').SetHasClass('no_unassigned_players', unassignedPlayers.length == 0 );

    // Hide the correct stuff
    calculateHideEnemyPicks();

    // Set host privledges
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;
    var playerID = playerInfo.player_id

    $.GetContextPanel().SetHasClass('player_has_host_privileges', playerID === GameUI.CustomUIConfig().hostID);
}

//--------------------------------------------------------------------------------------------------
// Update the unassigned players list and all of the team panels whenever a change is made to the
// player team assignments
//--------------------------------------------------------------------------------------------------
var teamUpdateInProgress = false;
var needsAnotherUpdate = false;
function OnTeamPlayerListChanged() {
    if(teamUpdateInProgress) {
        needsAnotherUpdate = true;
        return;
    }
    teamUpdateInProgress = true;

    // Do the update
    doActualTeamUpdate();

    // Give a delay before allowing another update
    $.Schedule(0.5, function() {
        teamUpdateInProgress = false;

        if(needsAnotherUpdate) {
            needsAnotherUpdate = false;
            OnTeamPlayerListChanged();
        }
    });
}

//--------------------------------------------------------------------------------------------------
//Generate formatted string of Hero stats from sent
//--------------------------------------------------------------------------------------------------
function heroStatsLine(lineName, value, color, color2) {
    // Ensure we have a color
    if(color == null) color = 'FFFFFF';
    if(color2 == null) color2 = '7C7C7C';

    // Create the line
    return '<font color=\'#' + color + '\'>' + $.Localize(lineName) + ':</font> <font color=\'#' + color2 + '\'>' + value + '</font><br>';
}

// Converts a string into a number with a certain number of decimal places
function stringToDecimalPlaces(numberString, places) {
    if(places == null) places = 2;
    return parseFloat(numberString).toFixed(places);
}

function generateFormattedHeroStatsString(heroName, info) {
    // Will contain hero stats
    var heroStats = '';

    // Seperator used to seperate sections
    var seperator = '<font color=\'#FFFFFF\'>_____________________________________</font><br>';

    if(info != null) {
        // Calculate how many total stats we have
        var startingAttributes = info.AttributeBaseStrength + info.AttributeBaseAgility + info.AttributeBaseIntelligence;
        var attributesPerLevel = stringToDecimalPlaces(info.AttributeStrengthGain + info.AttributeAgilityGain + info.AttributeIntelligenceGain);

        // Pick the colors for primary attribute
        var strColor = info.AttributePrimary == 'DOTA_ATTRIBUTE_STRENGTH' ? 'FF3939' : 'FFFFFF';
        var agiColor = info.AttributePrimary == 'DOTA_ATTRIBUTE_AGILITY' ? 'FF3939' : 'FFFFFF';
        var intColor = info.AttributePrimary == 'DOTA_ATTRIBUTE_INTELLECT' ? 'FF3939' : 'FFFFFF';

        // Calculate our stat gain
        var strGain = stringToDecimalPlaces(info.AttributeStrengthGain);
        var agiGain = stringToDecimalPlaces(info.AttributeAgilityGain);
        var intGain = stringToDecimalPlaces(info.AttributeIntelligenceGain);

        // Essentials
        heroStats += seperator;
        heroStats += heroStatsLine('heroStats_movementSpeed', info.MovementSpeed);
        heroStats += heroStatsLine('heroStats_attackRange', info.AttackRange);
        heroStats += heroStatsLine('heroStats_armor', info.ArmorPhysical);
        heroStats += heroStatsLine('heroStats_damage', info.AttackDamageMin + '-' + info.AttackDamageMax);

        // Attribute Stats
        heroStats += seperator;
        heroStats += heroStatsLine('heroStats_strength', info.AttributeBaseStrength + ' + ' + strGain, strColor);
        heroStats += heroStatsLine('heroStats_agility', info.AttributeBaseAgility + ' + ' + agiGain, agiColor);
        heroStats += heroStatsLine('heroStats_intelligence', info.AttributeBaseIntelligence + ' + ' + intGain, intColor);
        heroStats += '<br>';

        heroStats += heroStatsLine('heroStats_attributes_starting', startingAttributes, 'F9891A');
        heroStats += heroStatsLine('heroStats_attributes_perLevel', attributesPerLevel, 'F9891A');

        // Advanced
        heroStats += seperator;
        heroStats += heroStatsLine('heroStats_attackRate', stringToDecimalPlaces(info.AttackRate));
        heroStats += heroStatsLine('heroStats_attackAnimationPoint', stringToDecimalPlaces(info.AttackAnimationPoint));
        heroStats += heroStatsLine('heroStats_turnrate', stringToDecimalPlaces(info.MovementTurnRate));

        if(stringToDecimalPlaces(info.StatusHealthRegen) != 0.25) {
            heroStats += heroStatsLine('heroStats_baseHealthRegen', stringToDecimalPlaces(info.StatusHealthRegen));
        }

        if(info.MagicalResistance != 25) {
            heroStats += heroStatsLine('heroStats_magicalResistance', info.MagicalResistance);
        }

        if(stringToDecimalPlaces(info.StatusManaRegen) != 0.01) {
            heroStats += heroStatsLine('heroStats_baseManaRegen', stringToDecimalPlaces(info.StatusManaRegen));
        }

        if(info.ProjectileSpeed != 900 && info.ProjectileSpeed != 0) {
            heroStats += heroStatsLine('heroStats_projectileSpeed', info.ProjectileSpeed);
        }

        if(info.VisionDaytimeRange != 1800) {
            heroStats += heroStatsLine('heroStats_visionDay', info.VisionDaytimeRange);
        }

        if(info.VisionNighttimeRange != 800) {
            heroStats += heroStatsLine('heroStats_visionNight', info.VisionNighttimeRange);
        }

        if(info.RingRadius != 70) {
            heroStats += heroStatsLine('heroStats_ringRadius', info.RingRadius);
        }
    }

    // Unique Mechanics
    var heroMechanic = $.Localize("unique_mechanic_" + heroName.substring(14));
    if(heroMechanic != "unique_mechanic_" + heroName.substring(14)) {
        heroStats += '<br>';
        heroStats += heroStatsLine('heroStats_uniqueMechanic', heroMechanic, '23FF27', '70EA72');
    }

    // Talent Trees
    heroStats += '<br>';
    heroStats += heroStatsLine($.Localize('heroStats_talentTree'), "", '7FABF1', 'FFFFFF');
    for (var i = 1; i <= 4; i++) {
        var specialGroup = info["SpecialBonus"+i];
        heroStats += heroStatsLine($.Localize("heroStats_SpecialBonus"+i), $.Localize("DOTA_Tooltip_ability_"+specialGroup["1"]) + $.Localize("heroStats_or") + $.Localize("DOTA_Tooltip_ability_"+specialGroup["2"]), '7FABF1', 'FFFFFF');
    }

    return heroStats;
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function OnPlayerSelectedTeam( nPlayerId, nTeamId, bSuccess ) {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;

    // Check to see if the event is for the local player
    if (playerInfo.player_id === nPlayerId) {
        // Play a sound to indicate success or failure
        if (bSuccess) {
            Game.EmitSound('ui_team_select_pick_team');
        } else {
            Game.EmitSound('ui_team_select_pick_team_failed');
        }
    }
}

function isIMBA() {
    if (!CustomNetTables.GetTableValue("options", "lodOptionAdvancedImbaAbilities")) {
        return false;
    }
    var netTableValue = CustomNetTables.GetTableValue("options", "lodOptionAdvancedImbaAbilities").v;
    return netTableValue == 1;
}

function isDraftGamemode() {
    if (!CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode")) {
        return false;
    }
    var netTableValue = CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode").v;
    return netTableValue == 5 || netTableValue == 3 || netTableValue == 6 || optionValueList['lodOptionCommonGamemode'] == 5 || optionValueList['lodOptionCommonGamemode'] == 3 || optionValueList['lodOptionCommonGamemode'] == 6
}

function isBoosterDraftGamemode() {
    if (!CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode")) {
        return false;
    }
    var netTableValue = CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode").v;
    return netTableValue == 6 || optionValueList['lodOptionCommonGamemode'] == 6;
}

function isAllRandomGamemode() {
    if (!CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode")) {
        return false;
    }
    var netTableValue = CustomNetTables.GetTableValue("options", "lodOptionCommonGamemode").v;
    return netTableValue == 4 || optionValueList['lodOptionCommonGamemode'] == 4;
}

function restrictToHeroSelection() {
    restrictedToHeroSelection = true;

    $("#pickingPhaseMainTabRoot").enabled = false;
    $("#pickingPhaseSkillTabRoot").enabled = false;

    $("#buildingHelperHeroPreviewSkillsContainer").visible = false;

    $('#lodStageName').SetHasClass('showLodWarningTimer', true);

    showBuilderTab('pickingPhaseHeroTab');
}

function undoRestriction() {
    restrictedToHeroSelection = false;

    $("#pickingPhaseMainTabRoot").enabled = true;
    $("#pickingPhaseSkillTabRoot").enabled = true;
}

// A phase was changed
var seenPopupMessages = {};
var isTabSwitched = false;

function OnPhaseChanged(table_name, key, data) {
    switch(key) {
        case 'phase':
            // Update phase classes
            var masterRoot = $.GetContextPanel();
            masterRoot.RemoveClass(phases[currentPhase].class);

            // Update the current phase
            currentPhase = data.v;
            masterRoot.AddClass(phases[currentPhase].class);

            // Progress to the new phase
            SetSelectedPhase(currentPhase, true);

            // Hide middle buttons on all pick maps
            if (currentPhase == PHASE_OPTION_VOTING)
            {
                var mapName = Game.GetMapInfo().map_display_name;
                if (mapName.match("classic"))
                    $('#middleButtons').visible = false;
            }

            // Message for hosters
            if(currentPhase == PHASE_OPTION_SELECTION) {
                // Should we show the host message popup?
                if(!seenPopupMessages.hostWarning) {
                    seenPopupMessages.hostWarning = true;
                    showPopupMessage('lodWelcomeMessage');
                }
            }

            // Message voting
            /*if(currentPhase == PHASE_OPTION_VOTING) {
                // Should we show the host message popup?
                if(!seenPopupMessages.optionVoting) {
                    seenPopupMessages.optionVoting = true;
                    showPopupMessage('lodOptionVoting');
                }
            }*/

            // Message for banning phase
            if(currentPhase == PHASE_BANNING) {
                // Enable tabs
                $("#tabsSelector").visible = true;

                // Setup selection
                setSelectedHelperHero(undefined, false)

                // Set main tab activated
                if (!isTabSwitched){
                    showBuilderTab('pickingPhaseMainTab');
                    isTabSwitched = true;
                }

                // Should we show the host message popup?
                if(!seenPopupMessages.skillBanningInfo) {
                    seenPopupMessages.skillBanningInfo = true;
                    showPopupMessage('lodBanningMessage');
                }

                // for (var group in groupBlocks) {
                //     groupBlocks[group].SetHasClass('draftSkills', false)

                // }

                if (optionValueList['lodOptionBanningHostBanning'] == 1 && !isHost()) {
                    $('#pickingPhaseBans').visible = false;
                }
            }

            // Message for players selecting skills
            if(currentPhase == PHASE_SELECTION) {
                $("#newAbilitiesPanel").SetHasClass('GoldBonusEnabled', CustomNetTables.GetTableValue("options", "lodOptionNewAbilitiesBonusGold").v > 0);

                // Enable tabs
                $("#tabsSelector").visible = true;

                setSelectedHelperHero();

                // 30 second lock
                if (!Game.IsInToolsMode()) {
                    if (!$.GetContextPanel().isSinglePlayer) {
                        $('#heroBuilderLockButton').SetHasClass("makeThePlayerNoticeThisButton", false)
                        $('#heroBuilderLockButton').enabled = false;
                        $('#cooldownOverlay').AddClass("ready");
                        $.Schedule(30.0, function () {
                            $('#heroBuilderLockButton').SetHasClass("makeThePlayerNoticeThisButton", true)
                            $('#heroBuilderLockButton').enabled = true;
                        })
                        $('#heroBuilderLockButton').SetHasClass('pressed', !$('#heroBuilderLockButton').BHasClass('pressed'));
                    }
                }

                // Set main tab activated
                if (!isTabSwitched){
                    if (isDraftGamemode()) {
                        showBuilderTab('pickingPhaseSkillTab');
                        $("#pickingPhaseSkillTabContent").visible = false;
                    } else {
                        showBuilderTab('pickingPhaseMainTab');
                    }

                    isTabSwitched = true;
                }

                // Should we show the host message popup?
                if(!seenPopupMessages.skillDraftingInfo) {
                    if (isBoosterDraftGamemode()) {
                        showPopupMessage('lodBoosterDraftMessage');
                    } else {
                        if (balanceMode) {
                            seenPopupMessages.skillBanningInfo = true;
                            showPopupMessage('lodBalanceMessage');
                        } else {
                            seenPopupMessages.skillDraftingInfo = true;
                            showPopupMessage('lodPickingMessage');
                        }
                    }
                }

                if (isDraftGamemode() && currentPhase == PHASE_SELECTION) {
                    for (var g in abilityStore) {
                        abilityStore[g].SetHasClass("lodDraftAbility", isDraftGamemode() && currentPhase == PHASE_SELECTION);
                    }
                    $.Msg($("#pickingPhaseSkillTabContentSkills").Children().length);
                    for (var k in $("#pickingPhaseSkillTabContentSkills").Children()) {
                        var panel = $("#pickingPhaseSkillTabContentSkills").Children()[k];
                        if (panel.BHasClass("lodMiniAbility")) {
                            var label = panel.GetChild(0);
                            if (label) {
                                label.SetHasClass('skillCostLarge', true);
                                label.SetHasClass('skillCostSmall', false);
                            }
                            panel.AddClass("hide");
                            panel.AddClass("lodDraftAbility");
                        }
                    }
                }
            }

            // Message for players selecting skills
            if(currentPhase == PHASE_SPAWN_HEROES) {
                // $("#tipPanel").AddClass('hidden');
    //             // Load all hero images
    //             for(var playerID in activeReviewPanels) {
    //                 activeReviewPanels[playerID].OnReviewPhaseStart();
    //             }
                var parent = $.GetContextPanel().GetParent();
                while(parent.id != "Hud")
                    parent = parent.GetParent();

                var panel = parent.FindChildTraverse("PreGame");
                for (var child in panel.Children()) {
                    panel.Children()[child].visible = false;
                }

                var loading = $.CreatePanel('Panel', panel, '');
                loading.BLoadLayout('file://{resources}/layout/custom_game/custom_loading_screen.xml', false, false);
                loading.FindChildTraverse("buildLoadingIndicator").visible = true;
                $.Schedule(1.0, function () {
                    loading.FindChildTraverse("LoDLoadingTip").visible = true;
                })
                loading.FindChildTraverse("vignette").visible = false;
            }

            break;

        case 'endOfTimer':
            // Store the end time
            endOfTimer = data.v;
            break;

        case 'activeTab':
            var newActiveTab = data.v;

            for(var key in allOptionLinks) {
                // Grab reference
                var info = allOptionLinks[key];
                var optionButton = info.button;

                // Set active one
                optionButton.SetHasClass('activeHostMenu', key == newActiveTab);
            }
            break;

        case 'freezeTimer':
            freezeTimer = data.v;
            break;

        case 'doneCaching':
            // No longer waiting for precache
            waitingForPrecache = false;
            break;

        case 'vote_counts':
            // Server just sent us vote counts
            $.Each(data, function(info, name) {
                if (VotingOptionPanels[name] != null) {
                    VotingOptionPanels[name].UpdateVotes(info);
                }
            })
            break;

        case 'premium_info':
            var playerID = Players.GetLocalPlayer();

            if(data[playerID] != null) {
                // Store if we are a premium player
                isPremiumPlayer = data[playerID] > 0;
                GameUI.CustomUIConfig().isPremiumPlayer = isPremiumPlayer;
                $.GetContextPanel().SetHasClass('premiumUser', isPremiumPlayer);
            }
            break;

        case 'contributors':
            GameUI.CustomUIConfig().premiumData = data;
            break;

        case 'patrons':
            GameUI.CustomUIConfig().patrons = data;
            $("#thankyouButton").visible = isPatron();
            $("#patreonButton").visible = isPatron() == false;
            break;

        // case 'patreon_features':
        //     GameUI.CustomUIConfig().patreon_features = data;
        //     break;
    }

    // Ensure we are hiding the correct enemy picks
    calculateHideEnemyPicks();
}

function OnHostChanged(data) {
    GameUI.CustomUIConfig().hostID = data.newHost;
    if (GameUI.CustomUIConfig().hostID === Players.GetLocalPlayer()){
        showPopupMessage('You are a new host.');
    }
    OnTeamPlayerListChanged();
}

// An option just changed
function OnOptionChanged(table_name, key, data) {
    // Store new value
    optionValueList[key] = data.v;

    // Check if there is a mapping function available
    if(optionFieldMap[key]) {
        // Yep, run it!
        optionFieldMap[key](data.v);
    }

    switch(key) {
        // Check for the custom stuff
        case 'lodOptionGamemode':
            // Check if we are allowing custom settings
            allowCustomSettings = data.v == -1;
            $.GetContextPanel().RemoveClass('ignore_custom_message');
            $.GetContextPanel().SetHasClass('allow_custom_settings', allowCustomSettings || util.reviewOptions);
            $.GetContextPanel().SetHasClass('disallow_custom_settings', !allowCustomSettings && !util.reviewOptions);
            break;

        // Check for allowed categories changing
        case 'lodOptionAdvancedHeroAbilities':
        case 'lodOptionAdvancedNeutralAbilities':
        case 'lodOptionAdvancedOPAbilities':
        case 'lodOptionAdvancedCustomSkills':
        case 'lodOptionAdvancedImbaAbilities':
            onAllowedCategoriesChanged();
            break;
        // Check if it's the number of slots allowed
        case 'lodOptionCommonMaxSkills':
        case 'lodOptionCommonMaxSlots':
        case 'lodOptionCommonMaxUlts':
            onMaxSlotsChanged();
            break;

        // Check for banning phase
        case 'lodOptionBanningMaxBans':
        case 'lodOptionBanningMaxHeroBans':
        case 'lodOptionBanningHostBanning':
            onMaxBansChanged();
            break;

        // Check for unique abilities changing
        case 'lodOptionAdvancedUniqueSkills':
            calculateFilters();
            updateHeroPreviewFilters();
            updateRecommendedBuildFilters();
            $('#mainSelectionRoot').SetHasClass('unique_skills_mode', optionValueList['lodOptionAdvancedUniqueSkills'] > 0);
            break;

        case 'lodOptionAdvancedUniqueHeroes':
            $('#mainSelectionRoot').SetHasClass('unique_heroes_mode', optionValueList['lodOptionAdvancedUniqueHeroes'] == 1);
            break;

        case 'lodOptionCommonGamemode':
            onGamemodeChanged();
            break;

        // Hide enemy picks
        case 'lodOptionAdvancedHidePicks':
            hideEnemyPicks = data.v == 1;
            calculateHideEnemyPicks();
            break;

        case 'lodOptionBalanceMode':
            onBalanceModeChanged();
            break;

        case 'lodOptionBanningBalanceMode':
            onBalanceModeBanList();
            break;

        case 'lodOptionBalanceModePoints':
            SetBalanceModePoints(data.v);
            break;
    }
}

// Recalculates how many abilities / heroes we can ban
function recalculateBanLimits() {
    var maxHeroBans = optionValueList['lodOptionBanningMaxHeroBans'] || 0;
    var maxAbilityBans = optionValueList['lodOptionBanningMaxBans'] || 0;
    var hostBanning = optionValueList['lodOptionBanningHostBanning'] || 0;

    // Is host banning enabled, and we are the host?
    if(hostBanning && isHost()) {
        $('#lodBanLimits').text = $.Localize('hostBanningPanelText');
        return;
    }

    var heroBansLeft = maxHeroBans - currentHeroBans;
    var abilityBansLeft = maxAbilityBans - currentAbilityBans;

    var txt = '';
    var txtMainLeft = $.Localize('lodYouCanBan');
    var txtHero = '';
    var txtAb = '';

    if(heroBansLeft > 0) {
        if(heroBansLeft > 1) {
            txtHero = $.Localize('lodUptoHeroes');
        } else {
            txtHero = $.Localize('lodUptoOneHero');
        }
    }

    if(abilityBansLeft > 0) {
        if(abilityBansLeft > 1) {
            txtAb = $.Localize('lodUptoAbilities');
        } else {
            txtAb = $.Localize('lodUptoAbility');
        }
    }

    if(heroBansLeft > 0) {
        txt = txtMainLeft + txtHero;

        if(abilityBansLeft > 0) {
            txt += $.Localize('lodBanAnd') + txtAb;
        }
    } else if(abilityBansLeft) {
        txt = txtMainLeft + txtAb;
    } else {
        txt = $.Localize('lodNoMoreBans');
    }

    // Add full stop
    txt += '.';

    txt = txt.replace(/\{heroBansLeft\}/g, heroBansLeft);
    txt = txt.replace(/\{abilityBansLeft\}/g, abilityBansLeft);

    $('#lodBanLimits').text = txt;
}

// Recalculates what teams should be hidden
function calculateHideEnemyPicks( ) {
    // Hide picks
    var hideRadiantPicks = false;
    var hideDirePicks = false;

    if(hideEnemyPicks) {
        var playerInfo = Game.GetLocalPlayerInfo();
        if(playerInfo) {
            var teamID = playerInfo.player_team_id;

            if(teamID == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
                hideDirePicks = true;
            }

            if(teamID == DOTATeam_t.DOTA_TEAM_BADGUYS) {
                hideRadiantPicks = true;
            }
        }
    }

    $('#theRadiantContainer').SetHasClass('hide_picks', hideRadiantPicks && !$.GetContextPanel().isIngameBuilder);
    $('#theDireContainer').SetHasClass('hide_picks', hideDirePicks && !$.GetContextPanel().isIngameBuilder);
}

// The gamemode has changed
function onGamemodeChanged() {
    var theGamemode = optionValueList['lodOptionCommonGamemode'];

    var noHeroSelection = false;

    if(theGamemode == 4) {
        // All Random
        noHeroSelection = true;
    }

    var masterRoot = $('#mainSelectionRoot');
    masterRoot.SetHasClass('no_hero_selection', noHeroSelection);

    // All random mode
    masterRoot.SetHasClass('all_random_mode', theGamemode == 4);
}

// Max number of bans has changed
function onMaxBansChanged() {
    var maxBans = optionValueList['lodOptionBanningMaxBans'];
    var maxHeroBans = optionValueList['lodOptionBanningMaxHeroBans'];
    var hostBanning = optionValueList['lodOptionBanningHostBanning'];

    // Hide / show the banning phase button
    if(maxBans != null && maxHeroBans != null && hostBanning != null) {
        var masterRoot = $('#mainSelectionRoot');
        masterRoot.SetHasClass('no_banning_phase', maxBans == 0 && maxHeroBans == 0 && hostBanning == 0);
    }

    // Recalculate limits
    recalculateBanLimits();
}

// The max number of slots / ults / regular abs has changed!
function onMaxSlotsChanged() {
    var maxSlots = optionValueList['lodOptionCommonMaxSlots'];
    var maxSkills = optionValueList['lodOptionCommonMaxSkills'];
    var maxUlts = optionValueList['lodOptionCommonMaxUlts'];

    // Ensure all variables are defined
    if(maxSlots == null || maxSkills == null || maxUlts == null) return;

    for(var i=1; i<=6; ++i) {
        var con = $('#lodYourAbility' + i);

        if(i <= maxSlots) {
            con.visible = true;
        } else {
            con.visible = false;
        }
    }

    // Push it
    for(var playerID in activePlayerPanels) {
        activePlayerPanels[playerID].OnGetHeroSlotCount(maxSlots);
    }

    for(var playerID in activeReviewPanels) {
        activeReviewPanels[playerID].OnGetHeroSlotCount(maxSlots);
    }
}

function onAllowedCategoriesChanged() {
    // Reset the allowed categories
    allowedCategories = {};

    if(optionValueList['lodOptionAdvancedHeroAbilities'] == 1) {
        allowedCategories['main'] = true;
    }

    if(optionValueList['lodOptionAdvancedNeutralAbilities'] == 1) {
        allowedCategories['neutral'] = true;
    }

    if(optionValueList['lodOptionAdvancedCustomSkills'] == 1) {
        allowedCategories['custom'] = true;
    }

    if(optionValueList['lodOptionAdvancedImbaAbilities'] == 1) {
        allowedCategories['imba'] = true;
    }

    if(optionValueList['lodOptionAdvancedCustomSkills'] == 1) {
        allowedCategories['superop'] = true;
    }

    if(optionValueList['lodOptionAdvancedOPAbilities'] == 1) {
        allowedCategories['OP'] = true;
    }

    // Update the filters
    calculateFilters();
    updateHeroPreviewFilters();
    updateRecommendedBuildFilters();
}

function onBalanceModeChanged() {
    if (typeof($.GetContextPanel().balanceMode) != "boolean") {
        balanceMode = optionValueList['lodOptionBalanceMode'];
        GameUI.AbilityCosts.balanceModeEnabled = optionValueList['lodOptionBalanceMode'];

        $( "#balanceModeFilter" ).SetHasClass("balanceModeDisabled", !balanceMode);
        for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
            $( "#buttonShowTier" + (i + 1) ).SetHasClass("balanceModeDisabled", !balanceMode);
        }
        $( "#balanceModePointsPreset" ).SetHasClass("balanceModeDisabled", !balanceMode);
        $( "#balanceModePointsHeroes" ).SetHasClass("balanceModeDisabled", !balanceMode);
        $( "#balanceModePointsSkills" ).SetHasClass("balanceModeDisabled", !balanceMode);
    }
}

function onBalanceModeBanList() {

}

// Changes which phase the player currently has selected
function SetSelectedPhase(newPhase, noSound) {
    if(newPhase > currentPhase) {
        Game.EmitSound('ui_team_select_pick_team_failed');
        return;
    }

    // Emit the click noise
    if(!noSound) Game.EmitSound('ui_team_select_pick_team');

    // Set the phase
    selectedPhase = newPhase;
    GameUI.CustomUIConfig().selectedPhase = newPhase;;

    if (phases[selectedPhase] != undefined)
        $('#lodStageName').text = $.Localize(phases[selectedPhase].name);

    // Update CSS
    if (selectedPhase != PHASE_SELECTION) {
        util.reviewOptions = false;
    }
    var masterRoot = $.GetContextPanel();
    masterRoot.SetHasClass('phase_option_selection_selected', selectedPhase == PHASE_OPTION_SELECTION || util.reviewOptions);
    masterRoot.SetHasClass('review_selection', util.reviewOptions);
    masterRoot.SetHasClass('phase_option_voting_selected', selectedPhase == PHASE_OPTION_VOTING);
    masterRoot.SetHasClass('phase_banning_selected', selectedPhase == PHASE_BANNING);
    masterRoot.SetHasClass('phase_selection_selected', selectedPhase == PHASE_SELECTION && !util.reviewOptions);
    masterRoot.SetHasClass('phase_all_random_selected', selectedPhase == PHASE_RANDOM_SELECTION);
    masterRoot.SetHasClass('phase_drafting_selected', selectedPhase == PHASE_DRAFTING);
    masterRoot.SetHasClass('phase_review_selected', selectedPhase == PHASE_REVIEW);
    $('#backtrackBtn').SetHasClass('hidden', selectedPhase != PHASE_SELECTION);
    $('#backtrackBtnTxt').text = $.Localize('reviewOptions');
}

// Return X:XX time (M:SS)
function getFancyTime(timeNumber) {
    // Are we dealing with a negative number?
    if(timeNumber >= 0) {
        // Nope, EZ
        var minutes = Math.floor(timeNumber / 60);
        var seconds = timeNumber % 60;

        if(seconds < 10) {
            seconds = '0' + seconds;
        }

        return minutes + ':' + seconds;
    } else {
        // Yes, use normal function, add a negative
        return '-' + getFancyTime(timeNumber * -1);
    }

}

//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
var updateTimerCounter = 0;
function UpdateTimer() {
    /*var gameTime = Game.GetGameTime();
    var transitionTime = Game.GetStateTransitionTime();

    CheckForHostPrivileges();

    var mapInfo = Game.GetMapInfo();
    $( "#MapInfo" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

    if ( transitionTime >= 0 )
    {
        $( "#StartGameCountdownTimer" ).SetDialogVariableInt( "countdown_timer_seconds", Math.max( 0, Math.floor( transitionTime - gameTime ) ) );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", true );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", false );
    }
    else
    {
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", false );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", true );
    }

    var autoLaunch = Game.GetAutoLaunchEnabled();
    $( "#StartGameCountdownTimer" ).SetHasClass( "auto_start", autoLaunch );
    $( "#StartGameCountdownTimer" ).SetHasClass( "forced_start", ( autoLaunch == false ) );*/

    // Allow the ui to update its state based on team selection being locked or unlocked
    $('#mainSelectionRoot').SetHasClass('teams_locked', Game.GetTeamSelectionLocked());
    $('#mainSelectionRoot').SetHasClass('teams_unlocked', Game.GetTeamSelectionLocked() == false);

    // Container to place the time into
    var placeInto = $('#lodTimeRemaining');

    if(placeInto != null) {
        // Workout how long is left
        var timeLeft = currentPhase == PHASE_INGAME ? Math.ceil(Game.GetDOTATime( false, true )) : Math.ceil(endOfTimer - Game.Time());

        // Freeze timer
        if(freezeTimer != -1) {
            timeLeft = freezeTimer;
        }

        // Place the text
        placeInto.text = getFancyTime(timeLeft);

        // Text to show in the timer
        var theTimerText = ''

        // Make it more obvious how long is left
        if(freezeTimer != -1) {
            lastTimerShow = -1;
        } else {
            // Set how long is left
            theTimerText = getFancyTime(timeLeft);

            if(timeLeft <= 15 && !pickedAHero && currentPhase == PHASE_SELECTION && !restrictedToHeroSelection && !isAllRandomGamemode()) {
                theTimerText += '\n' + $.Localize('lodPickAHero');

            //     restrictToHeroSelection()
            // } else if (pickedAHero) {
            //     undoRestriction();
            }

            var shouldShowTimer = false;

            if(lastTimerShow == -1) {
                // Timer was frozen, show the time
                shouldShowTimer = true;
            } else {
                if(timeLeft < lastTimerShow) {
                    shouldShowTimer = true;
                }
            }

            // Remove warning on ingame timer
            shouldShowTimer &= currentPhase != PHASE_INGAME;

            // Should we show the timer?
            if(shouldShowTimer) {
                // Work out how long to show for
                var showDuration = 3;
                // QUICKER DEBUGGING CHANGE
                if (Game.IsInToolsMode()) {
                    showDuration = 0.5
                }

                // Calculate when the next show should occur
                if(timeLeft <= 30) {
                    // Always show
                    showDuration = timeLeft;

                    lastTimerShow = 0;
                } else {
                    // Show once every 30 seconds
                    lastTimerShow = Math.floor((timeLeft-1) / 30) * 30 + 1
                }

                $('#lodTimeRemaining').SetHasClass('showLodWarningTimer', true);

                // Used to fix timers disappearing at hte wrong time
                var myUpdateNumber = ++updateTimerCounter;

                $.Schedule(showDuration, function() {
                    // Ensure there wasn't another timer scheduled
                    if(myUpdateNumber != updateTimerCounter) return;

                    $('#lodTimeRemaining').SetHasClass('showLodWarningTimer', false);
                });
            }
        }

        if (isBoosterDraftGamemode()) {
            try {
                $("#boosterDraftBoosters").Children()[$("#boosterDraftBoosters").Children().length-1].FindChildTraverse("lodBoosterPackLabel").text = placeInto.text;
            } catch (err) {}
        }

        // Review override
        if(currentPhase == PHASE_REVIEW && waitingForPrecache) {
            $("#reviewReadyButton").enabled = false;
        }
        else if (currentPhase == PHASE_REVIEW) {
            // Show vs
            $("#reviewPhaseVS").AddClass('show');

            // Show abilities
            var radiantPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
            for(var i = 0; i < radiantPlayers.length; ++i)
                $("#reviewPlayer" + radiantPlayers[i]).FindChild("reviewPhasePlayerSkillContainer").AddClass('show');

            // Show abilities
            var direPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
            for(var i = 0; i < direPlayers.length; ++i)
                $("#reviewPlayer" + direPlayers[i]).FindChild("reviewPhasePlayerSkillContainer").AddClass('show');

            $("#reviewReadyButton").GetChild(0).text = $.Localize('continueFast');
            $("#reviewReadyButton").enabled = true;
        }
    }

    if ($.GetContextPanel().isIngameBuilder) {
        placeInto.text = "∞";
    }

    if ($.GetContextPanel().isInitialIngameBuilder) {
        placeInto.text = parent.FindChildTraverse("GameTime").text;
    }

    $.Schedule(0.1, UpdateTimer);
}

// Player has accepting the hosting message
function onAcceptPopup() {
    if (LOCAL_WARNING) {

    } else {
        $('#lodPopupMessage').visible = false;
        $('#lodOptionsRoot').SetHasClass("darkened", false);
        $('#tipPanel').SetHasClass("darkened", false);
    }
}

// Shows a popup message to a player
function showPopupMessage(msg) {
    $('#lodPopupMessageLabel').text = $.Localize(msg);

    if (LOCAL_WARNING) {
        $('#lodPopupMessageAcceptContainer').visible = false;
        $('#lodPopupMessageLabel').SetHasClass("large", true);
    }

    // QUICKER DEBUGGING CHANGE - Only show pops in non-tools mode
    if (!Game.IsInToolsMode()) {
        $('#lodPopupMessage').visible = true;
        $('#lodOptionsRoot').SetHasClass("darkened", true);
        $('#tipPanel').SetHasClass("darkened", true);
    }

    for (var k in $("#lodPopupMessageImage").Children()) {
        $("#lodPopupMessageImage").Children()[k].visible = false;
    }
    try {
        $("#lodPopupMessageImage").FindChildTraverse(msg).visible = true;
    } catch (err) {

    }
}

function showQuestionMessage(data) {
    var oldHost = data.oldHost;
    var newHost = data.newHost;
    var playerInfo = Game.GetPlayerInfo(newHost);
    $('#lodPopupQuestionLabel').text = 'Are you sure want to make player ' + playerInfo.player_name + ' the host of the game?'
    $('#lodPopupQuestion').visible = true
    $('#questionYes').SetPanelEvent('onactivate', function(){
        GameEvents.SendCustomGameEventToServer('lodChangeHost', {
            oldHost: oldHost,
            newHost: newHost});
        $('#lodPopupQuestion').visible = false;
    });
    $('#questionNo').SetPanelEvent('onactivate', function(){
        $('#lodPopupQuestion').visible = false;
    });
}

function OnChangeLock(data) {
    var command = data.command;
    switch (command) {
        case 'assign':
            onAutoAssignPressed();
            break;
        case 'shuffle':
            onShufflePressed();
            break
        case 'lock':
            onLockPressed();
            break;
        case 'unlock':
            onUnlockPressed();
            break;
    }
}

// Switch between basic and advanced options
function switchOptions() {
    if ($('#optionBasic').BHasClass('hide')) {
        $('#optionBasic').RemoveClass('hide');
        $('#optionAdvanced').RemoveClass('show');

        $('#optionAdvancedSwitcherPanel').RemoveClass('hide');
        $('#optionBasicSwitcherPanel').RemoveClass('show');
    }
    else {
        $('#optionBasic').AddClass('hide');
        $('#optionAdvanced').AddClass('show');

        $('#optionAdvancedSwitcherPanel').AddClass('hide');
        $('#optionBasicSwitcherPanel').AddClass('show');
    }
}

// Gamemodes scroller
function gamemodesScroll(direction) {
    if ($('#gamemodesContainer').num == undefined)
        $('#gamemodesContainer').num = 0;

    var childCount = $('#scroller').GetChildCount();


    var dir = direction == 'right' ? -1 : 1;
    if (childCount + $('#gamemodesContainer').num + dir == 0 ||
        $('#gamemodesContainer').num + dir > 0)
            return;

    $('#gamemodesContainer').num += dir;
    $('#scroller').style.transform = 'translateX(' + $('#gamemodesContainer').num / childCount * 100 * $('#scroller').actuallayoutwidth / $('#gamemodesContainer').actuallayoutwidth  + '%);';
}

// Show panel
function showMainPanel() {
    if ($('#mainSelectionRoot').BReadyForDisplay()) {
        $('#mainSelectionRoot').AddClass('show');
        $('#tipPanel').AddClass('show');
        return;
    }

    $.Schedule(0.1, showMainPanel);
}

function recordPlayerBans() {
    GameEvents.SendCustomGameEventToServer('lodSaveBans', {});
}

function loadPlayerBans() {
    GameEvents.SendCustomGameEventToServer('lodLoadBans', {});
}

function SaveOptions() {
    if (saveSCTimer) return true;
    saveSCTimer = true;
    $('#importAndExportSaveButton').SetHasClass("disableButtonHalf", true);
    $.Schedule(30.0, function () {
        saveSCTimer = false;
        $('#importAndExportSaveButton').SetHasClass("disableButtonHalf", false);
    })

    GameEvents.SendCustomGameEventToServer('stats_client_options_save', { content: JSON.stringify(optionValueList) });
    addNotification({ text: 'importAndExport_success_save' });
}

function LoadOptions() {
    GameEvents.SendCustomGameEventToServer('stats_client_options_load', {});
}

GameEvents.Subscribe('lodLoadOptions', LoadOptionsHandler);
function LoadOptionsHandler(data) {
    var content = JSON.parse(data.content);
    if (content.lodOptionGamemode) setOption('lodOptionGamemode', content.lodOptionGamemode);
    if (content.lodDisabledItems) LoadDisabledItems(content.lodDisabledItems);

    var changed = false;
    for(var key in content) {
        $.Msg(key, content[key]);
        if(key === 'lodOptionGamemode' || key === 'lodDisabledItems') continue;
        setOption(key, content[key]);

        if (optionValueList[key] != content[key]) {
            changed = true;
        }
    }
    addNotification({"text" : changed ? 'importAndExport_success' : 'importAndExport_no_changes'});
    if (content.lodOptionCommonDraftAbilities) setOption('lodOptionCommonDraftAbilities', content.lodOptionCommonDraftAbilities);
}

function addVotingOption(name) {
    var panel = $.CreatePanel("Panel", $("#optionVotePhasesList"), "");
    panel.BLoadLayoutSnippet("optionVotePhase");
    panel.SetDialogVariable("title", $.Localize("option_vote_entry_title_" + name));
    panel.FindChildTraverse("optionVoteNo").SetPanelEvent("onactivate", function() {
        castVote(name, false, panel);
    });
    panel.FindChildTraverse("optionVoteYes").SetPanelEvent("onactivate", function() {
        castVote(name, true, panel);
    });
    var VotingOptionInfo = panel.FindChildTraverse("VotingOptionInfo")
    VotingOptionInfo.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("UIShowCustomLayoutParametersTooltip", VotingOptionInfo, "voteOptionInfoTooltip", "file://{resources}/layout/custom_game/custom_tooltip.xml", "text=" + $.Localize("option_vote_entry_info_" + name));
    });
    panel.UpdateVotes = function(info) {
        info = [
            info[0] || 0,
            info[1] || 0
        ];
        panel.FindChildTraverse("voteCountNo").text = "(" + info[0] + ")";
        panel.FindChildTraverse("voteCountYes").text = "(" + info[1] + ")";
        var voteCount = info[0] + info[1];
        var votePercentages = [];
        var largestPercentage = 0;
        for (var i = 0; i <= 1; i++) {
            votePercentages[i] = Math.round((info[i] / voteCount) * 100);
            if (votePercentages[i] >= votePercentages[largestPercentage]) {
                largestPercentage = i;
            }
        }
        if (name == "customAbilities") {
            if (votePercentages[1] < 100) {
                votePercentages[1] = 0;
                votePercentages[0] = 100;
            }
        }
        $.Each([panel.FindChildTraverse("voteCountNoPercentage"), panel.FindChildTraverse("voteCountYesPercentage")], function(countLabel, index) {
            countLabel.text = votePercentages[index] + "%";
            countLabel.style.color = voteCount == 0 ? "white" : (i == largestPercentage ? "#0BB416" : "grey");
        });
    };
    VotingOptionPanels[name] = panel;
}

function castVote(category, choice, panel){
    var noBtn = panel.FindChildTraverse("optionVoteNo");
    noBtn.SetHasClass("optionCurrentlySelected", !choice)
    var yesBtn = panel.FindChildTraverse("optionVoteYes");
    yesBtn.SetHasClass("optionCurrentlySelected", choice)

    noBtn.RemoveClass("makeThePlayerNoticeThisButton");
    yesBtn.RemoveClass("makeThePlayerNoticeThisButton");
    GameEvents.SendCustomGameEventToServer("lodCastVote", {
        optionName: category,
        optionValue: choice
    });
}

function SetBalanceModePoints(value) {
    currentBalance = value;
    constantBalancePointsValue = value;
    $('#balanceModePointsPreset').SetDialogVariableInt( 'points', currentBalance );
    $('#balanceModePointsHeroes').SetDialogVariableInt( 'points', currentBalance );
    $('#balanceModePointsSkills').SetDialogVariableInt( 'points', currentBalance );
}

function onVotingOpenCallback() {
    $("#lodOptionsRoot").style.blur = "gaussian( 2.5 );";
}

function onVotingCloseCallback() {
    $("#lodOptionsRoot").style.blur = "none;";
}

function saveCurrentBuildToggleWindow(state) {
    var context = $.GetContextPanel()
    inBuildSaveMode = state == null ? !inBuildSaveMode : state
    if (inBuildSaveMode) {
        var mainPanel = $('#pickingPhaseTabs');
        $.Each(mainPanel.Children(), function(panelTab) {
            panelTab.visible = false;
        });
        $("#pickingPhaseSaveCurrentBuild").visible = true;
    } else {
        showBuilderTab(currentTab)
    }
}

function saveCurrentBuild() {
    CreateSkillBuild($("#pickingPhaseSaveCurrentBuildTitle").text, $("#pickingPhaseSaveCurrentBuildDescription").text)
    saveCurrentBuildToggleWindow(false)
}

function getAbilityGlobalPickPopularity(ability) {
    return AbilityUsageData.global[ability] == null ? 1 : AbilityUsageData.global[ability];
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function() {
    //$( "#mainTeamContainer" ).SetAcceptsFocus( true ); // Prevents the chat window from taking focus by default

    /*var teamsListRootNode = $( "#TeamsListRoot" );

    // Construct the panels for each team
    for ( var teamId of Game.GetAllTeamIDs() )
    {
        var teamNode = $.CreatePanel( "Panel", teamsListRootNode, "" );
        teamNode.AddClass( "team_" + teamId ); // team_1, etc.
        teamNode.SetAttributeInt( "team_id", teamId );
        teamNode.BLoadLayout( "file://{resources}/layout/custom_game/team_select_team.xml", false, false );

        // Add the team panel to the global list so we can get to it easily later to update it
        g_TeamPanels.push( teamNode );
    }*/

    $.GetContextPanel().onVotingOpenCallback = onVotingOpenCallback;
    $.GetContextPanel().onVotingCloseCallback = onVotingCloseCallback;

    // Grab the map's name
    var mapName = Game.GetMapInfo().map_display_name;

    if (mapName == "overthrow") {

    }

    // Should we use option voting?
    var useOptionVoting = false;

    // All Pick Only
    if(mapName == 'all_pick' || mapName == 'all_pick_fast' || mapName == 'mirror_draft' || mapName == 'all_random') {
        useOptionVoting = true;
    }

    // Bots
    $.GetContextPanel().SetHasClass('disallow_bots', mapName !== 'custom_bot');

    // Are we on a map that allocates slots for us?
    if(mapName == '3_vs_3' || mapName == '5_vs_5') {
        // Disable max slots voting
        $.GetContextPanel().SetHasClass('veryBasicVoting', true);
        useOptionVoting = true;
    }

    //useOptionVoting = false;

    // Apply option voting related CSS
    if(useOptionVoting) {
        // Change to option voting interface
        $.GetContextPanel().SetHasClass('option_voting_enabled', true);
    }

    GameEvents.Subscribe("lodSinglePlayer", function () {
        $.GetContextPanel().isSinglePlayer = true;
    })

    GameEvents.Subscribe("lodRestrictToHeroSelection", function () {
        restrictToHeroSelection();
    })

    // Automatically assign players to teams.
    Game.AutoAssignPlayersToTeams();

    // Start updating the timer, this function will schedule itself to be called periodically
    UpdateTimer();

    // Build the basic options categories
    var mutatorList = buildBasicOptionsCategories();

    // Build the advanced options categories
    buildAdvancedOptionsCategories(mutatorList);

    // Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
    $.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

    // Register a listener for the event which is broadcast whenever a player attempts to pick a team
    $.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

    // Hook stuff
    hookAndFire('phase_pregame', OnPhaseChanged);
    hookAndFire('options', OnOptionChanged);
    hookAndFire('heroes', OnHeroDataChanged);
    hookAndFire('flags', OnFlagDataChanged);
    hookAndFire('selected_heroes', OnSelectedHeroesChanged);
    hookAndFire('selected_attr', OnSelectedAttrChanged);
    hookAndFire('selected_skills', OnSelectedSkillsChanged);
    hookAndFire('banned', OnSkillBanned);
    hookAndFire('ready', OnGetReadyState);
    hookAndFire('random_builds', OnGetRandomBuilds);
    //hookAndFire('selected_random_builds', OnSelectedRandomBuildChanged);
    hookAndFire('draft_array', OnGetDraftArray);
    //Run out of nettables
    GameEvents.SendCustomGameEventToServer("lodRequestAbilityPerkData", {})
    GameEvents.Subscribe("lodRequestAbilityPerkData", function(data) {
        AbilityPerks = data;
    })

    GameUI.CustomUIConfig().hookSkillInfo = hookSkillInfo;

    // Listen for notifications
    GameEvents.Subscribe('lodNotification', function(data) {
        addNotification(data);
    });

    GameEvents.Subscribe('lodShowPopup', function(data) {
        showQuestionMessage(data);
    });

    GameEvents.Subscribe('lodChangeLock', function(data) {
        OnChangeLock(data);
    });

    GameEvents.Subscribe('lodOnHostChanged', function(data) {
        OnHostChanged(data);
    });

    GameEvents.Subscribe('lodCustomTimer', function (data) {
        endOfTimer = data.endTime;
        freezeTimer = data.freezeTimer ? data.freezeTimer : -1;
    })

    GameEvents.Subscribe('lodGameSetupPingEffect', function (data) {
        if (data.type == "hero") {
            heroPanelMap[data.originalContent].RemoveClass("quickHighlight")
            heroPanelMap[data.originalContent].AddClass("quickHighlight");
        } else if (data.type == "ability") {
            abilityStore[data.originalContent].RemoveClass("quickHighlight");
            abilityStore[data.originalContent].AddClass("quickHighlight");
        }
        Game.EmitSound("Redux.Ping")
    })

    // Search handler
    setTabsSearchHandler();

    // Preload heroes
    GameEvents.Subscribe('lodPreloadHeroPanel', function(data) {
        if (!preloadedHeroPanels[data.heroName]) {
            var heroImage = $.CreatePanel('Panel', $.GetContextPanel(), 'reviewPhaseHeroImageLoader');

            heroImage.BLoadLayoutFromString('<root><Panel><DOTAScenePanel particleonly="false" style="width: 300px; height: 800px; opacity-mask: url(\'s2r://panorama/images/masks/softedge_box_png.vtex\');" unit="' + data.heroName + '"/></Panel></root>', false, false);
            heroImage.AddClass("avatarScene");

            heroImage.visible = false;

            preloadedHeroPanels[data.heroName] = heroImage;
        }
    });

    // Update filters
    GameEvents.Subscribe('updateFilters', function(data) {
        updateRecommendedBuildFilters();
        calculateFilters();
    });

    // Add Troll Combos
    GameEvents.Subscribe('addTrollCombo', function(data) {
       var ab1 = data.ab1;
       var ab2 = data.ab2;

       // Break if it's the same
       if (ab1 == ab2) return;

       trollCombos[ab1] = trollCombos[ab1] || {};
       trollCombos[ab2] = trollCombos[ab2] || {};

       trollCombos[ab1][ab2] = true;
       trollCombos[ab2][ab1] = true;
    });

    GameEvents.Subscribe('lodReloadBuilds', function() {
        $.Each($('#recommendedBuildContainerScrollWrapper').Children(), function(p) {
            p.RemoveAndDeleteChildren();
        });
        LoadBuilds();
    });

    GameEvents.Subscribe('lodConnectAbilityUsageData', function(data) {
        AbilityUsageData = data;
    });
    GameEvents.SendCustomGameEventToServer('lodConnectAbilityUsageData', {});

    // Backtrack Review Option Button
    util.reviewOptionsChange = function(review) {
        fixBacktrackUI();
    };

    // Hook tab changes
    hookTabChange('pickingPhaseHeroTab', OnHeroTabShown);
    hookTabChange('pickingPhaseSkillTab', OnSkillTabShown);
    hookTabChange('pickingPhaseMainTab', OnMainSelectionTabShown);

    // Setup the tabs
    setupBuilderTabs();

    // Make input boxes nicer to use
    $('#mainSelectionRoot').SetPanelEvent('onactivate', focusNothing);

    // Toggle the show taken abilities button to be on
    $('#lodToggleButton').checked = true;

    // Toggle the hero grouping button
    $('#buttonHeroGrouping').checked = true;

    // Show banned abilities by default
    $('#buttonShowBanned').checked = false;

    var columnSwitch = true;
    // Show all tier values by default
    for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
        var currToggle = $( '#buttonShowTier' + (i + 1) );
        var column = (i < GameUI.AbilityCosts.TIER_COUNT / 2)? 'Left':'Right';
        var notColumn = (column === 'Left')? 'Right':'Left';
        var switchColumns = false
        if (columnSwitch && column === 'Right') {
            switchColumns = true;
            columnSwitch = false;
        }

        showTier[i] = true;
        currToggle.checked = true;
        currToggle.SetHasClass('balanceModeFilter' + column, true);
        currToggle.SetHasClass('balanceModeFilter' + notColumn, false);
        currToggle.SetHasClass('balanceModeColumnSwitch', switchColumns);
    }

    // Set Balance Mode points to default
    SetBalanceModePoints(constantBalancePointsValue)

    // Do an initial update of the player team assignment
    OnTeamPlayerListChanged();

    $.GetContextPanel().doActualTeamUpdate = doActualTeamUpdate;
    $.GetContextPanel().showBuilderTab = showBuilderTab;

    // Start tips
    startTips($("#tipPanel"));

    // Play appear animation when panel ready
    showMainPanel();

    $('#chat').BLoadLayout('file://{resources}/layout/custom_game/game_setup/chat.xml', false, false);

    if (mapName == "classic"){
        $.Each(["allPick", "OPAbilities", "noInvis", "customAbilities"], function(name) {
            addVotingOption(name);
        })
    }

    if (mapName == "all_allowed" || mapName == "overthrow"){
        $.Each(["noInvis", "banning", "antirat", "OPAbilities", "customAbilities"], function(name) {
            addVotingOption(name);
        })
    }

    var votings = $.CreatePanel('Panel', $.GetContextPanel(), '');
    votings.BLoadLayout('file://{resources}/layout/custom_game/ingame_votings.xml', false, false);

    parent.FindChildTraverse("PreGame").FindChildTraverse("HeroGrid").visible = false;
    parent.FindChildTraverse("PreGame").FindChildTraverse("HeroPickControls").visible = false;
    parent.FindChildTraverse("PreGame").FindChildTraverse("EnterGameRepickButton").visible = false;
    // parent.FindChildTraverse("PreGame").FindChildTraverse("EnterGameReRandomButton").visible = false;

    var calculateFiltersDebounced = util.debounce(function() {
        calculateFilters();
    }, 0.3);
    var popularityFilterValue = $('#popularityFilterValue');
    popularityFilterSlider.min = 1;
    popularityFilterSlider.max = 100;
    popularityFilterSlider.value = 100;

    var updateSliderFromNumberEntry = (function() {
        popularityFilterSlider.value = popularityFilterValue.value;
        calculateFiltersDebounced();
    });
    addInputChangedEvent(popularityFilterValue.FindChildTraverse('TextEntry'), updateSliderFromNumberEntry);
    popularityFilterValue.FindChildTraverse('IncrementButton').SetPanelEvent('onactivate', function() {
        popularityFilterValue.value++;
        updateSliderFromNumberEntry();
    });
    popularityFilterValue.FindChildTraverse('DecrementButton').SetPanelEvent('onactivate', function() {
        popularityFilterValue.value--;
        updateSliderFromNumberEntry();
    });
    popularityFilterDropDown.SetPanelEvent('oninputsubmit', function() {
        calculateFilters();
    });

    hookSliderChange(popularityFilterSlider, function(panel, newValue) {
        popularityFilterValue.value = newValue;
        calculateFiltersDebounced();
    }, function() {
        calculateFilters();
    });

    if (LOCAL_WARNING) {
        showPopupMessage('lodLocalWarning');
    }
})();

