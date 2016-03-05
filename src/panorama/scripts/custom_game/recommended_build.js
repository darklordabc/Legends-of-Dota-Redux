// Store build data to send to the server
var buildData = null;

function setBuildData(hookSkillInfo, makeSkillSelectable, hero, build, attr, title) {
    // Push skills
    for(var slotID=1; slotID<=6; ++slotID) {
        var slot = $('#recommendedSkill' + slotID);

        // Make it selectable and show info
        makeSkillSelectable(slot);
        hookSkillInfo(slot);

        if(build[slotID]) {
            slot.visible = true;
            slot.abilityname = build[slotID];
            slot.SetAttributeString('abilityname', build[slotID]);
        } else {
            slot.visible = false;
        }
    }

    // Set hero image
    $('#recommendedHeroImage').heroname = hero;

    // Set the title
    var titleLabel = $('#buildName');
    if(title != null) {
        titleLabel.text = title;
        titleLabel.visible = true;
    } else {
        titleLabel.visible = false;
    }

    // Set hero attribute
    var attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_strength.psd';
    if(attr == 'agi') {
        attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_agility.psd';
    } else if(attr == 'int') {
        attrImage = 'file://{images}/primary_attribute_icons/primary_attribute_icon_intelligence.psd';
    }

    $('#recommendedAttribute').SetImage(attrImage);

    // Store the build data
    buildData = {
        hero: hero,
        attr: attr,
        build: build
    };
}

// When the build is selected
function onSelectBuildPressed() {
    // Prevent reloading issues
    if(buildData == null) return;

    // Push it to the server
    GameEvents.SendCustomGameEventToServer('lodSelectBuild', buildData);
}

// When this panel loads
(function()
{
	// Grab the main panel
	var mainPanel = $.GetContextPanel();

    // Add the events
    mainPanel.setBuildData = setBuildData;
})();
