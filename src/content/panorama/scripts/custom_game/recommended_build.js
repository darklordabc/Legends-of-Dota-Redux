// Store build data to send to the server
$.GetContextPanel().isFavorite = false;
var buildData = null;

// Tags for filter
var searchTags = [];

function setBuildData(makeHeroSelectable, hookSkillInfo, makeSkillSelectable, build, constantBalancePointsValue) {
    var curBuild = build.abilities
    $.GetContextPanel().constantBalancePointsValue = constantBalancePointsValue;
    // Push skills
    for(var slotID = 0; slotID < 6; slotID++) {
        var slot = $('#recommendedSkill' + (slotID + 1));

        // Make it selectable and show info
        makeSkillSelectable(slot);

        if (curBuild[slotID]) {
            slot.visible = true;
            slot.abilityname = curBuild[slotID];
            slot.SetAttributeString('abilityname', curBuild[slotID]);
        } else {
            slot.visible = false;
        }

        hookSkillInfo(slot);

        // Add abilities names
        searchTags.push($.Localize('DOTA_Tooltip_ability_' + slot.abilityname).toLowerCase());
    }
    // Set hero image
    var heroImageCon = $('#recommendedHeroImage');
    heroImageCon.heroname = build.heroName;
    heroImageCon.SetAttributeString('heroName', build.heroName);
    makeHeroSelectable(heroImageCon);

    // Add hero name
    searchTags.push(build.heroName.toLowerCase());
    searchTags.push($.Localize(build.heroName).toLowerCase());
    searchTags.push(build.description.toLowerCase());

    // Add tags
    for (var v of build.tags) {
        searchTags.push($.Localize(v).toLowerCase());
    }

    // Set the title
    var titleLabel = $('#buildName');
    titleLabel.visible = build.title != null;

    if(build.title != null) {
        titleLabel.text = build.title;
        // Add title
        searchTags.push(build.title.toLowerCase());
    }

    $('#buildDesc').text = build.description;

    // Set hero attribute
    var attrImage = build.attribute == 'int' ? 'file://{images}/primary_attribute_icons/primary_attribute_icon_intelligence.psd' : build.attribute == 'agi' ? 'file://{images}/primary_attribute_icons/primary_attribute_icon_agility.psd' : 'file://{images}/primary_attribute_icons/primary_attribute_icon_strength.psd';

    $('#recommendedAttribute').SetImage(attrImage);

    // Renum items from 0-5 to 1-6 for server functions
    var buildForSend = {};
    for(var slotID = 0; slotID < 6; ++slotID)
        buildForSend[slotID + 1] = curBuild[slotID];

    //author
    var authorSteamID = build.steamID;
    var localSteamID = Game.GetLocalPlayerInfo().player_steamid
    $.GetContextPanel().SetHasClass("isLocalAuthor", authorSteamID == localSteamID)
    if (authorSteamID != -1) {
        $("#buildAuthor").steamid = authorSteamID;
    } else {
        $("#buildAuthor").text = "";
    }

    //Votes
    $("#buildRating").text = build.votes;
    $.GetContextPanel().SetHasClass("votedUp", build.votes_up.indexOf(localSteamID) !== -1)
    $.GetContextPanel().SetHasClass("votedDown", build.votes_down.indexOf(localSteamID) !== -1)

    // Store the build data
    buildData = {
        hero: build.heroName,
        attr: build.attribute,
        build: buildForSend,
        id: build._id
    };
    $.GetContextPanel().buildID = build._id;
}

// When the build is selected
function onSelectBuildPressed() {
    // Prevent reloading issues
    if(buildData == null) return;

    // Push it to the server
    GameEvents.SendCustomGameEventToServer('lodSelectBuild', buildData);
}

function setFavorite(flag) {
    $.GetContextPanel().isFavorite = flag;
    $('#recommendedBuildFavourite').SetHasClass('active', flag);
}

function onClickFav() {
    var flag = !$.GetContextPanel().isFavorite;
    setFavorite(flag);
    
    GameEvents.SendCustomGameEventToServer("stats_client_fav_skill_build", {
        id: $.GetContextPanel().buildID,
        fav: flag
    })
}

function removeBuild() {
    $("#recommendedBuildRemove").visible = false;
    GameEvents.SendCustomGameEventToServer("stats_client_remove_skill_build", {
        id: $.GetContextPanel().buildID
    })
}

function onSelectBuildVote(vote) {
    var newVotes = Number($("#buildRating").text);
    if ($.GetContextPanel().BHasClass("votedUp")) {
        if (vote > 0) return; newVotes--; vote = 0;
    } else if ($.GetContextPanel().BHasClass("votedDown")) {
        if (vote < 0) return; newVotes++; vote = 0;
    } else
        newVotes += vote;
    $.GetContextPanel().SetHasClass("votedUp", vote > 0)
    $.GetContextPanel().SetHasClass("votedDown", vote < 0)

    $("#buildRating").text = newVotes;

    GameEvents.SendCustomGameEventToServer("stats_client_vote_skill_build", {
        id: $.GetContextPanel().buildID,
        vote: vote
    })
}

// Does filtering on the abilities
function updateFilters(getSkillFilterInfo, getHeroFilterInfo) {
    if(buildData == null) return;

    // Grab the build
    var build = buildData.build;

    // Unavaliable skill count
    var unavalCount = 0;
    var totalBuildCost = 0;

    // Filter each ability
    for(var slotID = 1; slotID <= 6; ++slotID) {
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

        if (filterInfo.disallowed || filterInfo.banned || filterInfo.taken || filterInfo.cantDraft || filterInfo.trollCombo)
            unavalCount++;
        else if (GameUI.AbilityCosts.balanceModeEnabled)
            totalBuildCost += filterInfo.cost

        if (GameUI.AbilityCosts.balanceModeEnabled) {
            // Set the label to the cost of the ability
            var abCost = slot.GetChild(0);
            if (abCost) {
                for (var i = 0; i < GameUI.AbilityCosts.TIER_COUNT; ++i) {
                    abCost.SetHasClass('tier' + (i + 1), filterInfo.cost == GameUI.AbilityCosts.TIER[i]);
                }
                abCost.text = filterInfo.cost != GameUI.AbilityCosts.NO_COST ? filterInfo.cost : "";
            }
        }

        if (typeof($.GetContextPanel().balanceMode) === "boolean") {
            var abCost = slot.GetChild(0);
            if (abCost) {
                abCost.visible = $.GetContextPanel().balanceMode;
            }
        }
    }

    // Hide build if more than 1 unavaliable skill or it wasn't designed for balance mode
    $.GetContextPanel().SetHasClass('disabled', unavalCount > 1 || totalBuildCost > $.GetContextPanel().constantBalancePointsValue);

    // Update hero
    var heroFilterInfo = getHeroFilterInfo(buildData.hero);
    var heroImageCon = $('#recommendedHeroImage');
    heroImageCon.SetHasClass('should_hide_this_hero', !heroFilterInfo.shouldShow);
    heroImageCon.SetHasClass('takenHero', heroFilterInfo.takenHero);
}

function updateSearchFilter(searchStr) {
    var regexp = new RegExp(searchStr, 'i');
    $.GetContextPanel().SetHasClass('searchFilterHide', !(!searchStr || searchTags.some(function(tag) {
        return tag.search(regexp) > -1;
    })) );
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
