var talentsTable = {};
var talents = {};
const TalCols = 4;
const TalRows = 2;
var talentPopup;

function StoreTalents(data) {
	talentsTable = data;

	var parentPanel = $.GetContextPanel();
	if (talentPopup) {
		talentPopup.DeleteAsync(0);
	}
	talentPopup = $.CreatePanel("Panel", parentPanel, "talent_popup");
	talentPopup.AddClass("PopupTaletsPanel");

	//drawing loops
	var counter = 0;
	for (var i = 0; i < TalCols; i++) {
		var col = AddTalentCol(talentPopup, i);
		var t = talentsTable[i + 1];
		var count = 1;
		var picked = 1;
		for (var talentName in t) {
			if (t.hasOwnProperty(talentName)) {
				var test_button = AddTalentButton(count, t[talentName], talentName, col);
				if (talents !== undefined && talents[i] !== undefined) {
					if (talents[i].indexOf(talentName) != -1) {
						test_button.AddClass("TalentButtonSelected" + picked);
						picked++;
					}
				}
				count++;
			}
		}
	}

	DrawCloseButton(talentPopup);
}

function AddTalentCol(parent, id) {
	var talentCol = $.CreatePanel("Panel", parent, "talent_col" + id);
	talentCol.AddClass("TalentCol");

	var levelBG = $.CreatePanel("Panel", talentCol, "TalentLevelBG" + id);
	levelBG.AddClass("LevelBG");
	var talentText = $.CreatePanel("Label", levelBG, "TalentLevelBGText" + id);
	talentText.AddClass("ReqLabel");
	talentText.text = 10 + id * 5;

	return talentCol;
}

function AddTalentButton(id, talentData, talentName, parent, bHeader) {
	var talentButton = $.CreatePanel("Panel", parent, talentName);
	talentButton.AddClass("TalentEntry");
	var talentIcon = $.CreatePanel("DOTAAbilityImage", talentButton, "talent_icon_" + id);
	talentIcon.abilityname = talentData["AbilityName"];
	talentIcon.AddClass("TalentImg");
	var talentText = $.CreatePanel("Label", talentButton, "talent_text_" + id);
	talentText.AddClass("TalentLabel");

	if (bHeader === true) {
		talentText.style.fontSize = 30;
		talentText.text = $.Localize(talentName);
	} else {
		const localizedString = $.Localize("#DOTA_Tooltip_ability_" + talentName, $.GetContextPanel());
		if (localizedString.includes("[!s:value]")) {
			talentText.text = localizedString.replace("[!s:value]", talentData["TalentValue"]);
		} else {
			talentText.text = localizedString;
		}
		talentText.talentName = talentName;
	}

	//tooltip definition
	var tooltipDescriptionKey = "#DOTA_Tooltip_ability_" + talentName + "_Description";
	var tooltipDescriptionLocalized = $.Localize(tooltipDescriptionKey);
	//tooltip check
	if ("#" + tooltipDescriptionLocalized != tooltipDescriptionKey) {
		talentButton.SetPanelEvent("onmouseover", function () {
			$.DispatchEvent("DOTAShowTextTooltip", talentButton, tooltipDescriptionLocalized);
		});
		talentButton.SetPanelEvent("onmouseout", function () {
			$.DispatchEvent("DOTAHideTextTooltip");
		});
	}

	if (!bHeader) {
		//button click code
		talentButton.SetPanelEvent("onactivate", function () {
			SetTalentButtonSelectedStyle(talentButton);
		});
	}
	return talentButton;
}

function DrawCloseButton(parent) {
	var closeButton = $.CreatePanel("Panel", parent, "talent_close");
	closeButton.AddClass("TalentCloseButton");
	closeButton.SetPanelEvent("onactivate", function () {
		//CLICK CLOSE BUTTON CODE HERE
		//getting selected talents
		for (var i = 0; i < TalCols; i++) {
			talents[i] = [];
			var panel = parent.FindChildTraverse("talent_col" + i);
			$.Each(panel.Children(), function (oPanel) {
				if (oPanel.BHasClass("TalentButtonSelected1") || oPanel.BHasClass("TalentButtonSelected2")) {
					talents[i].push(oPanel.id);
				}
			});
		}
		GameEvents.SendCustomGameEventToServer("send_picked_talents", talents);
		parent.DeleteAsync(0);
		talentPopup = null;
	});
}

function ShowTalentChanger() {
	//define columns and rows count
	GameEvents.SendCustomGameEventToServer("request_available_talents", {});
}

function SetTalentButtonSelectedStyle(talentButton) {
	var parent_col = talentButton.GetParent();

	if (talentButton.BHasClass("TalentButtonSelected1")) {
		talentButton.RemoveClass("TalentButtonSelected1");

		$.Each(parent_col.Children(), function (bPanel) {
			if (bPanel.BHasClass("TalentButtonSelected2")) {
				bPanel.RemoveClass("TalentButtonSelected2");
				bPanel.AddClass("TalentButtonSelected1");
			}
		});
		return;
	}
	if (talentButton.BHasClass("TalentButtonSelected2")) {
		talentButton.RemoveClass("TalentButtonSelected2");
		return;
	}

	//deselect others

	$.Each(parent_col.Children(), function (oPanel) {
		if (oPanel != talentButton) {
			if (oPanel.BHasClass("TalentButtonSelected1")) {
				oPanel.AddClass("TalentButtonSelected2");
			} else {
				oPanel.RemoveClass("TalentButtonSelected2");
			}
			oPanel.RemoveClass("TalentButtonSelected1");
		}
	});
	talentButton.AddClass("TalentButtonSelected1");
}

GameEvents.Subscribe("send_viable_talents", StoreTalents);
