"use strict";
var cheat_list = [
	{
		name: 'com_lvl_up_1',
		command: 'dota_hero_level 1',
	},
	{
		name: 'com_lvl_bots_1',
		command: 'dota_bot_give_level 1',
	},
	{
		name: 'com_lvl_max',
		command: 'dota_hero_level 100',
	},
	{
		name: 'com_gold_max',
		command: 'dota_give_gold 999999',
	},
	{
		name: 'com_refresh',
		command: 'dota_hero_refresh',
	},
	{
		name: 'com_respawn',
		command: 'dota_hero_respawn',
	},
	{
		name: 'com_start_game',
		command: 'dota_start_game',
	},
	{
		name: 'com_spawn_neutrals',
		command: 'dota_spawn_neutrals',
	},
	{
		name: 'com_wtf_unwtf',
		command: 'dota_ability_debug',
		value: true,
	},
	{
		name: 'com_vision',
		command: 'dota_all_vision',
		value: true,
	},
	// {
	// 	name: 'com_teleport',
	// 	command: '-teleport',
	// 	type: 'int',
	// 	value: '1',
	// },
	{
		name: 'com_item_1',
		command: 'dota_create_item item_travel_boots_1',
	},
	{
		name: 'com_item_2',
		command: 'dota_create_item item_heart',
	},
	{
		name: 'com_item_3',
		command: 'dota_create_item item_radiance',
	},
	{
		name: 'com_item_4',
		command: 'dota_create_item item_blink',
	},
];

var isCreated = false;

function showCheatPanel(data){
	$('cheatsRoot').SetAttributeString('hidden', 'false')
}

function toggleCheats(){
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
}


function onClick(id){
	var cheatButton = $('#'+id);
	var command = cheatButton.GetAttributeString('command', '');
	var value = cheatButton.GetAttributeString('value', '');
	GameEvents.SendCustomGameEventToServer('lodOnCheats', {
		command: command,
		value: value,
	});
	if(value != ''){
		value = (value !== 'true');
		cheatButton.SetAttributeString('value', value.toString());
	}
}



(function (){
		GameEvents.Subscribe('lodShowCheatPanel', function(data) {
	        showCheatPanel(data);
	    });
	for (var cheat in cheat_list) {
		var cheatButton = $.CreatePanel('TextButton', $('#cheatsDisplay'), cheat_list[cheat].name);
		cheatButton.AddClass('PlayButton');
		cheatButton.text = $.Localize(cheat_list[cheat].name+"_Description");
		cheatButton.SetAttributeString('command', cheat_list[cheat].command);
		cheatButton.SetPanelEvent('onactivate', function (){
			onClick(cheat_list[cheat].name)
		});
		var value = cheat_list[cheat].value;
		if(value !== undefined) {
			cheatButton.SetAttributeString('value', value.toString());
		}
	}

})();