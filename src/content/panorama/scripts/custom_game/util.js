var Util = {};

Util.commandList = [{
    title: "votes",
    commands: [{
        title: "voteEnableCheat",
        chatCommand: "enablecheat",
    }, {
        title: "voteEnableBuilder",
        chatCommand: "enablebuilder",
    },{
        title: "voteEnableAntiRat",
        chatCommand: "antirat",
    },{
        title: "voteEnableUniversalShops",
        chatCommand: "universalshops",
    },{
        title: "voteEnableRespawn",
        chatCommand: "enablerespawn",
    },{
        title: "voteEnableKamikaze",
        chatCommand: "enablekamikaze",
    },{
        title: "voteDoubleCreeps",
        chatCommand: "doublecreeps",
    },{
        title: "voteFatOMeter",
        chatCommand: "enablefat",
    },{
        title: "voteRefresh",
        chatCommand: "enableRefresh",
    },{
        title: "voteSwitchTeam",
        chatCommand: "switchteam",
    },]
}, {
    title: "game",
    isCheat: true,
    commands: [{
        title: "toggleWtf",
        chatCommand: "wtfmenu",
        isCheat: true,
    },{
        title: "nofog",
        chatCommand: "nofog",
        isCheat: true,
    },{
        title: "fog",
        chatCommand: "fog",
        isCheat: true,
    }, {
        title: "toggleAllVision",
        consoleCommand: "dota_all_vision",
        "getArgs": function() {
            CommandProperties.toggleAllVision = !(CommandProperties.toggleAllVision || false);
            return CommandProperties.toggleAllVision ? 1 : 0;
        },
        isCheat: true,
    }, {
        title: "startGame",
        consoleCommand: "dota_start_game",
        isCheat: true,
    }, {
        title: "fortify",
        chatCommand: "fortify",
        isCheat: true,
    }, {
        title: "fortify_dire",
        chatCommand: "fortify_dire",
        isCheat: true,
    }, { 
        title: "fortify_rad",
        chatCommand: "fortify_rad",
        isCheat: true,
    }, {
        title: "spawnNeutrals",
        consoleCommand: "dota_spawn_neutrals",
        isCheat: true,
    }, {
        title: "spawnGolem",
        chatCommand: "spawn golem",
    }, {
        title: "spawnUnit",
        consoleCommand: "dota_create_unit",
        "getArgs": function(settings) {
            return settings.GetChild(0).GetSelected().id + (settings.GetChild(1).checked ? " enemy" : " friendly");
        },
        customXmlPanel: "<root><Panel><DropDown>\
                <Label text='Axe' id='axe'/>\
                <Label text='Roshan' id='npc_dota_roshan'/>\
            </DropDown><ToggleButton text='Enemy' /></Panel></root>",
        isCheat: true,
    }, {
        title: "setTimescale",
        consoleCommand: "host_timescale",
        "getArgs": function(settings) {
            return settings.GetChild(0).value
        },
        customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='10'/></Panel></root>",
        isCheat: true,
    },] 
}, {
    title: "bots",
    commands: [{
        title: "botsShowMode",
        chatCommand: "bot mode",
    },{
        title: "botsSwitchMode",
        chatCommand: "bot switch",
        isCheat: true,
    },{
        title: "botsLevelUp",
        consoleCommand: "dota_bot_give_level",
        "getArgs": function(settings) {
            return settings.GetChild(0).value
        },
        customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='100'/></Panel></root>",
        isCheat: true,
    }, {
        title: "botsGiveGold",
        consoleCommand: "dota_bot_give_gold",
        "getArgs": function(settings) {
            return settings.GetChild(0).value
        },
        customXmlPanel: "<root><Panel><NumberEntry value='999999' min='1' max='999999'/></Panel></root>",
        isCheat: true,
    }]
}, {
    title: "player",
    isCheat: true,
    commands: [{
        title: "refresh",
        consoleCommand: "dota_hero_refresh",
        isCheat: true,
    }, {
        title: "respawn",
        chatCommand: "respawn",
        isCheat: true,
    }, {
        title: "godMode",
        chatCommand: "god",
        isCheat: true,
    }, {
        title: "regen",
        chatCommand: "regen",
        isCheat: true,
    },{
        title: "scepter",
        chatCommand: "scepter",
        isCheat: true,
    },{
        title: "invis",
        chatCommand: "invis",
        isCheat: true,
    },{
        title: "reflect",
        chatCommand: "reflect",
        isCheat: true,
    },{
        title: "spellblock",
        chatCommand: "spellblock",
        isCheat: true,
    },{
        title: "gem",
        chatCommand: "gem",
        isCheat: true,
    },{
        title: "cooldown",
        chatCommand: "cooldown",
        isCheat: true,
    },{
        title: "globalcast",
        chatCommand: "globalcast",
        isCheat: true,
    },{
        title: "dagger",
        chatCommand: "dagger",
        isCheat: true,
    },{
        title: "dagon",
        chatCommand: "dagon",
        isCheat: true,
    }, {
        title: "selfFreePoints",
        chatCommand: "points",
        "getArgs": function(settings) {
            return settings.GetChild(0).value
        },
        customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='100'/></Panel></root>",
        isCheat: true,
    }, {
        title: "selfLevelUp",
        chatCommand: "lvlup",
        "getArgs": function(settings) {
            return settings.GetChild(0).value
        },
        customXmlPanel: "<root><Panel><NumberEntry value='1' min='1' max='100'/></Panel></root>",
        isCheat: true,
    }, {
        title: "selfGiveGold",
        chatCommand: "gold",
        "getArgs": function(settings) {
            return settings.GetChild(0).value;
        },
        customXmlPanel: "<root><Panel><NumberEntry value='999999' min='1' max='999999'/></Panel></root>",
        isCheat: true,
    }, {
        title: "selfGetItem",
        consoleCommand: "dota_create_item",
        "getArgs": function(settings) {
            return settings.GetChild(0).GetSelected().id;
        },
        customXmlPanel: "<root><Panel><DropDown>\
                <Label text='Boots of Travel' id='item_travel_boots'/>\
                <Label text='Heart of Tarrasque' id='item_heart'/>\
                <Label text='Radiance' id='item_radiance'/>\
                <Label text='Blink Dagger' id='item_blink'/>\
                <Label text='Bloodstone' id='item_bloodstone'/>\
            </DropDown></Panel></root>",
        isCheat: true,
    }, ]
}];

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

/**
 * Returns a function, that, as long as it continues to be invoked, will not
 * be triggered. The function will be called after it stops being called for
 * N milliseconds. If `immediate` is passed, trigger the function on the
 * leading edge, instead of the trailing. The function also has a property 'clear' 
 * that is a function which will clear the timer to prevent previously scheduled executions. 
 *
 * @source underscore.js
 * @see http://unscriptable.com/2009/03/20/debouncing-javascript-methods/
 * @param {Function} function to wrap
 * @param {Number} timeout in ms (`100`)
 * @param {Boolean} whether to execute at the beginning (`false`)
 * @api public
 */
Util.debounce = (function debounce(func, wait, immediate) {
    var timeout, args, context, timestamp, result;
    if (null == wait) wait = 100;

    function later() {
        var last = Date.now() - timestamp;

        if (last < wait && last >= 0) {
            timeout = $.Schedule(wait - last, later);
        } else {
            timeout = null;
            if (!immediate) {
                result = func.apply(context, args);
                context = args = null;
            }
        }
    };

    var debounced = function(){
        context = this;
        args = arguments;
        timestamp = Date.now();
        var callNow = immediate && !timeout;
        if (!timeout) timeout = $.Schedule(wait, later);
        if (callNow) {
            result = func.apply(context, args);
            context = args = null;
        }

        return result;
    };

    debounced.clear = function() {
        if (timeout) {
            $.CancelScheduled(timeout);
            timeout = null;
        }
    };
    
    debounced.flush = function() {
        if (timeout) {
            result = func.apply(context, args);
            context = args = null;
            
            $.CancelScheduled(timeout);
            timeout = null;
        }
    };

    return debounced;
});

(function(){
	GameUI.CustomUIConfig().Util = Util;

    GameUI.SetMouseCallback( function( eventName, arg ) {
        var CONSUME_EVENT = true;
        var CONTINUE_PROCESSING_EVENT = false;
        var ClickBehaviors = GameUI.GetClickBehaviors();
        if ( ClickBehaviors !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
            return CONTINUE_PROCESSING_EVENT;
        var result = CONTINUE_PROCESSING_EVENT;

        if (eventName === "pressed") {
            if (arg === 5 || arg === 6) {
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
            } else if (arg === 0) {
                for (var k in Game.MouseEvents.OnLeftPressed) {
                    var r = Game.MouseEvents.OnLeftPressed[k](ClickBehaviors, eventName, arg);
                    if (r === true)
                        result = r;
                }
            }
        }

        return result;
    } );
})()
