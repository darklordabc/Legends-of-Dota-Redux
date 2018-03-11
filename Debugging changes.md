https://github.com/darklordabc/Legends-of-Dota-Redux/commit/d926ad21f614aa7ea74af4eeb76f0f07f377e1df

disabled review phase in toolsmode to speed things up
///Changes made to this branch code to decrease testing time

///Pregame.lua - line 3333
local minTime = 3
///to
local minTime = .5

///game_setup.js - line 5263
var showDuration = 3;
///to
var showDuration = .5;

///game_setup.js - line "function buildHeroList() {"
///add below
Game.SetTeamSelectionLocked(true);

///game_setup.js - comment out following lines: 
$('#lodPopupMessage').visible = true;
