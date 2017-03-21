function createVoting(rootPanel, playerInfo, votingName, votingTitle, votingLine, acceptCallback, declineCallback, voteDuration) {
    var panel = $.CreatePanel("Panel", rootPanel, "voting_" + votingName);
    panel.BLoadLayout('file://{resources}/layout/custom_game/universal_votings.xml', false, false);

    panel.FindChildTraverse("titleLabel").text = $.Localize(votingTitle);
    panel.FindChildTraverse("lineLabel").html = true;
    panel.FindChildTraverse("lineLabel").text = playerInfo.player_name + " " + $.Localize(votingLine);

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
    });

    panel.SetHasClass("dialog_hidden", false);
    panel.FindChildTraverse("choice").RemoveClass('hiddenoccupy');

    GameEvents.Subscribe("universalVotingsPlayerUpdate", function(data) {
        if (data.votingName == votingName) {
            panel.FindChildTraverse("choice").AddClass('hiddenoccupy')
            var accepted = data.accept
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
        }
    });

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
    GameUI.CustomUIConfig().createVoting = createVoting;
})();