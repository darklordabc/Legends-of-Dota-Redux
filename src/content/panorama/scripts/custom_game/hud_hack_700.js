"use strict";
$.$ = GameUI.CustomUIConfig().$;

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

// When this panel loads
(function(){
    for(var selector of Object.keys(styles))
        $.$(selector).css(styles[selector]);
})();
