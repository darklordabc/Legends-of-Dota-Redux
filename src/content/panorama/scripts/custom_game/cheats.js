"use strict";

var util = GameUI.CustomUIConfig().Util;

var currentMenu;

var CommandProperties = {}
var commandList = [{
	title: "votes",
	commands: [{
		title: "voteEnableCheat",
		chatCommand: "enablecheat",
	}, {
		title: "voteEnableBuilder",
		chatCommand: "enablebuilder",
	}, {
		title: "voteEnableRespawn",
		chatCommand: "enablerespawn",
	},{
		title: "voteEnableKamikaze",
		chatCommand: "enablekamikaze",
	}, ]
}, {
	title: "game",
	isCheat: true,
	commands: [{
		title: "toggleWtf",
		chatCommand: "wtfmenu",
		isCheat: true,
	}, {
		title: "toggleAllVision",
		consoleCommand: "dota_all_vision",
		"getArgs": function() {
			CommandProperties.toggleAllVision = !(CommandProperties.toggleAllVision || false);
			return CommandProperties.toggleAllVision ? 1 : 0;
		},
		isCheat: true,
	}, {
		title: "startGame",
		consoleCommand: "dota_start_game",
		isCheat: true,
	}, {
		title: "spawnNeutrals",
		consoleCommand: "dota_spawn_neutrals",
		isCheat: true,
	}, {
		title: "spawnUnit",
		consoleCommand: "dota_create_unit",
		"getArgs": function(settings) {
			return settings.GetChild(0).GetSelected().id + (settings.GetChild(1).checked ? " enemy" : " friendly");
		},
		customXmlPanel: "<root><Panel><DropDown>\
				<Label text='Axe' id='axe'/>\
				<Label text='Roshan' id='npc_dota_roshan'/>\
			</DropDown><ToggleButton text='Enemy' /></Panel></root>",
		isCheat: true,
	}, {
		title: "setTimescale",
		consoleCommand: "host_timescale",
		"getArgs": function(settings) {
			return settings.GetChild(0).value
		},
		customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='10'/></Panel></root>",
		isCheat: true,
	},]	
}, {
	title: "bots",
	isCheat: true,
	commands: [{
		title: "botsShowMode",
		chatCommand: "bot mode",
	},{
		title: "botsSwitchMode",
		chatCommand: "bot switch",
		isCheat: true,
	},{
		title: "botsLevelUp",
		consoleCommand: "dota_bot_give_level",
		"getArgs": function(settings) {
			return settings.GetChild(0).value
		},
		customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='100'/></Panel></root>",
		isCheat: true,
	}, {
		title: "botsGiveGold",
		consoleCommand: "dota_bot_give_gold",
		"getArgs": function(settings) {
			return settings.GetChild(0).value
		},
		customXmlPanel: "<root><Panel><NumberEntry value='999999' min='1' max='999999'/></Panel></root>",
		isCheat: true,
	}]
}, {
	title: "player",
	isCheat: true,
	commands: [{
		title: "refresh",
		consoleCommand: "dota_hero_refresh",
		isCheat: true,
	}, {
		title: "respawn",
		chatCommand: "respawn",
		isCheat: true,
	}, {
		title: "godMode",
		chatCommand: "god",
		isCheat: true,
	}, {
		title: "regen",
		chatCommand: "regen",
		isCheat: true,
	},{
		title: "scepter",
		chatCommand: "scepter",
		isCheat: true,
	},{
		title: "dagger",
		chatCommand: "dagger",
		isCheat: true,
	},  {
		title: "selfLevelUp",
		chatCommand: "lvlup",
		"getArgs": function(settings) {
			return settings.GetChild(0).value
		},
		customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='100'/></Panel></root>",
		isCheat: true,
	}, {
		title: "selfGiveGold",
		chatCommand: "gold",
		"getArgs": function(settings) {
			return settings.GetChild(0).value;
		},
		customXmlPanel: "<root><Panel><NumberEntry value='999999' min='1' max='999999'/></Panel></root>",
		isCheat: true,
	}, {
		title: "selfGetItem",
		consoleCommand: "dota_create_item",
		"getArgs": function(settings) {
			return settings.GetChild(0).GetSelected().id;
		},
		customXmlPanel: "<root><Panel><DropDown>\
				<Label text='Boots of Travel' id='item_travel_boots'/>\
				<Label text='Heart of Tarrasque' id='item_heart'/>\
				<Label text='Radiance' id='item_radiance'/>\
				<Label text='Blink Dagger' id='item_blink'/>\
				<Label text='Bloodstone' id='item_bloodstone'/>\
			</DropDown></Panel></root>",
		isCheat: true,
	}, ]
}];

function createCommandPanel(data, root) {
	var panel = $.CreatePanel("Panel", root, "");
	panel.BLoadLayoutSnippet("command");
	panel.SetDialogVariable("command_title", $.Localize("command_menu_command_" + data.title));
	panel.SetPanelEvent("onmouseover", function () {
		$.Schedule(3.0, function () {
			if (panel.BHasHoverStyle()) {
				var description = $.Localize("command_menu_command_descr_" + data.title);
				if (description == ("command_menu_command_descr_" + data.title)) {
					description = "";
				}
				$.DispatchEvent('DOTAShowTitleTextTooltip', panel.FindChildTraverse("commandSettings"), $.Localize("command_menu_command_" + data.title), description);
			}
		})
	});
	panel.SetPanelEvent("onmouseout", function () {
		$.DispatchEvent('DOTAHideTitleTextTooltip');
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
	$.Each(data.commands, function(info) {
		createCommandPanel(info, panel.FindChildTraverse("groupContents"));
	})
	var groupHeader = panel.FindChildTraverse("groupHeader")
	groupHeader.SetPanelEvent("onactivate", function() {
		panel.SetHasClass("GroupCollapsed", !groupHeader.checked);
		if (!groupHeader.checked) {
			panel.FindChildTraverse("groupContents").style.height = "0px;";
		} else {
			panel.FindChildTraverse("groupContents").style.height = panel.FindChildTraverse("groupContents").tempHeight + "px;";;
		}

		if (currentMenu) {
			$.Msg("Asd");
			currentMenu.FindChildTraverse("groupHeader").checked = !currentMenu.FindChildTraverse("groupHeader").checked;
			currentMenu.SetHasClass("GroupCollapsed", !currentMenu.FindChildTraverse("groupHeader").checked);
			if (!currentMenu.FindChildTraverse("groupHeader").checked) {
				currentMenu.FindChildTraverse("groupContents").style.height = "0px;";
			} else {
				currentMenu.FindChildTraverse("groupContents").style.height = currentMenu.FindChildTraverse("groupContents").tempHeight + "px;";;
			}
		}

		currentMenu = panel;
	})

	$.Schedule(0.5, function () {
		panel.FindChildTraverse("groupContents").tempHeight = panel.FindChildTraverse("groupContents").contentheight;
		panel.FindChildTraverse("groupContents").style.height = "0px;";
	})
}

GameEvents.Subscribe("lodOnCheats", function() {
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
});
GameEvents.Subscribe('lodShowCheatPanel', function(data) {
	$.GetContextPanel().SetHasClass("cheatMode", data.cheats == 1 || data.players == 1);
});
$("#commandList").RemoveAndDeleteChildren();
$.Each(commandList, createCommandGroup);

util.blockMouseWheel($("#changelogDisplay"));
util.blockMouseWheel($("#changelogNotification"));