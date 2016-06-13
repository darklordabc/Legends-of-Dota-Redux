"use strict";
GameEvents.Subscribe("vote_dialog", show_vote_dialog);
GameEvents.Subscribe("player_declined", player_declined);

var handler;

function show_vote_dialog(swap_info) {
    var swapper_info = Game.GetPlayerInfo(swap_info.swapper);
    var swappee_info = Game.GetPlayerInfo(swap_info.swappee);

    $('#swapper_icon').heroname = swapper_info.player_selected_hero;
    $('#swapper_name').text = swapper_info.player_name;

    $('#swappee_icon').heroname = swappee_info.player_selected_hero;
    $('#swappee_name').text = swappee_info.player_name;

    $('#vote_dialog').RemoveClass('hidden');
    $('#vote_timer').AddClass('show');
    $('#vote_timer').RemoveClass('show');
    handler = $.Schedule(10, function() { $('#vote_dialog').AddClass('hidden'); });
}

function accept() {
    $('#vote_dialog').AddClass('hidden');
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
    $.Schedule(2, function() {
        vote_dialog.RemoveClass('declined');
        vote_dialog.AddClass('hidden');
        title.text = 'TEAM SWITCH';
    })
}

