var hud = $.GetContextPanel().GetParent();
while(hud.id != "Hud")
    hud = hud.GetParent();

var label = hud.FindChildTraverse("PausedLabel");

var queue = -1;

function rollBackChanges() {
    hud.FindChildTraverse("lower_hud").visible = true;
    hud.FindChildTraverse("topbar").visible = true;

    label.text = $.Localize("DOTA_Hud_Paused");

    // $.GetContextPanel().DeleteAsync(0.0);
}

(function() {
    GameEvents.Subscribe("lodAttemptReconnect", function (args) {
        GameEvents.SendCustomGameEventToServer('lodSpawnHero', {});
    })
    GameEvents.Subscribe("lodCreatedHero", function (args) {
        queue = 0;

        rollBackChanges();
    })

    hud.FindChildTraverse("lower_hud").visible = false;
    hud.FindChildTraverse("topbar").visible = false;

    GameEvents.Subscribe("lodSpawningQueue", function (args) {
        queue = (Players.GetLocalPlayer() - args.queue);

        if (queue < 0) {
            label.text = $.Localize("DOTA_Hud_Paused");
        } else if (queue == 0) {
            label.text = "Spawning";
        } else {
            label.text = "Queued for spawn: " + queue;
        }
    });
})();