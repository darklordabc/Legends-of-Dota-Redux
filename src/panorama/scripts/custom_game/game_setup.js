"use strict";

// All options JSON (todo: EXPORT IT)
var allOptions = {
    // Presets, to make selection FAST
    presets: {

    },

    // The common stuff people play with
    common_selection: {

    },

    // Changing the speed of the match
    game_speed: {

    },

    // Advanced stuff, for pros
    advanced_selection: {

    },

    // Buffing of heroes, towers, etc
    buffs: {

    },

    // Stuff that is just crazy
    crazyness: {

    }
}

// Phases
var PHASE_LOADING = 1;          // Waiting for players, etc
var PHASE_OPTION_SELECTION = 2; // Selection options
var PHASE_BANNING = 3;          // Banning stuff
var PHASE_SELECTION = 4;        // Selecting heroes
var PHASE_DRAFTING = 5;         // Place holder for drafting mode
var PHASE_REVIEW = 6;           // Review Phase
var PHASE_INGAME = 7;           // Game has started

// The current phase we are in
var currentPhase = PHASE_LOADING;
var selectedPhase = PHASE_OPTION_SELECTION;
var endOfTimer = -1;

// List of all player team panels
var allPlayerPanels = [];

// Hooks an events and fires for all the keys
function hookAndFire(tableName, callback) {
    // Listen for phase changing information
    CustomNetTables.SubscribeNetTableListener(tableName, callback);

    // Grab the data
    var data = CustomNetTables.GetAllTableValues(tableName);
    for(var i=0; i<data.length; ++i) {
        var info = data[i];
        callback(tableName, info.key, info.value);
    }
}

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

// Build the options categories
function buildOptionsCategories() {
    // Grab the main container for option categories
    var catContainer = $('#optionCategories');

    // Delete any children
    catContainer.RemoveAndDeleteChildren();

    // Loop over all the option labels
    for(var optionLabelText in allOptions) {
        var optionCategory = $.CreatePanel('Button', catContainer, 'option_button_' + optionLabelText);
        optionCategory.SetAttributeString('cat', optionLabelText);
        optionCategory.AddClass('PlayButton');

        var optionLabel = $.CreatePanel('Label', optionCategory, 'option_button_' + optionLabelText + '_label');
        optionLabel.text = $.Localize(optionLabelText + '_lod');
    }
}

// Player presses auto assign
function onAutoAssignPressed() {
    // Auto assign teams
    Game.AutoAssignPlayersToTeams();

    // Lock teams
    Game.SetTeamSelectionLocked(true);
}

// Player presses shuffle
function onShufflePressed() {
    // Shuffle teams
    Game.ShufflePlayerTeamAssignments();
}

// Player presses lock teams
function onLockPressed() {
    // Don't allow a forced start if there are unassigned players
    if (Game.GetUnassignedPlayerIDs().length > 0)
        return;

    // Lock the team selection so that no more team changes can be made
    Game.SetTeamSelectionLocked(true);
}

// Player presses unlock teams
function onUnlockPressed() {
    // Unlock Teams
    Game.SetTeamSelectionLocked(false);
}

// Lock options pressed
function onLockOptionsPressed() {
    // Ensure teams are locked
    if(!Game.GetTeamSelectionLocked()) return;

    // Lock options
    GameEvents.SendCustomGameEventToServer('lodOptionsLocked', {});
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

// A phase was changed
function OnPhaseChanged(table_name, key, data) {
    switch(key) {
        case 'phase':
            // Update the current phase
            currentPhase = data.v;

            // Update phase classes
            var masterRoot = $('#mainSelectionRoot');
            masterRoot.SetHasClass('phase_loading', currentPhase == PHASE_LOADING);
            masterRoot.SetHasClass('phase_option_selection', currentPhase == PHASE_OPTION_SELECTION);
            masterRoot.SetHasClass('phase_banning', currentPhase == PHASE_BANNING);
            masterRoot.SetHasClass('phase_selection', currentPhase == PHASE_SELECTION);
            masterRoot.SetHasClass('phase_drafting', currentPhase == PHASE_DRAFTING);
            masterRoot.SetHasClass('phase_review', currentPhase == PHASE_REVIEW);
            masterRoot.SetHasClass('phase_ingame', currentPhase == PHASE_INGAME);

            // Progrss to the new phase
            SetSelectedPhase(currentPhase, true);
        break;

        case 'endOfTimer':
            // Store the end time
            endOfTimer = data.v;
        break;
    }
}

// Changes which phase the player currently has selected
function SetSelectedPhase(newPhase, noSound) {
    if(newPhase > currentPhase) {
        Game.EmitSound('ui_team_select_pick_team_failed');
        return;
    }

    // Emit the click noise
    if(!noSound) Game.EmitSound('ui_team_select_pick_team');

    // Set the phase
    selectedPhase = newPhase;

    // Update CSS
    var masterRoot = $('#mainSelectionRoot');
    masterRoot.SetHasClass('phase_option_selection_selected', selectedPhase == PHASE_OPTION_SELECTION);
    masterRoot.SetHasClass('phase_banning_selected', selectedPhase == PHASE_BANNING);
    masterRoot.SetHasClass('phase_selection_selected', selectedPhase == PHASE_SELECTION);
    masterRoot.SetHasClass('phase_drafting_selected', selectedPhase == PHASE_DRAFTING);
    masterRoot.SetHasClass('phase_review_selected', selectedPhase == PHASE_REVIEW);
}

//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
function UpdateTimer() {
    /*var gameTime = Game.GetGameTime();
    var transitionTime = Game.GetStateTransitionTime();

    CheckForHostPrivileges();

    var mapInfo = Game.GetMapInfo();
    $( "#MapInfo" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

    if ( transitionTime >= 0 )
    {
        $( "#StartGameCountdownTimer" ).SetDialogVariableInt( "countdown_timer_seconds", Math.max( 0, Math.floor( transitionTime - gameTime ) ) );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", true );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", false );
    }
    else
    {
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", false );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", true );
    }

    var autoLaunch = Game.GetAutoLaunchEnabled();
    $( "#StartGameCountdownTimer" ).SetHasClass( "auto_start", autoLaunch );
    $( "#StartGameCountdownTimer" ).SetHasClass( "forced_start", ( autoLaunch == false ) );*/

    // Allow the ui to update its state based on team selection being locked or unlocked
    $('#mainSelectionRoot').SetHasClass('teams_locked', Game.GetTeamSelectionLocked());
    $('#mainSelectionRoot').SetHasClass('teams_unlocked', Game.GetTeamSelectionLocked() == false);

    // Phase specific stuff
    switch(currentPhase) {
        case PHASE_BANNING:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodBanningTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;

        case PHASE_SELECTION:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodSelectionTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;

        case PHASE_REVIEW:
            // Workout how long is left
            var currentTime = Game.Time();
            var timeLeft = Math.ceil(endOfTimer - currentTime);

            var timeLeftLabel = $('#lodReviewTimeRemaining');
            timeLeftLabel.text = '(' + timeLeft + ')'
        break;
    }

    $.Schedule(0.1, UpdateTimer);
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
    UpdateTimer();

    // Build the options categories
    buildOptionsCategories();

    // Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
    $.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

    // Register a listener for the event which is broadcast whenever a player attempts to pick a team
    $.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

    // Hook stuff
    hookAndFire('phase_pregame', OnPhaseChanged);
})();
