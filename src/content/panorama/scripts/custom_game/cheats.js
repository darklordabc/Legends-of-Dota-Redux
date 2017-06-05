"use strict";

var util = GameUI.CustomUIConfig().Util;

var currentMenu;

var CommandProperties = {}

function createCommandPanel(data, root) {
	var panel = $.CreatePanel("Panel", root, "");
	panel.BLoadLayoutSnippet("command");
	panel.SetDialogVariable("command_title", $.Localize("command_menu_command_" + data.title));
	panel.SetPanelEvent("onmouseover", function () {
		$.Schedule(3.0, function () {
			if (panel.BHasHoverStyle()) {
				var description = $.Localize("command_menu_command_descr_" + data.title);
				if (description != ("command_menu_command_descr_" + data.title)) {
					$.DispatchEvent('UIShowCustomLayoutParametersTooltip', panel.FindChildTraverse("commandTitle"), panel.FindChildTraverse("commandTitle").id, "file://{resources}/layout/custom_game/custom_text_tooltip.xml", "text="+description);
					// $.DispatchEvent('DOTAShowTitleTextTooltipStyled', panel.FindChildTraverse("commandTitle"), $.Localize("command_menu_command_" + data.title), description, "testStyle");
				}
			}
		})
	});
	panel.SetPanelEvent("onmouseout", function () {
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel.FindChildTraverse("commandTitle"), panel.FindChildTraverse("commandTitle").id); 
	});
	var isCheat = data.isCheat == true;
	panel.SetHasClass("cheatOnly", isCheat);
	var commandSettings = panel.FindChildTraverse("commandSettings");
	if (data.customXmlPanel != null) {
		commandSettings.BLoadLayoutFromString(data.customXmlPanel, true, true);
	}
	panel.FindChildTraverse("commandHeader").SetPanelEvent("onactivate", function() {
		if (!isCheat || $.GetContextPanel().BHasClass("cheatMode")) {
			var args = data.getArgs != null ? data.getArgs(commandSettings) : null;
			var request = {};
			if (data.consoleCommand != null) {
				request.consoleCommand = args == null ? data.consoleCommand : data.consoleCommand + " " + args;
			}
			if (data.chatCommand != null) {
				request.command = args == null ? data.chatCommand : data.chatCommand + " " + args;
			}
			if (Object.keys(request).length !== 0) {
				GameEvents.SendCustomGameEventToServer("lodOnCheats", request);
			}
		} else {
			GameEvents.SendEventClientSide("dota_hud_error_message", {
				"splitscreenplayer": 0,
				"reason": 80,
				"message": "#command_menu_cheat_rejection"
			});
		}
	});
}

function createCommandGroup(data) {
	var panel = $.CreatePanel("Panel", $("#commandList"), "");
	panel.BLoadLayoutSnippet("commandGroup");
	var isCheat = data.isCheat == true;
	panel.SetHasClass("cheatOnly", isCheat);
	panel.SetDialogVariable("group_title", $.Localize("command_menu_group_" + data.title));
	/*if (data.image != null) {
		panel.FindChildrenWithClassTraverse("TickBox")[0].SetImage(data.image);
		panel.AddClass("groupCustomImage")
	}*/
	var groupContents = panel.FindChildTraverse("groupContents");
	$.Each(data.commands, function(info) {
		createCommandPanel(info, groupContents);
	})
	var groupHeader = panel.FindChildTraverse("groupHeader")
	groupHeader.SetPanelEvent("onactivate", function() {
		if (!groupHeader.checked) {
			panel.FindChildTraverse("groupContents").style.height = "0px;";
		} else {
			panel.FindChildTraverse("groupContents").style.height = panel.FindChildTraverse("groupContents").tempHeight + "px;";;
		}

		if (currentMenu) {
			$.Msg("Asd");
			currentMenu.FindChildTraverse("groupHeader").checked = !currentMenu.FindChildTraverse("groupHeader").checked;
			if (!currentMenu.FindChildTraverse("groupHeader").checked) {
				currentMenu.FindChildTraverse("groupContents").style.height = "0px;";
			} else {
				currentMenu.FindChildTraverse("groupContents").style.height = currentMenu.FindChildTraverse("groupContents").tempHeight + "px;";;
			}
		}

		currentMenu = panel;
	})

	var checkHeight = function() {
		if (heightResolutionFix != null && groupContents.contentheight > 0) {
			groupContents.tempHeight = groupContents.contentheight * heightResolutionFix;
			groupContents.style.height = "0px;";
		} else {
			$.Schedule(0.1, checkHeight);
		}
	}
	checkHeight();
}

function toggleCheats(arg){
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
}

GameEvents.Subscribe("lodOnCheats", function() {
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
});
GameEvents.Subscribe('lodRequestCheatData', function(data) {
	$.GetContextPanel().SetHasClass("cheatMode", data.enabled == 1);
});
GameEvents.SendCustomGameEventToServer("lodRequestCheatData", {})

$("#commandList").RemoveAndDeleteChildren();
$.Each(util.commandList, createCommandGroup);

util.blockMouseWheel($("#changelogDisplay"));
util.blockMouseWheel($("#changelogNotification"));

var heightResolutionFix;
var heightResolutionFixPanel = $.CreatePanel("Panel", $.GetContextPanel(), "");
heightResolutionFixPanel.style.height = "100px";
var checkFixPanel = function() {
	if (heightResolutionFixPanel.actuallayoutheight > 0) {
		heightResolutionFix = 100 / heightResolutionFixPanel.actuallayoutheight;
		heightResolutionFixPanel.DeleteAsync(0);
	} else {
		$.Schedule(0.1, checkFixPanel);
	}
}
checkFixPanel();