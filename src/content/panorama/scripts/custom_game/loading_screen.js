"use strict";

// Hooks an events and fires for all the keys
function hookAndFire(tableName, callback) {
    // Listen for phase changing information
    CustomNetTables.SubscribeNetTableListener(tableName, callback);

    // Grab the data
    var data = CustomNetTables.GetAllTableValues(tableName);
    if(data != null) {
        for(var i=0; i<data.length; ++i) {
            var info = data[i];
            callback(tableName, info.key, info.value);
        }
    }
}

// When we get player stats
function onGetPlayerStats(table_name, key, data) {
    // Are we dealing with stats?
    if(key != 'stats') return;

    // Cleanup the stats container
    var statsCon = $('#statsContainer');
    statsCon.RemoveAndDeleteChildren();

    // Create the header
    var statsRow = $.CreatePanel('Panel', statsCon, 'stats_row_header');
    statsRow.BLoadLayout( "file://{resources}/layout/custom_game/stats_row.xml", false, false);
    statsRow.onGetRowData(-1);

    var even = true;

    // Loop over the data
    for(var playerID in data) {
        var statsRow = $.CreatePanel('Panel', statsCon, 'stats_row_' + playerID);
        statsRow.BLoadLayout( "file://{resources}/layout/custom_game/stats_row.xml", false, false);
        statsRow.onGetRowData(parseInt(playerID), data[playerID]);

        even = !even;
        statsRow.SetHasClass('evenStatRow', even);
    }

    // Hide the stupid tip
    $.GetContextPanel().SetHasClass('statsFullyLoaded', true);
}

function setBackground()
{
    var backgroundPath = "file://{images}/custom_game/loading_screens/";
    var backgroundPanel = $( "#CustomBackground" );

    var backList = [
        { img: "venomancer.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
        { img: "crystal_maiden.png", author: "eric geusz", url: "http://entroz.deviantart.com" },
        { img: "doom.jpg", author: "eric geusz", url: " http://entroz.deviantart.com" },
		{ img: "bristle.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "ck.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "clink.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "clockwerk.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "crystal_maiden.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "dirge.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "doom2.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "ember.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "es.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "jugg.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "jugg2.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "kotl.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "medusa.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "np.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "nyx.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "od.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "pl.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "puck.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "razor.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "sd.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "sf.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "silencer.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "sky.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "slardar.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "sven.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "venomancer.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "venomancer2.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "vs.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "warlock.jpg", author: "BigGreenPepper", url: "http://biggreenpepper.deviantart.com" },
		{ img: "bladeandbow.jpg", author: "Valve", url: "" },
		{ img: "direancient.jpg", author: "Valve", url: "" },
		{ img: "io.jpg", author: "Valve", url: "" },
		{ img: "midlane.jpg", author: "Valve", url: "" },
		{ img: "np2.jpg", author: "Valve", url: "" },
		{ img: "pureskill.jpg", author: "Valve", url: "" },
		{ img: "radiantancient.jpg", author: "Valve", url: "" },
		{ img: "roshan.jpg", author: "Valve", url: "" },
		{ img: "rubick.jpg", author: "Valve", url: "" },
		{  img: "tidehunter.jpg", author: "Valve", url: "" },
		//title for below: The Calm Before the Horn
		{  img: "calmbeforehorn.jpg", author: "Eran Fowler", url: "http://eranfolio.deviantart.com/" },
		{  img: "huskarfire.jpg", author: "Valve", url: "" },
		{  img: "pa.jpg", author: "Valve", url: "" },
		{  img: "abaddon.jpg", author: "Valve", url: "" },
		{  img: "drow.jpg", author: "Valve", url: "" },
		{  img: "ursa.jpg", author: "Valve", url: "" },
		{  img: "dragonknight.jpg", author: "Valve", url: "" },
		{  img: "luna.jpg", author: "Valve", url: "" },
		{  img: "ta.jpg", author: "Valve", url: "" },
    ];

    var backNum = Math.floor(Math.random() * backList.length);
    $('#BackgroundImage').SetImage(backgroundPath + backList[backNum].img);
    $('#BackgroundCredit').text = 'by ' + backList[backNum].author; 
    $('#BackgroundCredit').GetParent().SetPanelEvent('onactivate', function(){ 
        $.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), backList[backNum].url);
    });
}

(function() {
    // The tips we can show
    var tips = [{
        img: 'file://{images}/spellicons/death_prophet_witchcraft.png',
        txt: '#hintWitchCraft'
    }, {
        img: 'file://{images}/custom_game/hints/ogre_magi_multicast_lod.png',
        txt: '#hintMulticast'
    },{
        img: 'file://{images}/custom_game/hints/hint_warnings.png',
        txt: '#hintWarnings'
    },{
        img: 'file://{images}/spellicons/antimage_blink.png',
        txt: '#hintBlink'
    },{
        img: 'file://{images}/custom_game/hints/hint_balancemode.png',
        txt: '#hintBalanceMode'
    },{
        img: 'file://{images}/custom_game/hints/hint_saveload.png',
        txt: '#hintSaveLoad'
    },{
        img: 'file://{images}/custom_game/hints/hint_scoreboard.png',
        txt: '#hintScoreboard'
    },{
        img: 'file://{images}/custom_game/hints/commentButton.png',
        txt: '#hintComment'
    },{
        img: 'file://{images}/custom_game/hints/hint_removeability.png',
        txt: '#hintRemoveAbility'
    },{
        img: 'file://{images}/spellicons/satyr_hellcaller_unholy_aura.png',
        txt: '#hintNeutralBuffs'
    }, {
        img: 'file://{images}/spellicons/invoker_alacrity.png',
        txt: '#hintInvokerSpells'
    }, {
        img: 'file://{images}/spellicons/roshan_bash.png',
        txt: '#hintRoshanSpells'
    }, {
        img: 'file://{images}/spellicons/treant_eyes_in_the_forest.png',
        txt: '#hintUltimates'
    }, {
        img: 'file://{images}/spellicons/witch_doctor_voodoo_restoration.png',
        txt: '#hintInfestHacks'
    }, {
        img: 'file://{images}/items/gem.png',
        txt: '#hintSuggestHint'
    }, {
        img: 'file://{images}/custom_game/hints/hint_empowering_haste.png',
        txt: '#hintEmpoweringHaste'
    }, {
        img: 'file://{images}/items/recipe.png',
        txt: '#hintSuggestBuild'
    }, {
        img: 'file://{images}/items/silver_edge.png',
        txt: '#hintBreakPassives'
    }, {
        img: 'file://{images}/spellicons/night_stalker_darkness.png',
        txt: '#hintInnateAbilities'
    }, {
        img: 'file://{images}/spellicons/weaver_the_swarm.png',
        txt: '#hintReport'
    }, {
        img: 'file://{images}/spellicons/axe_counter_helix.png',
        txt: '#hintJungle'
    }];

    // How long to wait before we show the next tip
    var tipDelay = 15;

    // Contains a list of all tip IDs
    var allTips = [];
    var tipUpto = 0;
    for(var i=0; i<tips.length; ++i) {
        allTips.push(i);
    }
    for (var i = allTips.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = allTips[i];
        allTips[i] = allTips[j];
        allTips[j] = temp;
    }

    // Sets the hint
    function setHint(img, txt) {
        // Set the image
        var tipImage = $('#LoDLoadingTipImage');
        if(tipImage != null) {
            tipImage.SetImage(img);
        }

        var tipText = $('#LoDLoadingTipText');
        if(tipText != null) {
            tipText.text = txt;
        }
    }

    // Show the next hint
    function nextHint() {
        // Set the next tip
        var tip = tips[allTips[tipUpto++]];
        //var tip = tips[5];
        setHint(tip.img, $.Localize(tip.txt));

        if(tipUpto >= allTips.length) {
            tipUpto = 0;
        }

        // Schedule the next tip
        $.Schedule(tipDelay, function() {
            nextHint();
        });
    }

    function checkIfWeShouldMoveTheHintToTheRight() {
        if(Game.GetState() >= 2) {
            $.GetContextPanel().AddClass('moveHintTheHint');

            // Done
            return;
        }

        $.Schedule(0.1, checkIfWeShouldMoveTheHintToTheRight);
    }

    // Show the first hint
    nextHint();

    // Check if we should move the hint
    checkIfWeShouldMoveTheHintToTheRight();

    // Give a delay, and then hook pregame stuff
    $.Schedule(0.1, function() {
        // Hook getting player data
        hookAndFire('phase_pregame', onGetPlayerStats);
    });

    setBackground();
})();
