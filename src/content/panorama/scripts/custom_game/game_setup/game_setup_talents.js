var talentsTable = {}
var talents = {}
var tal_cols = 4
var tal_rows = 2
var talent_popup

function storeTalents(data) {
	$.Msg("storeTalents")

	talentsTable= data
}
function showTalentChanger(){
	//define columns and rows count
	

	GameEvents.SendCustomGameEventToServer("request_available_talents", {});
	$.Schedule(1, function(){
		tal_cols=4
		tal_rows= Math.max(2,talentsTable["count1"],talentsTable["count2"],talentsTable["count3"],talentsTable["count4"])
	
	
	//example data
	/*talent_icons=["dark_willow_terrorize",
				"pangolier_shield_crash",
				"warlock_rain_of_chaos",
				"leshrac_split_earth",
				"invoker_sun_strike",
				"kunkka_torrent",
				"kunkka_tidebringer",
				"special_bonus_unique_warlock_1",
				"roshan_slam",
				"lina_light_strike_array"]
	talent_names=["#special_bonus_unique_warlock_1",
				"special_bonus_unique_antimage_5",
				"#special_bonus_unique_warlock_1",
				"#special_bonus_unique_warlock_1",
				"#special_bonus_unique_warlock_1",
				"#special_bonus_unique_warlock_1",
				"#special_bonus_unique_warlock_1",
				"special_bonus_unique_warlock_1",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_warlock_1",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_warlock_1",
				"special_bonus_unique_antimage_5",
				"special_bonus_unique_warlock_1",
				"special_bonus_unique_warlock_1",

				]*/


		var parentPanel=$.GetContextPanel()
		if (talent_popup) {
			talent_popup.DeleteAsync(0)
		}
		talent_popup=$.CreatePanel('Panel',parentPanel,'talent_popup')
		talent_popup.AddClass('PopupTaletsPanel')

		function addTalentCol(parent,id){
			var talent_col=$.CreatePanel('Panel',parent,'talent_col'+id)
			talent_col.AddClass('TalentCol')
			addTalentButton(0,"special_bonus_unique_antimage_3",10 + id * 5,talent_col,true)
			return talent_col
		}

		function addTalentButton(id,iconName,text,parent,bHeader){
			var talentButton=$.CreatePanel('Panel',parent,text)
			talentButton.AddClass('TalentEntry')
			var talentIcon = $.CreatePanel('DOTAAbilityImage', talentButton, 'talent_icon_' + id)
			talentIcon.abilityname = iconName
			talentIcon.AddClass('TalentImg')
			var talentText = $.CreatePanel('Label', talentButton, 'talent_text_' + id)
			talentText.AddClass("TalentLabel")
			if (bHeader === true) {
				talentText.style.fontSize = 30
				talentText.text=$.Localize(text)
			} else {
				talentText.text=$.Localize('#DOTA_Tooltip_ability_'+text)
				talentText.talentName = text
			}

			//tooltip definition
			var tooltip_var = '#DOTA_Tooltip_ability_'+text+"_Description"
			var tooltip_localed=$.Localize(tooltip_var)
			//tooltip check
			if ("#"+tooltip_localed!=tooltip_var) {
				talentButton.SetPanelEvent(
					"onmouseover", 
					function() {
						$.DispatchEvent("DOTAShowTextTooltip", talentButton, tooltip_localed);
					}
				)
				talentButton.SetPanelEvent(
					"onmouseout",
					function() {
						$.DispatchEvent("DOTAHideTextTooltip");
					}
				)
			}

			if (!bHeader) {
				//button click code
				talentButton.SetPanelEvent (
					"onactivate", 
					function() {
						SetTalentButtonSelectedStyle(talentButton)
					}

				)

				
			}
			return talentButton
		}
		function drawCloseButton(parent){
			var closeButton=$.CreatePanel('Panel',parent,'talent_close')
			closeButton.AddClass('TalentCloseButton')
			closeButton.SetPanelEvent (
			"onactivate", 
				function() {
					

					//CLICK CLOSE BUTTON CODE HERE
					//getting selected talents
					for (var i = 0; i < tal_cols; i++) {
						talents[i] = []
						var panel = parent.FindChildTraverse("talent_col"+i)
						$.Each(panel.Children(), function( oPanel ) {
							if (oPanel.BHasClass('TalentButtonSelected1') || oPanel.BHasClass('TalentButtonSelected2')) {
								talents[i].push(oPanel.id) 
							}
						})
					}
					GameEvents.SendCustomGameEventToServer("send_picked_talents", talents);
					parent.DeleteAsync(0)
					talent_popup = null
				}
			)
		}

		//drawing loops
		var counter=0
		for (var i = 0; i < tal_cols; i++) {
			var test_col=addTalentCol(talent_popup,i)
			var t = talentsTable[(i+1)]
			var count = 1
			var picked = 1
			for (var talentName in t){
			    if (t.hasOwnProperty(talentName)) {
			        var test_button=addTalentButton(count,t[talentName],talentName,test_col)
			        if (talents !== undefined && talents[i] !== undefined) {
				       	if (talents[i].indexOf(talentName) != -1) {
				       		test_button.AddClass("TalentButtonSelected"+picked)
				       		picked++
				       	}
				    }
			        count++
			    }
			}

			/*for (var j = 0; j < tal_rows; j++) {
				var test_button=addTalentButton(counter,talentsTable[toString(i)][j],ar[j],test_col)
				counter+=1;
			}*/
		}

		drawCloseButton(talent_popup)
	});
	
}


function SetTalentButtonSelectedStyle(talentButton) {

	var parent_col=talentButton.GetParent()

	if (talentButton.BHasClass('TalentButtonSelected1')) {
		talentButton.RemoveClass('TalentButtonSelected1')

		$.Each(parent_col.Children(), function( bPanel ){
			if (bPanel.BHasClass('TalentButtonSelected2')) {
				bPanel.RemoveClass('TalentButtonSelected2')
				bPanel.AddClass("TalentButtonSelected1")
			}
		})
		return;
	}
	if (talentButton.BHasClass('TalentButtonSelected2')) {
		talentButton.RemoveClass('TalentButtonSelected2')
		return;
	}

	//deselect others
	
	$.Each(parent_col.Children(), function( oPanel ){
		if (oPanel!=talentButton) {
			if (oPanel.BHasClass('TalentButtonSelected1')) {
				oPanel.AddClass("TalentButtonSelected2")
			} else {
				oPanel.RemoveClass('TalentButtonSelected2')
			}
			oPanel.RemoveClass('TalentButtonSelected1')
		}
	});
	talentButton.AddClass("TalentButtonSelected1")
}

GameEvents.Subscribe("send_viable_talents", storeTalents);


