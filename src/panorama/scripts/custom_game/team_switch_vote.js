"use strict";
GameEvents.Subscribe("vote_dialog", show_vote_dialog);
GameEvents.Subscribe("player_declined", player_declined);
GameEvents.Subscribe("player_accepted", player_accepted);

var handler;

function show_vote_dialog(swap_info) {
    var swapper_info = Game.GetPlayerInfo(swap_info.swapper);
    var swappee_info = Game.GetPlayerInfo(swap_info.swappee);

    $('#swapper_icon').heroname = swapper_info.player_selected_hero;
    $('#swapper_name').text = swapper_info.player_name;

    $('#swappee_icon').heroname = swappee_info.player_selected_hero;
    $('#swappee_name').text = swappee_info.player_name;

    $('#vote_dialog').RemoveClass('hidden');
    $('#choice').RemoveClass('hiddenoccupy')

    apply_transition_from_start('#vote_timer', '10s', 'shrink');
    handler = $.Schedule(10, function() { $('#vote_dialog').AddClass('hidden');
                                          $('#vote_timer').RemoveClass('shrink')
                                        });
}

function accept() {
    GameEvents.SendCustomGameEventToServer( 'accept', {} );
    $('#choice').AddClass('hiddenoccupy')
}

function decline() {
    GameEvents.SendCustomGameEventToServer( 'declined', {} );
}

function player_declined() {
    var vote_dialog = $('#vote_dialog')
    var title = vote_dialog.FindChildrenWithClassTraverse('title')[0];
    title.text = 'DECLINED';
    vote_dialog.AddClass('declined');

    $.CancelScheduled(handler);
    halt_transition('#vote_timer', 'shrink');
    $.Schedule(2, function() {
        vote_dialog.RemoveClass('declined');
        vote_dialog.AddClass('hidden');
        title.text = 'TEAM SWITCH';
    })
}

function player_accepted() {
    var vote_dialog = $('#vote_dialog')
    var title = vote_dialog.FindChildrenWithClassTraverse('title')[0];
    title.text = 'ACCEPTED';
    vote_dialog.AddClass('accepted');

    $.CancelScheduled(handler);
    halt_transition('#vote_timer', 'shrink');
    $.Schedule(2, function() {
        vote_dialog.RemoveClass('accepted');
        vote_dialog.AddClass('hidden');
        title.text = 'TEAM SWITCH';
    })
}

function apply_transition(el, t, c) {
    $(el).AddClass(t);
    $(el).AddClass(c);
    $(el).RemoveClass(t);
}

function apply_transition_from_start(el, t, c) {
    $(el).AddClass(c);
    $(el).RemoveClass(c);
    apply_transition(el, t, c);
}

function halt_transition(el, c) {
    $(el).AddClass('forever');
    $(el).RemoveClass(c);
    $(el).RemoveClass('forever');
}
