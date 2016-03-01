"use strict";

(function() {
    // The tips we can show
    var tips = [{
        img: 'file://{images}/spellicons/death_prophet_witchcraft.png',
        txt: '#hintWitchCraft'
    }, {
        img: 'file://{images}/spellicons/ogre_magi_multicast.png',
        txt: '#hintMulticast'
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
        img: 'file://{images}/spellicons/invoker_empty1.png',
        txt: '#hintSuggestHint'
    }, {
        img: 'file://{images}/custom_game/hints/hint_empowering_haste.png',
        txt: '#hintEmpoweringHaste'
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
})();
