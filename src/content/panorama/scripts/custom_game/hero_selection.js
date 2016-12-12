// This script simply ensures that a hero is spawned
// In theory, a hero SHOULD be spawned, this script just ensures one IS spawned

// Checks if we have a hero yet
function checkForHero() {
    var playerID = Players.GetLocalPlayer();
    var myInfo = Game.GetPlayerInfo(playerID);

    // Game is bugged, or something is wrong, get out of here!
    if(myInfo == null) return;

    if(myInfo.player_selected_hero.length <= 0 || !Players.GetPlayerSelectedHero( playerID ) || Players.GetPlayerSelectedHero( playerID ) <= 0) {
        // Request a hero
        GameEvents.SendCustomGameEventToServer('lodSpawnHero', {});

        // Try again after an entire second
        $.Schedule(1, checkForHero);
    }
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function() {
    // Check if we have a hero yet
    checkForHero();
    GameEvents.Subscribe("lodSpawningQueue", function (args) {
        var queue = (Players.GetLocalPlayer() - args.queue);

        if (queue == 0) {
            $("#loadingLabel").text = "Spawning...";
        } else {
            $("#loadingLabel").text = "You are queued for spawn: " + queue;
        }
    });
})();
