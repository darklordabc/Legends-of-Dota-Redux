"use strict";

var util = GameUI.CustomUIConfig().Util;

// Last received message time
var lastMessageTime = 0;
// Last sended message time
var lastSendedMessageTime = 0;
// Send timeout
var sendTimeout = 0.1;

var channels = { 
	'all': {
		color: 'white',
		name: '#channelAll'
	}, 
	'team': {
		color: '#749ab8',
		name: '#channelTeam'
	}
};

// Current channel params
var currentChannel = 'team';
var color = 'white';

function setChannelStyle( channel ){
	$('#channelName').text = $.Localize(channels[channel].name) + ':';
	$('#channelName').style.color = channels[channel].color;
}

// Add smile
var emotions = {
	// Standart
	':wink:': 'file://{images}/emoticons/wink.png',
	':blush:': 'file://{images}/emoticons/blush.png',
	':cheeky:': 'file://{images}/emoticons/cheeky.png',
	':cool:': 'file://{images}/emoticons/cool.png',
	':crazy:': 'file://{images}/emoticons/crazy.png',
	':cry:': 'file://{images}/emoticons/cry.png',
	':disapprove:': 'file://{images}/emoticons/disaprove.png',
	':facepalm:': 'file://{images}/emoticons/facepalm.png',
	':happytears:': 'file://{images}/emoticons/happytears.png',
	':hex:': 'file://{images}/emoticons/hex.png',
	':highfive:': 'file://{images}/emoticons/highfive.png',
	':huh:': 'file://{images}/emoticons/huh.png',
	':hush:': 'file://{images}/emoticons/hush.png',
	':laugh:': 'file://{images}/emoticons/laugh.png',
	':rage:': 'file://{images}/emoticons/rage.png',
	':sad:': 'file://{images}/emoticons/sad.png',
	':sick:': 'file://{images}/emoticons/sick.png',
	':sleeping:': 'file://{images}/emoticons/sleeping.png',
	':smile:': 'file://{images}/emoticons/smile.png',
	':surprise:': 'file://{images}/emoticons/surprise.png',

	':aaaah:': 'file://{images}/emoticons/aaaah.png',
	':aegis_2016:': 'file://{images}/emoticons/aegis_2016.png',
	':aegis2015:': 'file://{images}/emoticons/aegis2015.png',
	':angel:': 'file://{images}/emoticons/angel.png',
	':blink:': 'file://{images}/emoticons/blink.png',
	':blush_smile:': 'file://{images}/emoticons/blush_smile.png',
	':burn:': 'file://{images}/emoticons/burn.png',
	':cocky:': 'file://{images}/emoticons/cocky.png',
	':dead_eyes:': 'file://{images}/emoticons/dead_eyes.png',
	':devil:': 'file://{images}/emoticons/devil.png',
	':dice_roll:': 'file://{images}/emoticons/dice_roll.png',
	':disappear:': 'file://{images}/emoticons/disappear.png',
	':dizzy:': 'file://{images}/emoticons/dizzy.png',
	':drunk:': 'file://{images}/emoticons/drunk.png',
	':eyeroll:': 'file://{images}/emoticons/eyeroll.png',
	':fall_2016_trophy:': 'file://{images}/emoticons/fall_2016_trophy.png',
	':fall_major_2015_eaglesong:': 'file://{images}/emoticons/fall_major_2015_eaglesong.png',
	':fire:': 'file://{images}/emoticons/fire.png',
	':fuming:': 'file://{images}/emoticons/fuming.png',
	':ggdire:': 'file://{images}/emoticons/ggdire.png',
	':ggradiant:': 'file://{images}/emoticons/ggradiant.png',
	':give:': 'file://{images}/emoticons/give.png',
	':gross:': 'file://{images}/emoticons/gross.png',
	':happy:': 'file://{images}/emoticons/happy.png',
	':heal:': 'file://{images}/emoticons/heal.png',
	':heart_kiss:': 'file://{images}/emoticons/heart_kiss.png',
	':heart_smill:': 'file://{images}/emoticons/heart_smill.png',
	':hide:': 'file://{images}/emoticons/hide.png',
	':iceburn:': 'file://{images}/emoticons/iceburn.png',
	':jugg:': 'file://{images}/emoticons/jugg.png',
	':laugh_tears:': 'file://{images}/emoticons/laugh_tears.png',
	':lifestealer:': 'file://{images}/emoticons/lifestealer.png',
	':money:': 'file://{images}/emoticons/money.png',
	':naga:': 'file://{images}/emoticons/naga.png',
	':nervous:': 'file://{images}/emoticons/nervous.png',
	':no:': 'file://{images}/emoticons/no.png',
	':poop:': 'file://{images}/emoticons/poop.png',
	':recharge:': 'file://{images}/emoticons/recharge.png',
	':salty:': 'file://{images}/emoticons/salty.png',
	':snot:': 'file://{images}/emoticons/snot.png',
	':spring_2015_trophy:': 'file://{images}/emoticons/spring_2015_trophy.png',
	':stunned:': 'file://{images}/emoticons/stunned.png',
	':surprise_blush:': 'file://{images}/emoticons/surprise_blush.png',
	':tear:': 'file://{images}/emoticons/tear.png',
	':tears:': 'file://{images}/emoticons/tears.png',
	':techies:': 'file://{images}/emoticons/techies.png',
	':thinking:': 'file://{images}/emoticons/thinking.png',
	':throwgame:': 'file://{images}/emoticons/throwgame.png',
	':thumbs_down:': 'file://{images}/emoticons/thumbs_down.png',
	':thumbs_up:': 'file://{images}/emoticons/thumbs_up.png',
	':tp:': 'file://{images}/emoticons/tp.png',
	':troll:': 'file://{images}/emoticons/troll.png',
	':unicorn:': 'file://{images}/emoticons/unicorn.png',
	':winter_2016_trophy:': 'file://{images}/emoticons/winter_2016_trophy.png',
	':yolo:': 'file://{images}/emoticons/yolo.png',
	':zipper:': 'file://{images}/emoticons/zipper.png',

	// Runes
	':arcane_rune:': 'file://{images}/emoticons/arcane_rune.png',
	':bountyrune:': 'file://{images}/emoticons/bountyrune.png',
	':doubledamage:': 'file://{images}/emoticons/doubledamage.png',
	':haste:': 'file://{images}/emoticons/haste.png',
	':illusion:': 'file://{images}/emoticons/illusion.png',
	':invisibility:': 'file://{images}/emoticons/invisibility.png',
	':regeneration:': 'file://{images}/emoticons/regeneration.png',

	// BC
	':bc_emoticon_check:': 'file://{images}/emoticons/bc_emoticon_check.png',
	':bc_emoticon_eyes:': 'file://{images}/emoticons/bc_emoticon_eyes.png',
	':bc_emoticon_fire:': 'file://{images}/emoticons/bc_emoticon_fire.png',
	':bc_emoticon_flex:': 'file://{images}/emoticons/bc_emoticon_flex.png',
	':bc_emoticon_frog:': 'file://{images}/emoticons/bc_emoticon_frog.png',
	':bc_emoticon_hundred:': 'file://{images}/emoticons/bc_emoticon_hundred.png',
	':bc_emoticon_okay:': 'file://{images}/emoticons/bc_emoticon_okay.png',

	// DC
	':dcfail:': 'file://{images}/emoticons/dcfail.png',
	':dcgoodjob:': 'file://{images}/emoticons/dcgoodjob.png',
	':dcheadshot:': 'file://{images}/emoticons/dcheadshot.png',
	':dcheart:': 'file://{images}/emoticons/dcheart.png',
	':dchorse:': 'file://{images}/emoticons/dchorse.png',

	// TI 4
	':ti4copper:': 'file://{images}/emoticons/ti4copper.png',
	':ti4bronze:': 'file://{images}/emoticons/ti4bronze.png',
	':ti4silver:': 'file://{images}/emoticons/ti4silver.png',
	':ti4gold:': 'file://{images}/emoticons/ti4gold.png',
	':ti4platinum:': 'file://{images}/emoticons/ti4platinum.png',
	':ti4diamond:': 'file://{images}/emoticons/ti4diamond.png',

	// TI 5
	':blush_ti5_charm:': 'file://{images}/emoticons/blush_ti5_charm.png',
	':cheeky_ti5_charm:': 'file://{images}/emoticons/cheeky_ti5_charm.png',
	':cool_ti5_charm:': 'file://{images}/emoticons/cool_ti5_charm.png',
	':crazy_ti5_charm:': 'file://{images}/emoticons/crazy_ti5_charm.png',
	':cry_ti5_charm:': 'file://{images}/emoticons/cry_ti5_charm.png',
	':disaprove_ti5_charm:': 'file://{images}/emoticons/disaprove_ti5_charm.png',
	':facepalm_ti5_charm:': 'file://{images}/emoticons/facepalm_ti5_charm.png',
	':happytears_ti5_charm:': 'file://{images}/emoticons/happytears_ti5_charm.png',
	':highfive_ti5_charm:': 'file://{images}/emoticons/highfive_ti5_charm.png',
	':huh_ti5_charm:': 'file://{images}/emoticons/huh_ti5_charm.png',
	':hush_ti5_charm:': 'file://{images}/emoticons/hush_ti5_charm.png',
	':laugh_ti5_charm:': 'file://{images}/emoticons/laugh_ti5_charm.png',
	':onlooker_ti5_charm:': 'file://{images}/emoticons/onlooker_ti5_charm.png',
	':rage_ti5_charm:': 'file://{images}/emoticons/rage_ti5_charm.png',
	':sad_ti5_charm:': 'file://{images}/emoticons/sad_ti5_charm.png',
	':sick_ti5_charm:': 'file://{images}/emoticons/sick_ti5_charm.png',
	':sleeping_ti5_charm:': 'file://{images}/emoticons/sleeping_ti5_charm.png',
	':smile_ti5_charm:': 'file://{images}/emoticons/smile_ti5_charm.png',
	':surprise_ti5_charm:': 'file://{images}/emoticons/surprise_ti5_charm.png',
	':wink_ti5_charm:': 'file://{images}/emoticons/wink_ti5_charm.png',

	// TI 6
	':angel_ti6_charm:': 'file://{images}/emoticons/angel_ti6_charm.png',
	':chicken_ti6_charm:': 'file://{images}/emoticons/chicken_ti6_charm.png',
	':cocky_ti6_charm:': 'file://{images}/emoticons/cocky_ti6_charm.png',
	':devil_ti6_charm:': 'file://{images}/emoticons/devil_ti6_charm.png',
	':disappear_ti6_charm:': 'file://{images}/emoticons/disappear_ti6_charm.png',
	':drunk_ti6_charm:': 'file://{images}/emoticons/drunk_ti6_charm.png',
	':eyeroll_ti6_charm:': 'file://{images}/emoticons/eyeroll_ti6_charm.png',
	':fire_ti6_charm:': 'file://{images}/emoticons/fire_ti6_charm.png',
	':gross_ti6_charm:': 'file://{images}/emoticons/gross_ti6_charm.png',
	':happy_ti6_charm:': 'file://{images}/emoticons/happy_ti6_charm.png',
	':heal_ti6_charm:': 'file://{images}/emoticons/heal_ti6_charm.png',
	':hex_ti6_charm:': 'file://{images}/emoticons/hex_ti6_charm.png',
	':legion_commander_ti6_charm:': 'file://{images}/emoticons/legion_commander_t16_charm.png',
	':lifestealer_ti6_charm:': 'file://{images}/emoticons/lifestealer_ti6_charm.png',
	':monkey_king_ti6_charm:': 'file://{images}/emoticons/monkey_king_ti6_charm.png',
	':salty_ti6_charm:': 'file://{images}/emoticons/salty_ti6_charm.png',
	':snot_ti6_charm:': 'file://{images}/emoticons/snot_ti6_charm.png',
	':stunned_ti6_charm:': 'file://{images}/emoticons/stunned_ti6_charm.png',
	':thinking_ti6_charm:': 'file://{images}/emoticons/thinking_ti6_charm.png',
	':throwgame_ti6_charm:': 'file://{images}/emoticons/throwgame_ti6_charm.png',
	':tp_ti6_charm:': 'file://{images}/emoticons/tp_ti6_charm.png',
	':underlord_ti6_charm:': 'file://{images}/emoticons/underlord_ti6_charm.png',
	':yolo_ti6_charm:': 'file://{images}/emoticons/yolo_ti6_charm.png',

	// BTS
	':bts3_bristle:': 'file://{images}/emoticons/bts3_bristle.png',
	':bts3_godz:': 'file://{images}/emoticons/bts3_godz.png',
	':bts3_lina:': 'file://{images}/emoticons/bts3_lina.png',
	':bts3_merlini:': 'file://{images}/emoticons/bts3_merlini.png',
	':bts3_rosh:': 'file://{images}/emoticons/bts3_rosh.png',

	// DAC
	':dac15_blush:': 'file://{images}/emoticons/dac15_blush.png',
	':dac15_cool:': 'file://{images}/emoticons/dac15_cool.png',
	':dac15_duel:': 'file://{images}/emoticons/dac15_duel.png',
	':dac15_face:': 'file://{images}/emoticons/dac15_face.png',
	':dac15_frog:': 'file://{images}/emoticons/dac15_frog.png',
	':dac15_nosewipe:': 'file://{images}/emoticons/dac15_nosewipe.png',
	':dac15_stab:': 'file://{images}/emoticons/dac15_stab.png',
	':dac15_surprise:': 'file://{images}/emoticons/dac15_surprise.png',
	':dac15_transform:': 'file://{images}/emoticons/dac15_transform.png',

	// Arcana
	':pa_arcana_rose:': 'file://{images}/emoticons/pa_arcana_rose.png',
	':wolf_pup:': 'file://{images}/emoticons/wolf_pup.png',
	':zeus_arcana:': 'file://{images}/emoticons/zeus_arcana.png',

	// Teams
	':team_af:': 'file://{images}/emoticons/team_af.png',
	':team_af_gold:': 'file://{images}/emoticons/team_af_gold.png',
	':team_af_silver:': 'file://{images}/emoticons/team_af_silver.png',
	':team_complexity:': 'file://{images}/emoticons/team_complexity.png',
	':team_complexity_gold:': 'file://{images}/emoticons/team_complexity_gold.png',
	':team_complexity_silver:': 'file://{images}/emoticons/team_complexity_silver.png',
	':team_dc:': 'file://{images}/emoticons/team_dc.png',
	':team_dc_gold:': 'file://{images}/emoticons/team_dc_gold.png',
	':team_dc_silver:': 'file://{images}/emoticons/team_dc_silver.png',
	':team_eg:': 'file://{images}/emoticons/team_eg.png',
	':team_eg_gold:': 'file://{images}/emoticons/team_eg_gold.png',
	':team_eg_silver:': 'file://{images}/emoticons/team_eg_silver.png',
	':team_ehome:': 'file://{images}/emoticons/team_ehome.png',
	':team_ehome_gold:': 'file://{images}/emoticons/team_ehome_gold.png',
	':team_ehome_silver:': 'file://{images}/emoticons/team_ehome_silver.png',
	':team_exe:': 'file://{images}/emoticons/team_exe.png',
	':team_exe_gold:': 'file://{images}/emoticons/team_exe_gold.png',
	':team_exe_silver:': 'file://{images}/emoticons/team_exe_silver.png',
	':team_faceless:': 'file://{images}/emoticons/team_faceless.png',
	':team_faceless_gold:': 'file://{images}/emoticons/team_faceless_gold.png',
	':team_faceless_silver:': 'file://{images}/emoticons/team_faceless_silver.png',
	':team_igv:': 'file://{images}/emoticons/team_igv.png',
	':team_igv_gold:': 'file://{images}/emoticons/team_igv_gold.png',
	':team_igv_silver:': 'file://{images}/emoticons/team_igv_silver.png',
	':team_lfy:': 'file://{images}/emoticons/team_lfy.png',
	':team_lfy_gold:': 'file://{images}/emoticons/team_lfy_gold.png',
	':team_lfy_silver:': 'file://{images}/emoticons/team_lfy_silver.png',
	':team_lgd:': 'file://{images}/emoticons/team_lgd.png',
	':team_lgd_gold:': 'file://{images}/emoticons/team_lgd_gold.png',
	':team_lgd_silver:': 'file://{images}/emoticons/team_lgd_silver.png',
	':team_mvp:': 'file://{images}/emoticons/team_mvp.png',
	':team_mvp_silver:': 'file://{images}/emoticons/team_mvp_silver.png',
	':team_nb:': 'file://{images}/emoticons/team_nb.png',
	':team_nb_gold:': 'file://{images}/emoticons/team_nb_gold.png',
	':team_nb_silver:': 'file://{images}/emoticons/team_nb_silver.png',
	':team_np:': 'file://{images}/emoticons/team_np.png',
	':team_np_gold:': 'file://{images}/emoticons/team_np_gold.png',
	':team_np_silver:': 'file://{images}/emoticons/team_np_silver.png',
	':team_og:': 'file://{images}/emoticons/team_og.png',
	':team_og_gold:': 'file://{images}/emoticons/team_og_gold.png',
	':team_og_silver:': 'file://{images}/emoticons/team_og_silver.png',
	':team_vp:': 'file://{images}/emoticons/team_vp.png',
	':team_vp_gold:': 'file://{images}/emoticons/team_vp_gold.png',
	':team_vp_silver:': 'file://{images}/emoticons/team_vp_silver.png',
	':team_wg:': 'file://{images}/emoticons/team_wg.png',
	':team_wg_gold:': 'file://{images}/emoticons/team_wg_gold.png',
	':team_wg_silver:': 'file://{images}/emoticons/team_wg_silver.png',
	':team_wings:': 'file://{images}/emoticons/team_wings.png',
	':team_wings_gold:': 'file://{images}/emoticons/team_wings_gold.png',
	':team_wings_silver:': 'file://{images}/emoticons/team_wings_silver.png',	
}

var commandList = [{
	title: "votes",
	commands: [{
		title: "voteEnableCheat",
		chatCommand: "enablecheat",
	}, {
		title: "voteEnableBuilder",
		chatCommand: "enablebuilder",
	},{
		title: "voteEnableAntiRat",
		chatCommand: "antirat",
	},{
		title: "voteEnableUniversalShops",
		chatCommand: "universalshops",
	},{
		title: "voteEnableRespawn",
		chatCommand: "enablerespawn",
	},{
		title: "voteEnableKamikaze",
		chatCommand: "enablekamikaze",
	},{
		title: "voteDoubleCreeps",
		chatCommand: "doublecreeps",
	},{
		title: "voteFatOMeter",
		chatCommand: "enablefat",
	},{
		title: "voteRefresh",
		chatCommand: "enableRefresh",
	},{
		title: "voteSwitchTeam",
		chatCommand: "switchteam",
	},]
}];

function addEmotion( parent, emotStr ) {
	if (!emotions.hasOwnProperty(emotStr))
		return;

	var emotion = $.CreatePanel('DOTAEmoticon', parent, '');
	emotion.SetImage(emotions[emotStr]);

	return emotion;
}

// Common say function
function say() {
	var time = Game.Time();
	if (time < lastSendedMessageTime + sendTimeout && lastSendedMessageTime != 0)
		return;

	var msg = $('#chatInput').text.trim();

	var channel = msg.match(/\/[\w]+/g);
	if(channel != null){
		channel = channel[0];
		msg = msg.replace(channel, '');
		channel = channel.substring(1);

		if (channels.hasOwnProperty(channel)){
			currentChannel = channel;
			color = channels[channel].color;
		}
	}

	setChannelStyle(currentChannel);

	if (msg.length > 0) {
		lastSendedMessageTime = time;
		$('#chatInput').text = '';
		GameEvents.SendCustomGameEventToServer( 'custom_chat_say', { channel: currentChannel, msg: msg });
	}
}

// Show received message
function showChatMessage( args ) {
	// Don't show muted players
	if (Game.IsPlayerMuted(args.player) && args.player != -1) {
		$.Msg("Asd");
		return;
	}

	var time = Game.Time();
	if (time > lastMessageTime + 60 || lastMessageTime == 0) {
     	var timeStamp = $.CreatePanel( "Panel", $('#chatRows'), "" );
		timeStamp.BLoadLayoutSnippet('timeStamp');
		timeStamp.FindChildTraverse('timeStamp').text = args.timeStamp;
	}

	lastMessageTime = time;

	var label = $.CreatePanel('Label', $('#chatRows'), '');
	label.AddClass('chatRow');
	label.html = true;

	var msg = args.msg;

	// Smiles checkimg
	var matches = args.msg.match(/:[\w]+?:/g);
	if (matches){
		matches = matches.filter(function(k){
			return emotions.hasOwnProperty(k);
		});

		$.Each(matches, function(v, k) {
			msg = msg.replace(v, '<img>');
		});
	}

	if (args.player == -1) {
		if (args.localize) {
			msg = $.Localize(msg);
		}
		label.text = '(' + $.Localize("announcement") + ') : ' + msg;
	} else {
		label.text = '(' + $.Localize(channels[args.channel].name) + ') ' + ' ' + Game.GetPlayerInfo(args.player).player_name + ': ' + msg;
	}
	label.style.color = channels[args.channel].color;

	if (matches)
		for(var i = 0; i < matches.length; i++)
			addEmotion(label.GetChild(i), matches[i]);
}

// Hooks a change event
function addInputChangedEvent(panel, callback) {
    var shouldListen = false;
    var checkRate = 0.01;
    var currentString = panel.text;

    var inputChangedLoop = function() {
        // Check for a change
        if(currentString != panel.text) {
            // Update current string
            currentString = panel.text;

            // Run the callback
            callback(panel, currentString);
        }

        if(shouldListen) {
            $.Schedule(checkRate, inputChangedLoop);
        }
    }

    panel.SetPanelEvent('onfocus', function() {
		$.GetContextPanel().RemoveClass('blur');

        // Enable listening, and monitor the field
        shouldListen = true;
        inputChangedLoop();
    });

    panel.SetPanelEvent('onblur', function() {
		$.GetContextPanel().AddClass('blur');
		$('#emoticonPicker').SetHasClass('visible', false);

        // No longer listen
        shouldListen = false;
    });
}

function checkString( panel, str ){
	if (str[0] == '/'){
		$('#channelName').visible = false;
	}
	else {
		$('#channelName').visible = true;
	}
}

// Fill emotions list
function fillEmoticonContainer() {
	$('#emoticonContainer').RemoveAndDeleteChildren();

	$.Each(emotions, function(v, k) {
		var emot = addEmotion($('#emoticonContainer'), k);
		emot.AddClass('emot');

		emot.SetPanelEvent('onmouseover', function(){
			$('#emoticonAlias').text = k;
		});

		emot.SetPanelEvent('onmouseout', function(){
			$('#emoticonAlias').text = '';
		});	

		emot.SetPanelEvent('onactivate', function(){
			$('#chatInput').text += k;
		});				
	})
}

function showEmoticonPicker() {
	$('#emoticonPicker').SetHasClass('visible', !$('#emoticonPicker').BHasClass('visible'));
	$.GetContextPanel().SetFocus();
}

function showVotings() {
	if (GameUI.CustomUIConfig().selectedPhase > 3) {
		$('#votingsPicker').SetHasClass('visible', !$('#votingsPicker').BHasClass('visible'));
		$.GetContextPanel().SetFocus();
	} else {
		addNotification({"text" : 'votingsDisabled'});
	}
}

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
				showVotings();
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

	var checkHeight = function() {
		$.Schedule(0.1, checkHeight);
	}
	checkHeight();
}

(function() {
	GameEvents.Subscribe('custom_chat_send_message', showChatMessage);

	$("#commandList").RemoveAndDeleteChildren();
	createCommandGroup(util.commandList[0]);

	addInputChangedEvent($('#chatInput'), checkString);
	fillEmoticonContainer();
	setChannelStyle(currentChannel); 
})();