"use strict";

// List of all player team panels
var allPlayerPanels = [];

// Adds a player to the list of unassigned players
function addUnassignedPlayer(playerID) {
    // Grab the panel to insert into
    var unassignedPlayersContainerNode = $('#unassignedPlayersContainer');
    if (unassignedPlayersContainerNode == null) return;

    // Create the new panel
    var newPlayerPanel = $.CreatePanel('Panel', unassignedPlayersContainerNode, 'unassignedPlayer');
    newPlayerPanel.SetAttributeInt('playerID', playerID);
    newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/unasignedPlayer.xml', false, false);

    // Add this panel to the list of panels we've generated
    allPlayerPanels.push(newPlayerPanel);
}

// Adds a player to a team
function addPlayerToTeam(playerID, panel) {
    // Validate the panel
    if(panel == null) return;

    // Create the new panel
    var newPlayerPanel = $.CreatePanel('Panel', panel, 'teamPlayer');
    newPlayerPanel.SetAttributeInt('playerID', playerID);
    newPlayerPanel.BLoadLayout('file://{resources}/layout/custom_game/teamPlayer.xml', false, false);

    // Add this panel to the list of panels we've generated
    allPlayerPanels.push(newPlayerPanel);
}

// Player presses auto assign
function onAutoAssignPressed() {
    // Auto assign teams
    Game.AutoAssignPlayersToTeams();
}

// Player presses shuffle
function onShufflePressed() {
    // Shuffle teams
    Game.ShufflePlayerTeamAssignments();
}

// Player tries to join radiant
function onJoinRadiantPressed() {
    // Attempt to join radiant
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
}

// Player tries to join dire
function onJoinDirePressed() {
    // Attempt to join dire
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
}

// Player tries to join unassigned
function onJoinUnassignedPressed() {
    // Attempt to join unassigned
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}

//--------------------------------------------------------------------------------------------------
// Update the unassigned players list and all of the team panels whenever a change is made to the
// player team assignments
//--------------------------------------------------------------------------------------------------
function OnTeamPlayerListChanged() {
    // Kill all of the old panels
    for(var i=0; i<allPlayerPanels.length; ++i) {
        // Grab the panel
        var panel = allPlayerPanels[i];

        // Kill the panel
        panel.DeleteAsync(0);
    }
    allPlayerPanels = [];

    // Move all existing player panels back to the unassigned player list
    /*for ( var i = 0; i < g_PlayerPanels.length; ++i )
    {
        var playerPanel = g_PlayerPanels[ i ];
        playerPanel.SetParent( unassignedPlayersContainerNode );
    }*/

    // Create a panel for each of the unassigned players
    var unassignedPlayers = Game.GetUnassignedPlayerIDs();
    for(var i=0; i<unassignedPlayers.length; ++i) {
        // Add this player to the unassigned list
        addUnassignedPlayer(unassignedPlayers[i]);
    }

    // Add radiant players
    var radiantPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
    for(var i=0; i<radiantPlayers.length; ++i) {
        // Add this player to the unassigned list
        addPlayerToTeam(radiantPlayers[i], $('#theRadiantContainer'));
    }

    // Add radiant players
    var direPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);
    for(var i=0; i<direPlayers.length; ++i) {
        // Add this player to the unassigned list
        addPlayerToTeam(direPlayers[i], $('#theDireContainer'));
    }

    // Update all of the team panels moving the player panels for the
    // players assigned to each team to the corresponding team panel.
    /*for ( var i = 0; i < g_TeamPanels.length; ++i )
    {
        UpdateTeamPanel( g_TeamPanels[ i ] )
    }*/

    // Set the class on the panel to indicate if there are any unassigned players
    $('#mainSelectionRoot').SetHasClass('unassigned_players', unassignedPlayers.length != 0 );
    $('#mainSelectionRoot').SetHasClass('no_unassigned_players', unassignedPlayers.length == 0 );

    // Set host privledges
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;

    $('#mainSelectionRoot').SetHasClass('player_has_host_privileges', playerInfo.player_has_host_privileges);
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function OnPlayerSelectedTeam( nPlayerId, nTeamId, bSuccess ) {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) return;

    // Check to see if the event is for the local player
    if (playerInfo.player_id === nPlayerId) {
        // Play a sound to indicate success or failure
        if (bSuccess) {
            Game.EmitSound('ui_team_select_pick_team');
        } else {
            Game.EmitSound('ui_team_select_pick_team_failed');
        }
    }
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function() {
    //$( "#mainTeamContainer" ).SetAcceptsFocus( true ); // Prevents the chat window from taking focus by default

    /*var teamsListRootNode = $( "#TeamsListRoot" );

    // Construct the panels for each team
    for ( var teamId of Game.GetAllTeamIDs() )
    {
        var teamNode = $.CreatePanel( "Panel", teamsListRootNode, "" );
        teamNode.AddClass( "team_" + teamId ); // team_1, etc.
        teamNode.SetAttributeInt( "team_id", teamId );
        teamNode.BLoadLayout( "file://{resources}/layout/custom_game/team_select_team.xml", false, false );

        // Add the team panel to the global list so we can get to it easily later to update it
        g_TeamPanels.push( teamNode );
    }*/

    // Automatically assign players to teams.
    Game.AutoAssignPlayersToTeams();

    // Do an initial update of the player team assignment
    OnTeamPlayerListChanged();

    // Start updating the timer, this function will schedule itself to be called periodically
    //UpdateTimer();

    // Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
    $.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

    // Register a listener for the event which is broadcast whenever a player attempts to pick a team
    $.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

})();
