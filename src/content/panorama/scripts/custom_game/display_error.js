GameEvents.Subscribe("display_custom_error", function(msg) {
	GameEvents.SendEventClientSide("dota_hud_error_message", {
		splitscreenplayer: 0,
		reason: 80,
		message: msg.message
	});
});