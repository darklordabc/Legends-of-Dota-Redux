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
		command: 'dota_dev hero_maxlevel',
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
		command: 'dota_create_item item_travel_boots',
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
	{
		name: 'com_spawn_enemy',
		command: 'dota_create_unit axe enemy',
	},
	{
		name: 'com_spawn_roshan',
		command: 'dota_create_unit npc_dota_roshan',
	},
	{
		name: 'com_spawn_friendly',
		command: 'dota_create_unit axe friendly',
	},
	{
		name: 'com_gold_bots',
		command: 'dota_bot_give_gold 1000',
	},
];

function toggleCheats(){
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
}


function onActivate(id){
	var cheatID = null;
	for (var i in cheat_list) {
		if (cheat_list[i].name == id)
		{
			cheatID = i;
			break;
		}
	}
	var command = cheat_list[cheatID].command;
	var value = cheat_list[cheatID].value;
	GameEvents.SendCustomGameEventToServer('lodOnCheats', {
		command: command,
		value: value,
	});
	if(value !== undefined){
		cheat_list[cheatID].value = !value;
	}
}

function setupCheats(data){
	for (var cheat in cheat_list) {
		var cheatButton = $("#"+cheat_list[cheat].name);
		cheatButton.text = $.Localize(cheat_list[cheat].name+"_Description");
		var value = cheat_list[cheat].value;
		if(value !== undefined) {
			cheatButton.SetAttributeString('value', value.toString());
		}
	}
	$('#cheatsContainer').AddClass('visible');
}


GameEvents.Subscribe('lodShowCheatPanel', setupCheats);