// Store build data to send to the server
$.GetContextPanel().isFavorite = false;
var buildData = null;

// Tags for filter
var searchTags = [];

function setBuildData(makeHeroSelectable, hookSkillInfo, makeSkillSelectable, build, balanceMode) {
    var buildVariant = balanceMode === 1 ? build.Balanced : build.Unbalanced;

    // Get abilities array from JSON string
    var curBuild = JSON.parse(buildVariant.replace(/'/g, '"'))
    // Push skills
    for(var slotID = 0; slotID < 6; ++slotID) {
        var slot = $('#recommendedSkill' + (slotID + 1));

        // Make it selectable and show info
        makeSkillSelectable(slot);
        hookSkillInfo(slot);

        if(curBuild[slotID]) {
            slot.visible = true;
            slot.abilityname = curBuild[slotID];
            slot.SetAttributeString('abilityname', curBuild[slotID]);
        } else {
            slot.visible = false;
        }

        // Add abilities names
        searchTags.push($.Localize('DOTA_Tooltip_ability_' + slot.abilityname).toLowerCase());
    }

    // Set hero image
    var heroImageCon = $('#recommendedHeroImage');
    heroImageCon.heroname = build.Hero;
    heroImageCon.SetAttributeString('heroName', build.Hero);
    makeHeroSelectable(heroImageCon);

    // Add hero name
    searchTags.push($.Localize(build.Hero).toLowerCase());

    // Set the title
    var titleLabel = $('#buildName');
    if(build.Title != null) {
        titleLabel.text = $.Localize(build.Title);
        titleLabel.visible = true;

        // Add title
        searchTags.push(titleLabel.text.toLowerCase());
    } else {
        titleLabel.visible = false;
    }

    $('#buildDesc').text = $.Localize(build.Description); 

    // Set hero attribute
    var attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_strength.psd';
    if(build.Attr == 'agi') {
        attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_agility.psd';
    } else if(build.Attr == 'int') {
        attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_intelligence.psd';
    }

    $('#recommendedAttribute').SetImage(attrImage);

    // Renum items from 0-5 to 1-6 for server functions
    var buildForSend = {};
    for(var slotID = 0; slotID < 6; ++slotID)
        buildForSend[slotID + 1] = curBuild[slotID];

    // Store the build data
    buildData = {
        hero: build.Hero,
        attr: build.Attr,
        build: buildForSend,
        id: build.ID
    };

    $.GetContextPanel().buildID = build.ID;
}

// When the build is selected
function onSelectBuildPressed() {
    // Prevent reloading issues
    if(buildData == null) return;

    // Push it to the server
    GameEvents.SendCustomGameEventToServer('lodSelectBuild', buildData);
}

function setFavorite( flag ) {
    $.GetContextPanel().isFavorite = flag;
    $('#recommendedBuildFavourite').SetHasClass('active', flag);
}

function onClickFav() {
    setFavorite( !$.GetContextPanel().isFavorite );
}

// Does filtering on the abilities
function updateFilters(getSkillFilterInfo, getHeroFilterInfo) {
    if(buildData == null) return;

    // Grab the build
    var build = buildData.build;

    // Filter each ability
    for(var slotID = 1; slotID < 7; ++slotID) {
        // Grab the slot
        var slot = $('#recommendedSkill' + slotID);

        // Grab the filter info
        var abilityName = build[slotID];
        var filterInfo = getSkillFilterInfo(abilityName);

        // Apply the filter info
        slot.SetHasClass('disallowedSkill', filterInfo.disallowed);
        slot.SetHasClass('bannedSkill', filterInfo.banned);
        slot.SetHasClass('takenSkill', filterInfo.taken);
        slot.SetHasClass('notDraftable', filterInfo.cantDraft);
        slot.SetHasClass('trollCombo', filterInfo.trollCombo);

        if (GameUI.AbilityCosts.balanceModeEnabled) {
            // Set the label to the cost of the ability
            var abCost = slot.GetChild(0);
            if (abCost) {
                for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
                    abCost.SetHasClass('tier' + (i + 1), filterInfo.cost == GameUI.AbilityCosts.TIER[i]);
                }
                abCost.text = (filterInfo.cost != GameUI.AbilityCosts.NO_COST)? filterInfo.cost: "";
            }
        }
    }

    // Update hero
    var heroFilterInfo = getHeroFilterInfo(buildData.hero);
    var heroImageCon = $('#recommendedHeroImage');
    heroImageCon.SetHasClass('should_hide_this_hero', !heroFilterInfo.shouldShow);
    heroImageCon.SetHasClass('takenHero', heroFilterInfo.takenHero);
}

function updateSearchFilter( searchStr ) {
    if (searchStr == '' || searchStr == undefined || searchStr == null)
        $.GetContextPanel().visible = true;

    $.GetContextPanel().visible = searchTags.filter(function(tag){
        return tag.indexOf(searchStr) != -1;
    }).length > 0;
}

// When this panel loads
(function()
{
	// Grab the main panel
	var mainPanel = $.GetContextPanel();

    // Add the events
    mainPanel.setBuildData = setBuildData;
    mainPanel.updateFilters = updateFilters;
    mainPanel.setFavorite = setFavorite;
    mainPanel.onClickFav = onClickFav;
    mainPanel.updateSearchFilter = updateSearchFilter;
})();
