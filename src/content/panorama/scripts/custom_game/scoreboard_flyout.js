var PlayerPanels = [];
var TeamPanels = [];
var SharedControlPanels = [];
var teamColors = {};
teamColors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#008000"
teamColors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#FF0000"
var team_names = {}
team_names[DOTATeam_t.DOTA_TEAM_GOODGUYS] = $.Localize("#DOTA_GoodGuys")
team_names[DOTATeam_t.DOTA_TEAM_BADGUYS] = $.Localize("#DOTA_BadGuys")
team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = $.Localize("#DOTA_Custom1")
team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = $.Localize("#DOTA_Custom2")
var Util = GameUI.CustomUIConfig().Util;
var DOTA_TEAM_SPECTATOR = -1;

function Snippet_SharedControlPlayer(pid) {
	if (SharedControlPanels[pid] == null) {
		var panel = $.CreatePanel("Panel", $("#PlayersContainer"), "");
		panel.BLoadLayoutSnippet("SharedControlPlayer");
		panel.playerId = pid;
		var DisableHelpButton = panel.FindChildTraverse("DisableHelpButton")
		DisableHelpButton.SetDialogVariable("player_name", Players.GetPlayerName(pid))
		DisableHelpButton.SetPanelEvent("onactivate", function() {
			GameEvents.SendCustomGameEventToServer("set_help_disabled", {
				player: pid,
				disabled: DisableHelpButton.checked
			});
		})
		SharedControlPanels[pid] = panel;
	}
	return SharedControlPanels[pid];
}

function Snippet_SharedControlPlayer_Update(panel) {
	panel.visible = Players.GetTeam(panel.playerId) == Players.GetTeam(Game.GetLocalPlayerID()) && Snippet_Player(panel.playerId).visible
	panel.SetHasClass("LocalPlayer", panel.playerId == Game.GetLocalPlayerID())
}

function Snippet_Player(pid) {
	if (PlayerPanels[pid] == null) {
		var team = Players.GetTeam(pid)
		if (team != DOTA_TEAM_SPECTATOR) {
			var teamPanel = Snippet_Team(team).FindChildTraverse("TeamPlayersContainer")
			var panel = $.CreatePanel("Panel", teamPanel, "")
			panel.BLoadLayoutSnippet("Player")
			var VoiceMute = panel.FindChildTraverse("VoiceMute")
			panel.playerId = pid
			panel.SetHasClass("EmptyPlayerRow", false)
			panel.SetHasClass("LocalPlayer", pid == Game.GetLocalPlayerID())
			panel.FindChildTraverse("HeroImage").SetPanelEvent("onactivate", function() {
				Players.PlayerPortraitClicked(pid, GameUI.IsControlDown(), GameUI.IsAltDown());
			});
			VoiceMute.checked = Game.IsPlayerMuted(pid);
			VoiceMute.SetPanelEvent("onactivate", function() {
				Game.SetPlayerMuted(pid, VoiceMute.checked)
			});
			panel.Resort = function() {
				SortPanelChildren(teamPanel, dynamicSort("playerId"), function(child, child2) {
					return child.playerId < child2.playerId
				});
			}
			panel.Resort();
			PlayerPanels[pid] = panel;
		}
	}
	return PlayerPanels[pid]
}

function Snippet_Player_Update(panel) {
	var playerId = panel.playerId;
	var playerInfo = Game.GetPlayerInfo(playerId);
	var connectionState = playerInfo.player_connection_state;
	panel.visible = connectionState != DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED && connectionState != DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED;
	if (panel.visible) {
		var heroName = playerInfo.player_selected_hero;
		var respawnSeconds = playerInfo.player_respawn_seconds;
		var heroEnt = playerInfo.player_selected_hero_entity_index;
		var ScoreboardUltIndicator = panel.FindChildTraverse("ScoreboardUltIndicator")
		var ultStateOrTime = playerInfo.player_team_id == Players.GetTeam(Game.GetLocalPlayerID()) ? Game.GetPlayerUltimateStateOrTime(playerId) : PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN;
		panel.SetHasClass("UltLearned", ultStateOrTime != PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NOT_LEVELED);
		panel.SetHasClass("UltReady", ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_READY);
		panel.SetHasClass("UltReadyNoMana", ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NO_MANA);
		panel.SetHasClass("UltOnCooldown", ultStateOrTime > 0);
		panel.SetHasClass("BuybackReady", Players.CanPlayerBuyback(playerId));
		panel.SetDialogVariableInt("ult_cooldown", ultStateOrTime);
		panel.SetDialogVariableInt("kills", Players.GetKills(playerId));
		panel.SetDialogVariableInt("deaths", Players.GetDeaths(playerId));
		panel.SetDialogVariableInt("assists", Players.GetAssists(playerId));
		panel.SetDialogVariableInt("gold", Players.GetGold(playerId));
		panel.SetDialogVariableInt("level", Players.GetLevel(playerId))
		panel.FindChildTraverse("HeroImage").heroname = heroName;
		panel.FindChildTraverse("HeroNameLabel").text = $.Localize(heroName).toUpperCase();
		panel.FindChildTraverse("PlayerNameLabel").text = Players.GetPlayerName(playerId)
		panel.FindChildTraverse("AvatarImage").steamid = playerInfo.player_steamid
		panel.FindChildTraverse("PlayerColor").style.backgroundColor = Util.getHexPlayerColor(playerId);

		var currentAbilitySlot = -1
		var currentTalentSlot = -1
		var AbilityListAbilities = panel.FindChildTraverse("AbilityListAbilities")
		var AbilityListTalents = panel.FindChildTraverse("AbilityListTalents")
		for (var i = 0; i < Entities.GetAbilityCount(heroEnt); i++) {
			var ability = Entities.GetAbility(heroEnt, i)
			var abilityName = Abilities.GetAbilityName(ability)
			var isTalent = abilityName.match("special_bonus_");
			if (ability > -1 && (!isTalent || Abilities.GetLevel(ability) > 0) && !Abilities.IsHidden(ability)) {
				if (isTalent) {
					currentTalentSlot++
					var abilityPanel = AbilityListTalents.GetChild(currentTalentSlot)
					if (!abilityPanel) abilityPanel = Snippet_Ability(AbilityListTalents)
					abilityPanel.SetAbility(ability)
				} else {
					currentAbilitySlot++
					var abilityPanel = AbilityListAbilities.GetChild(currentAbilitySlot)
					if (!abilityPanel) abilityPanel = Snippet_Ability(AbilityListAbilities)
					abilityPanel.SetAbility(ability)
				}
			}
		}
		for (var i = currentAbilitySlot; i < AbilityListAbilities.GetChildCount() - 1; i++) {
			AbilityListAbilities.GetChild(i).SetAbility(-1)
		}
		for (var i = currentAbilitySlot; i < AbilityListTalents.GetChildCount() - 1; i++) {
			AbilityListTalents.GetChild(i).SetAbility(-1)
		}

		if (playerInfo.player_team_id != panel.GetParent().team && teamColors[playerInfo.player_team_id] != null) {
			panel.SetParent(Snippet_Team(playerInfo.player_team_id).FindChildTraverse("TeamPlayersContainer"))
			panel.Resort();
		}
	}
}

function Snippet_Team(team) {
	if (TeamPanels[team] == null) {
		var TeamList = $("#TeamList")
		var panel = $.CreatePanel("Panel", TeamList, "")
		panel.BLoadLayoutSnippet("Team")
		panel.team = team
		TeamPanels[team] = panel;
		panel.FindChildTraverse("TeamLabel").text = team_names[team];
		panel.FindChildTraverse("TeamLabel").style.textShadow = "0px 0px 6px 1.0 " + teamColors[team]
		panel.FindChildTraverse("TeamScoreLabel").style.textShadow = "0px 0px 6px 1.0 " + teamColors[team]
		panel.SetHasClass("FirstTeam", team == DOTATeam_t.DOTA_TEAM_GOODGUYS)

		SortPanelChildren(TeamList, dynamicSort("team"), function(child, child2) {
			return child.team < child2.team
		});
	}
	return TeamPanels[team];
}

function Snippet_Team_Update(panel) {
	var team = panel.team
	var teamDetails = Game.GetTeamDetails(team);
	var isAlly = team == Players.GetTeam(Game.GetLocalPlayerID());
	panel.SetHasClass("EnemyTeam", !isAlly);
	panel.SetDialogVariableInt("score", teamDetails.team_score);
	if (isAlly) {
		$("#SharedUnitControl").style.marginTop = Math.max(parseInt(panel.actualyoffset, 10), 0) + "px"
		$("#SharedUnitControl").style.height = panel.actuallayoutheight + "px"
	}
}

function Snippet_Ability(rootPanel) {
	var panel = $.CreatePanel("Panel", rootPanel, "")
	panel.BLoadLayoutSnippet("HeroAbility")
	panel.SetAbility = function(ability) {
		if (ability != panel.ability) {
			panel.visible = ability != -1
			panel.ability = ability
			panel.abilityname = Abilities.GetAbilityName(ability)
			panel.FindChildTraverse("HeroAbilityImage").abilityname = panel.abilityname
		}
	}
	panel.SetPanelEvent("onmouseover", function() {
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", panel, panel.abilityname, Abilities.GetCaster(panel.ability));
	})
	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideAbilityTooltip", panel);
	})
	return panel;
}

function Update() {
	$.Schedule(0.1, Update);
	var context = $.GetContextPanel();
	$.Each(Game.GetAllPlayerIDs(), function(pid) {
		var team = Players.GetTeam(pid)
		if (team != DOTA_TEAM_SPECTATOR) {
			Snippet_Player_Update(Snippet_Player(pid));
			Snippet_SharedControlPlayer_Update(Snippet_SharedControlPlayer(pid));
		}
	})
	var LocalTeam = Players.GetTeam(Game.GetLocalPlayerID())
	for (var i in TeamPanels) {
		Snippet_Team_Update(TeamPanels[i]);
	}
	context.SetHasClass("AltPressed", GameUI.IsAltDown())
}

function SetFlyoutScoreboardVisible(visible) {
	$.GetContextPanel().SetHasClass("ScoreboardClosed", !visible)
}

function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === "-") {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function(a, b) {
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	}
}

function SortPanelChildren(panel, sortFunc, compareFunc) {
	var tlc = panel.Children().sort(sortFunc)
	$.Each(tlc, function(child) {
		for (var k in tlc) {
			var child2 = tlc[k]
			if (child != child2 && compareFunc(child, child2)) {
				panel.MoveChildBefore(child, child2)
				break;
			}
		}
	});
}

function DisableHelpDataUpdate(table, key, value) {
	if (key == "disable_help_data") {
		var LocalPlayerID = Game.GetLocalPlayerID()
		if (value[LocalPlayerID] != null) {
			$.Each(value[LocalPlayerID], function(state, playerID) {
				Snippet_SharedControlPlayer(playerID).FindChildTraverse("DisableHelpButton").checked = state == 1
			})
		}
	}
}

(function() {
	var tableData = CustomNetTables.GetAllTableValues("phase_ingame")
	if (tableData != null) {
		$.Each(tableData, function(ent) {
			if (ent.key == "disable_help_data") {
				DisableHelpDataUpdate("phase_ingame", "disable_help_data", ent.value)
			}
		})
	}
	if ($.GetContextPanel().listener)
		CustomNetTables.UnsubscribeNetTableListener($.GetContextPanel().listener)
	$.GetContextPanel().listener = CustomNetTables.SubscribeNetTableListener("phase_ingame", DisableHelpDataUpdate)

	$("#TeamList").RemoveAndDeleteChildren()
	$("#PlayersContainer").RemoveAndDeleteChildren()
	Update();

	SetFlyoutScoreboardVisible(false);
	$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible);
	var debug = false;
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, debug)
	$.GetContextPanel().visible = !debug;
})();