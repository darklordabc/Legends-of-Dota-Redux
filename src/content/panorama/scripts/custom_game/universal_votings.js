function createVoting(rootPanel, playerInfo, votingName, votingLine, acceptCallback, declineCallback) {
	var panel = $.CreatePanel("Panel", rootPanel, "voting_" + votingName);
	panel.BLoadLayout('file://{resources}/layout/custom_game/universal_votings.xml', false, false);

	panel.FindChildTraverse("titleLabel").text = $.Localize(votingName);
	panel.FindChildTraverse("lineLabel").html = true;
	panel.FindChildTraverse("lineLabel").text = $.Localize(votingLine);

	panel.FindChildTraverse("swapper_icon").steamid = playerInfo.player_steamid;
	panel.FindChildTraverse("swapper_name").text = playerInfo.player_name;

	panel.FindChildTraverse("acceptButton").SetPanelEvent("onactivate", (function () {
		acceptCallback();

	    GameEvents.SendCustomGameEventToServer( 'universalVotingsAccept', {"optionName" : votingName} );
	    panel.FindChildTraverse("choice").AddClass('hiddenoccupy')
	}));

	panel.FindChildTraverse("declineButton").SetPanelEvent("onactivate", (function () {
		declineCallback();

		GameEvents.SendCustomGameEventToServer( 'universalVotingsDeclined', {"optionName" : votingName} );
	}));

	var handler;
    apply_transition_from_start(panel.FindChildTraverse("vote_timer"), '10s', 'shrink');
    handler = $.Schedule(10, function() {
    	panel.SetHasClass("dialog_hidden", true);
    	panel.FindChildTraverse("vote_timer").RemoveClass('shrink')

    	$.Schedule(10.0, function () {
    		panel.DeleteAsync(0.0);
    	})
    });

	panel.SetHasClass("dialog_hidden", false);
	panel.FindChildTraverse("choice").RemoveClass('hiddenoccupy')

	GameEvents.Subscribe("universalVotingsPlayerAccepted", function (data) {
		if (data.votingName == votingName) {
		    var title = panel.FindChildrenWithClassTraverse('title')[0];
		    title.text = 'DECLINED';
		    panel.AddClass('declined');

		    $.CancelScheduled(handler);
		    halt_transition(panel.FindChildTraverse("vote_timer"), 'shrink');
		    $.Schedule(2, function() {
		        panel.AddClass('dialog_hidden');
		    })
		    $.Schedule(4, function() {
		        panel.RemoveClass('declined');
		    })
			$.Schedule(10.0, function () {
				panel.DeleteAsync(0.0);
			})
		}
	});
	GameEvents.Subscribe("universalVotingsPlayerDeclined", function (data) {
		if (data.votingName == votingName) {
		    var title = panel.FindChildrenWithClassTraverse('title')[0];
		    title.text = 'DECLINED';
		    panel.AddClass('declined');

		    $.CancelScheduled(handler);
		    halt_transition(panel.FindChildTraverse("vote_timer"), 'shrink');
		    $.Schedule(2, function() {
		        panel.AddClass('dialog_hidden');
		    })
		    $.Schedule(4, function() {
		        panel.RemoveClass('declined');
		    })
			$.Schedule(10.0, function () {
				panel.DeleteAsync(0.0);
			})
		}
	});
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

	// createVoting($.GetContextPanel(), "testVoting", 0, 0);
})();