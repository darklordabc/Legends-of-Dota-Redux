"use strict";
var cheat_list = [
	{
		name: 'com_lvl_up_1',
		command: 'lvl_up',
		value: 1,
		isCustom: true,
	},
	{
		name: 'com_lvl_bots_1',
		command: 'dota_bot_give_level 1',
	},
	{
		name: 'com_lvl_max',
		command: 'lvl_up',
		value: 100,
		isCustom: true,
	},
	{
		name: 'com_gold_max',
		command: 'give_gold',
		value: 999999,
		isCustom: true,
	},
	{
		name: 'com_refresh',
		command: 'dota_hero_refresh',
	},
	{
		name: 'com_respawn',
		command: 'hero_respawn',
		isCustom: true,
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
		command: 'create_item',
		value: 'item_travel_boots',
		isCustom: true,
	},
	{
		name: 'com_item_2',
		command: 'create_item',
		value: 'item_heart',
		isCustom: true,
	},
	{
		name: 'com_item_3',
		command: 'create_item',
		value: 'item_radiance',
		isCustom: true,
	},
	{
		name: 'com_item_4',
		command: 'create_item',
		value: 'item_blink',
		isCustom: true,
	},
	{
		name: 'com_item_5',
		command: 'create_item',
		value: 'item_bloodstone',
		isCustom: true,
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
	{
		name: 'com_host_scale_normal',
		command: 'host_timescale 1',
	},
	{
		name: 'com_host_scale_5',
		command: 'host_timescale 5',
	},
];

var playersCount;
var isCheatsEnabled;

function displayCheats(){
	$('#cheatsDisplay').SetHasClass('cheatsDisplayHidden', !$('#cheatsDisplay').BHasClass('cheatsDisplayHidden'));
}

function onActivate(id){
	var cheatID = null;
	for (var i in cheat_list){
		if (cheat_list[i].name == id)
		{
			cheatID = i;
			break;
		}
	}
	var command = cheat_list[cheatID].command;
	var value = cheat_list[cheatID].value;
	var isCustom = cheat_list[cheatID].isCustom;
	GameEvents.SendCustomGameEventToServer('lodOnCheats', {
		command: command,
		value: value,
		isCustom: isCustom,
		playerID: Players.GetLocalPlayer(),
		status: 'ok',
	});
	if(value !== undefined && isCustom === undefined){
		cheat_list[cheatID].value = !value;
	}
}

function setupCheats(data){
	playersCount = data.players;
	isCheatsEnabled = (data.cheats == 1) ? true : false;
	if (isCheatsEnabled){
		for (var cheat in cheat_list){
			var cheatButton = $("#"+cheat_list[cheat].name);
			var value = cheat_list[cheat].value;
			if(value !== undefined) {
				cheatButton.SetAttributeString('value', value.toString());
			}
		}
	}
	if (playersCount == 1 || isCheatsEnabled){
		$('#cheatsContainer').AddClass('visible');
	}
}

GameEvents.Subscribe( "lodOnCheats", displayCheats );
GameEvents.Subscribe('lodShowCheatPanel', setupCheats);