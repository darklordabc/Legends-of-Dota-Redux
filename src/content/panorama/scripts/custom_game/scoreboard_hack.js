function InitPlayer(panel) {
	$.Schedule(0.5, function () {
		InitPlayer(panel);
	})
	if (panel) {
		var playerId = parseInt((panel.id.match(/\d/g)).join(""));

		var heroEntity = Players.GetPlayerHeroEntityIndex( playerId );

		var abilitiesPanel = panel.FindChildTraverse("HeroAbilities");
		var skillsPanel = panel.FindChildTraverse("Skills");
		var talentsPanel = panel.FindChildTraverse("Talents");

		if (!abilitiesPanel) {
			abilitiesPanel = $.CreatePanel("Panel", panel, "HeroAbilities");
			abilitiesPanel.style.height = "100%;";
			abilitiesPanel.style.width = "200px;";
			abilitiesPanel.style.flowChildren = "down;";

			skillsPanel = $.CreatePanel("Panel", abilitiesPanel, "Skills");
			skillsPanel.style.height = "50%;";
			skillsPanel.style.marginTop = "1px;";
			skillsPanel.style.flowChildren = "right;";
			skillsPanel.style.horizontalAlign = "center;";

			talentsPanel = $.CreatePanel("Panel", abilitiesPanel, "Talents");
			talentsPanel.style.height = "50%;";
			talentsPanel.style.marginBottom = "1px;";
			talentsPanel.style.flowChildren = "right;";
			talentsPanel.style.horizontalAlign = "center;";

			panel.MoveChildAfter(abilitiesPanel, panel.FindChildTraverse("PlayerAndHeroNameContainer"))
		}

		for (var i = 0; i < Entities.GetAbilityCount(heroEntity); i++) {
			(function () {
				var ability = Entities.GetAbility(heroEntity, i);
				var abilityName = Abilities.GetAbilityName(ability);
				var abilityPanelID = "_" + abilityName;

				var abilityPanel = abilitiesPanel.FindChildTraverse(abilityPanelID);

				if (abilityName && (!abilityName.match("special_bonus") || Abilities.GetLevel(ability) > 0)) {
					if (Abilities.IsHidden(ability) == false && !abilityPanel) {

						abilityPanel = $.CreatePanel("DOTAAbilityImage", abilityName.match("special_bonus") && Abilities.GetLevel(ability) > 0 ? talentsPanel : skillsPanel, abilityPanelID);
						abilityPanel.abilityname = abilityName;

						abilityPanel.style.width = "25px;";
						abilityPanel.style.height = "25px;";
						abilityPanel.style.padding = "1px;";
						// abilityPanel.style.verticalAlign = "center;";

						abilityPanel.SetPanelEvent('onmouseover', function(){
							$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityPanel, abilityName, 0 );
						});
						abilityPanel.SetPanelEvent('onmouseout', (function(){
							$.DispatchEvent( "DOTAHideAbilityTooltip", abilityPanel );
						}));
					} else if (Abilities.IsHidden(ability) == true && abilityPanel) {
						abilityPanel.DeleteAsync(0.0);
					}
				}
			})();
		}
	}
}

(function () {
	$.Schedule(5.0, function () {
		var parent = $.GetContextPanel().GetParent();
		while(parent.id != "Hud")
			parent = parent.GetParent();

		parent.FindChildTraverse("scoreboard").FindChildTraverse("SharedContent").style.marginLeft = "542px;";
		parent.FindChildTraverse("scoreboard").FindChildTraverse("SharedUnitControl").style.marginLeft = "650px;";
		parent.FindChildTraverse("scoreboard").FindChildTraverse("TeamInventories").style.marginLeft = "650px;";

		var radiantHeader = parent.FindChildTraverse("scoreboard").FindChildTraverse("RadiantHeader");
		if (!radiantHeader.FindChildTraverse("AbilitiesLabel")) {
			var abilitiesHeader = $.CreatePanel("Label", radiantHeader, "AbilitiesLabel");
			abilitiesHeader.SetHasClass("SubheaderDesc", true);
			abilitiesHeader.style.width = "200px;";
			abilitiesHeader.style.paddingRight = "23px;";
			abilitiesHeader.text = "ABILITIES";
			radiantHeader.MoveChildAfter(abilitiesHeader, radiantHeader.FindChildTraverse("RadiantTeamLabel"))
		}

		for (var i = 0; i < 23; i++) {
			InitPlayer(parent.FindChildTraverse("scoreboard").FindChildTraverse("RadiantPlayer"+i))
		}

		for (var i = 0; i < 23; i++) {
			InitPlayer(parent.FindChildTraverse("scoreboard").FindChildTraverse("DirePlayer"+i))
		}
	})
})();