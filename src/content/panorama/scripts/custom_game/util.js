var Util = {};

Util.mouseWheelBlockingPanels = [];

Util.secondsToHHMMSS = (function (d) {
	d = Number(d);
	var h = Math.floor(d / 3600);
	var m = Math.floor(d % 3600 / 60);
	var s = Math.floor(d % 3600 % 60);
	return ((h > 0 ? h + ":" + (m < 10 ? "0" : "") : "") + m + ":" + (s < 10 ? "0" : "") + s); 
});

Util.secondsToMMSS = (function (d) {
    d = Number(d);
    var m = Math.floor(d / 60);
    var s = Math.floor(d % 60);
    return (m + ":" + (s < 10 ? "0" : "") + s); 
});

Util.getSteamID32 = (function () {
    var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
});

Util.getDate = (function () {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    return yyyy * 10000 + mm * 100 + dd;
});

Util.roundToTwo = (function (num) {    
    return +(Math.round(num + "e+2")  + "e-2");
});

Util.roundToThree = (function (num) {    
    return +(Math.round(num + "e+3")  + "e-3");
});

Util.autoUppercase = (function (str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
});

Util.spanString = (function (str, className) {
    if (!str) return str;
    return "<span class=\"" + className + "\">" + str + "</span>";
});

Util.colorString = (function (str, color) {
    return "<font color=\"" + (color || "#FFFFFF") + "\">" + str + "</font>";
});

Util.removeChildren = (function (panel) {
    for (var child in panel.Children()) {
        panel.Children()[child].DeleteAsync(0.0);
        panel.Children()[child].RemoveAndDeleteChildren();
    }
});

Util.isPointInRect = (function (point, rect) {
    x1 = rect[0][0];
    x2 = rect[2][0];
    y1 = rect[0][1];
    y2 = rect[2][1];

    if ((x1 <= point[0]) && (point[0] <= x2) && 
        (y1 <= point[1]) && (point[1] <= y2)) {
        return true;
    } else {
        return false
    }
})

Util.blockMouseWheel = (function (panel) {
    Util.mouseWheelBlockingPanels.push(panel);
});

Util.getHexPlayerColor = (function (playerID) {
    if (playerID === undefined)
        return 'none';

    var color = Players.GetPlayerColor( playerID ).toString(16);
    color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4);
    return "#" + color;
});

(function(){
	GameUI.CustomUIConfig().Util = Util;

    GameUI.SetMouseCallback( function( eventName, arg ) {
        var nMouseButton = arg
        var CONSUME_EVENT = true;
        var CONTINUE_PROCESSING_EVENT = false;
        if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
            return CONTINUE_PROCESSING_EVENT;

        if (eventName === "pressed" && (arg == 5 || arg == 6))
        {
            for (var key in Util.mouseWheelBlockingPanels) {
                var panel = Util.mouseWheelBlockingPanels[key];

                try {
                    var pX = panel.GetPositionWithinWindow()["x"];
                    var pY = panel.GetPositionWithinWindow()["y"];

                    var rect = [[pX, pY], [pX + panel.actuallayoutwidth, pY], [pX + panel.actuallayoutwidth, pY + panel.actuallayoutheight], [pX, pY + panel.actuallayoutheight]]; //Util.isPointInRect(, [pX, pY, , ])

                    if (Util.isPointInRect(GameUI.GetCursorPosition(), rect) && panel.visible && panel.enabled && panel.BCanSeeInParentScroll()) {
                        return CONSUME_EVENT;
                    }
                } catch (err) {
                }
            }
        }

        return CONTINUE_PROCESSING_EVENT;
    } );
})()