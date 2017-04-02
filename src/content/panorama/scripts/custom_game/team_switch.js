function TeamSwitchButton() {
    if ($.GetContextPanel().BHasClass('NeedsBlanace')) {
        GameEvents.SendCustomGameEventToServer('lodOnCheats', {
            command: 'switchteam'
        });
    }
}

function TeamSwitchOnHover() {
    $.DispatchEvent('DOTAShowTextTooltip',  $('#TeamSwitch_Button'), $.GetContextPanel().BHasClass('NeedsBlanace') ? '#teamSwitch_ready' : '#teamSwitch_no_imbalance');
}

CustomNetTables.SubscribeNetTableListener('phase_ingame', function(table, key, value) {
    if (key == 'balance_data') {
        $.GetContextPanel().SetHasClass('NeedsBlanace', Game.IsInToolsMode() || (value.required == 1 && value.takeFromTeam == Players.GetTeam(Game.GetLocalPlayerID())));
    }
})
if (Game.IsInToolsMode()) {
    $.GetContextPanel().AddClass('NeedsBlanace')
}