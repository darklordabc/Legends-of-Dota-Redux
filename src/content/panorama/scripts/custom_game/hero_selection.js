// Checks if we have a hero yet
function checkForHero() {
    var playerID = Players.GetLocalPlayer();
    var myInfo = Game.GetPlayerInfo(playerID);

    // Game is bugged, or something is wrong, get out of here!
    if(myInfo == null) return;

    if(myInfo.player_selected_hero.length <= 0) {
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
    if (!Players.IsSpectator(Players.GetLocalPlayer())) {
        checkForHero();
    }
})();