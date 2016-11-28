"use strict";

var lastMessageTime = 0;

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

var currentChannel = 'all';
var color = 'white';

function setChannelStyle( channel ){
	$('#channelName').text = $.Localize(channels[channel].name) + ':';
	$('#channelName').style.color = channels[channel].color;
}

function say() {
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
		$('#chatInput').text = '';
		GameEvents.SendCustomGameEventToServer( 'custom_chat_say', { channel: currentChannel, msg: msg });
	}
}

function showChatMessage( args ) {
	var time = Game.Time();
	if (time > lastMessageTime + 60 || lastMessageTime == 0) {
     	var timeStamp = $.CreatePanel( "Panel", $('#chatRows'), "" );
		timeStamp.BLoadLayoutSnippet('timeStamp');
		timeStamp.FindChildTraverse('timeStamp').text = args.timeStamp;
	}

	lastMessageTime = time;

	var label = $.CreatePanel('Label', $('#chatRows'), '');
	label.AddClass('chatRow');
	label.text = '(' + $.Localize(channels[args.channel].name) + ') ' + ' ' + Game.GetPlayerInfo(args.player).player_name + ': ' + args.msg;
	label.style.color = channels[args.channel].color;

	$.Schedule(0.2, function() {
		$('#chatRows').GetParent().ScrollToTop(); 
	});	
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

(function() {
	GameEvents.Subscribe('custom_chat_send_message', showChatMessage);

	addInputChangedEvent($('#chatInput'), checkString);

	setChannelStyle(currentChannel); 
})();