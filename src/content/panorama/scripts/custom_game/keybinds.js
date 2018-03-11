function RegisterKeybind(command) {
	Game.Events[command] = [];
	Game.AddCommand('+' + command, function() {
		for (var key in Game.Events[command]) {
			Game.Events[command][key]();
		}
	}, '', 0);
	Game.AddCommand('-' + command, function() {}, '', 0);
}

Game.Events = {};

RegisterKeybind('F4Pressed');
RegisterKeybind('F5Pressed');
RegisterKeybind('F8Pressed');

Game.MouseEvents = {
	OnLeftPressed: []
};
