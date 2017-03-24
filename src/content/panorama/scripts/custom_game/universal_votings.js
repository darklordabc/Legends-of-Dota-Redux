var VotingCallbacks = {};

var hud, label;

function createVoting(playerInfo, votingName, votingTitle, votingLine, acceptCallback, declineCallback, voteDuration) {
    var panel = $.CreatePanel("Panel", $.GetContextPanel(), "voting_" + votingName);
    panel.BLoadLayoutSnippet('Voting');

    panel.FindChildTraverse("titleLabel").text = $.Localize(votingTitle);
    panel.FindChildTraverse("lineLabel").html = true;
    panel.FindChildTraverse("lineLabel").text = playerInfo.player_name + " " + $.Localize(votingLine);
    panel.FindChildTraverse("descriptionLabel").text = $.Localize(votingLine + "Descr");

    panel.FindChildTraverse("picture").SetImage("file://{images}/custom_game/votings/" + votingName + ".png");

    panel.FindChildTraverse("acceptButton").enabled = false;
    panel.FindChildTraverse("declineButton").enabled = false;
    $.Schedule(5, function() {
        panel.FindChildTraverse("acceptButton").enabled = true;
        panel.FindChildTraverse("declineButton").enabled = true;
    });

    panel.FindChildTraverse("acceptButton").SetPanelEvent("onactivate", (function () {
        acceptCallback();

        GameEvents.SendCustomGameEventToServer( 'universalVotingsVote', {"votingName" : votingName, "accept": true} );
    }));

    panel.FindChildTraverse("declineButton").SetPanelEvent("onactivate", (function () {
        declineCallback();

        GameEvents.SendCustomGameEventToServer( 'universalVotingsVote', {"votingName" : votingName, "accept": false} );
    }));

    panel.FindChildTraverse("vote_timer").style.transitionDuration = (voteDuration || 10) + "s"
    apply_transition_from_start(panel.FindChildTraverse("vote_timer"), '10s', 'shrink');
    var handler = $.Schedule(voteDuration || 10, function() {
        panel.SetHasClass("dialog_hidden", true);
        panel.FindChildTraverse("vote_timer").RemoveClass('shrink');

        panel.DeleteAsync(10);

        label.visible = true;
    });

    panel.SetHasClass("dialog_hidden", false);
    panel.FindChildTraverse("choice").RemoveClass('hiddenoccupy');

    VotingCallbacks[votingName] = function(accepted) {
        panel.FindChildTraverse("choice").AddClass('hiddenoccupy')
        var title = panel.FindChildTraverse('titleLabel');
        title.text = accepted ? 'ACCEPTED' : 'DECLINED';
        panel.AddClass(accepted ? 'accepted' : 'declined');

        $.CancelScheduled(handler);
        halt_transition(panel.FindChildTraverse("vote_timer"), 'shrink');
        $.Schedule(2, function() {
            panel.AddClass('dialog_hidden');
        })
        $.Schedule(4, function() {
            panel.RemoveClass(accepted ? 'accepted' : 'declined');
        })
        panel.DeleteAsync(10);

        label.visible = true;
    }

    label.visible = false;

    return panel;
}

function apply_transition(el, t, c) {
    el.AddClass(t);
    el.AddClass(c);
    el.RemoveClass(t);
}

function apply_transition_from_start(el, t, c) {
    el.AddClass(c);
    el.RemoveClass(c);
    apply_transition(el, t, c);
}

function halt_transition(el, c) {
    el.AddClass('forever');
    el.RemoveClass(c);
    el.RemoveClass('forever');
}

(function () {
    hud = $.GetContextPanel().GetParent();
    while(hud.id != "Hud")
        hud = hud.GetParent();

    label = hud.FindChildTraverse("PausedLabel").GetParent();

    GameEvents.Subscribe('lodCreateUniversalVoting', function(data) {
        createVoting(Game.GetPlayerInfo(data.initiator), data.title, 'lodVotingTitle', data.title + 'Line', function() {}, function() {}, data.duration);
    })

    GameEvents.Subscribe("universalVotingsPlayerUpdate", function(data) {
        if (VotingCallbacks[data.votingName] != null) {
            VotingCallbacks[data.votingName](data.accept)
        }
    });
})();