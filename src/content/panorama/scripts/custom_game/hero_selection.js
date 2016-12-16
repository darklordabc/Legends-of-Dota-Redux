var hud = $.GetContextPanel().GetParent();
while(hud.id != "Hud")
    hud = hud.GetParent();

var label = hud.FindChildTraverse("PausedLabel");

var queue = -1;

function checkForHero() {
    var playerID = Players.GetLocalPlayer();
    var myInfo = Game.GetPlayerInfo(playerID);

    if (queue == 0) {
        return;
    }

    // Game is bugged, or something is wrong, get out of here!
    if(myInfo == null) {
        $.Schedule(1, checkForHero);
        return;
    }

    if(myInfo.player_selected_hero.length <= 0 || !Players.GetPlayerSelectedHero( playerID ) || Players.GetPlayerSelectedHero( playerID ) <= 0) {
        // Request a hero
        GameEvents.SendCustomGameEventToServer('lodSpawnHero', {});
    }

    // Try again after an entire second
    $.Schedule(1, checkForHero);
}

function rollBackChanges() {
    hud.FindChildTraverse("lower_hud").visible = true;
    GameUI.CustomUIConfig().topScoreboard.visible = true;

    label.text = $.Localize("DOTA_Hud_Paused");

    $.GetContextPanel().DeleteAsync(0.0);
}

(function() {
    GameEvents.Subscribe("lodCreatedHero", function (args) {
        queue = 0;

        rollBackChanges();
    })

    hud.FindChildTraverse("lower_hud").visible = false;
    GameUI.CustomUIConfig().topScoreboard.visible = false;

    // Check if we have a hero yet
    checkForHero();
    GameEvents.Subscribe("lodSpawningQueue", function (args) {
        queue = (Players.GetLocalPlayer() - args.queue);

        if (queue == -1) {
            label.text = $.Localize("DOTA_Hud_Paused");
        } else if (queue == 0) {
            label.text = "Spawning";
        } else {
            label.text = "Queued for spawn: " + queue;
        }
    });
})();