"use strict";

function SetCameraDistance( args ) 
{
    $.Msg("Setting camera distance to: " + args.distance)
    GameUI.SetCameraDistance( Number(args.distance) )
}

(function()
{
	GameEvents.Subscribe( "camera_zoom", SetCameraDistance)
})();