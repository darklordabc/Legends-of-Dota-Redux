"use strict";
$.$ = GameUI.CustomUIConfig().$;

var hud = $.GetContextPanel().GetParent();
while(hud.id != "Hud")
    hud = hud.GetParent();

var styles = {
    // Scoreboard
    '#scoreboard #RadiantTeamContainer': {
        'overflow': 'clip scroll'
    },

    '#scoreboard #DireTeamContainer': {
        'overflow': 'clip scroll'
    },

    '#scoreboard #LocalTeamInventoryContainer': {
        'overflow': 'clip scroll'  
    },

    // Top bar
    '#topbar': {
        'width': 'fit-children'
    },

    '#TopBarRadiantTeam': {
        'width': 'fit-children',
        'horizontal-align': 'right',
        'margin-right': '52%'
    },

    '#TopBarDireTeam': {
        'width': 'fit-children',
        'horizontal-align': 'left',
        'margin-left': '52%'
    },    

    '#TopBarRadiantPlayers': {
        'width': 'fit-children'
    },

    '#TopBarDirePlayers': {
        'width': 'fit-children'
    },

    '#TopBarRadiantPlayersContainer': {
        'width': 'fit-children'
    },

    '#TopBarDirePlayersContainer': {
        'width': 'fit-children'
    },

    '#HUDSkinTopBarBG': {
    	'width': '20%'
    }
};

function hackHotkeys() {
    $.Schedule(0.5, hackHotkeys);
    var defaultLetters = ['Q', 'W', 'E', 'D', 'F', 'R'];
    for (var i = 0; i <= 5; i++) {
        var ability = hud.FindChildTraverse("Ability"+i)
        if (ability && ability.FindChildTraverse("HotkeyText") && ability.FindChildTraverse("HotkeyText").text == 'R' && i != 5) {
            ability.FindChildTraverse("HotkeyText").text = defaultLetters[i];
        }
    }
}

// When this panel loads
(function(){
    for(var selector of Object.keys(styles))
        $.$(selector).css(styles[selector]);

    hackHotkeys();
})();
