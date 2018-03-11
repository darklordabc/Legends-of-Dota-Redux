"use strict";

// The tips we can show
var tipsGeneral = [{
        img: 'file://{images}/spellicons/death_prophet_witchcraft.png',
        txt: '#hintWitchCraft'
    }, {
        img: 'file://{images}/custom_game/hints/ogre_magi_multicast_lod.png',
        txt: '#hintMulticast'
    }, {
        img: 'file://{images}/custom_game/hints/hint_warnings.png',
        txt: '#hintWarnings'
    }, {
        img: 'file://{images}/spellicons/antimage_blink.png',
        txt: '#hintBlink'
    }, {
        img: 'file://{images}/custom_game/hints/hint_balancemode.png',
        txt: '#hintBalanceMode'
    }, {
        img: 'file://{images}/custom_game/hints/hint_saveload.png',
        txt: '#hintSaveLoad'
    }, {
        img: 'file://{images}/custom_game/hints/hint_scoreboard.png',
        txt: '#hintScoreboard'
    }, {
        img: 'file://{images}/custom_game/hints/commentButton.png',
        txt: '#hintComment'
    }, {
        img: 'file://{images}/custom_game/hints/hint_removeability.png',
        txt: '#hintRemoveAbility'
    }, {
        img: 'file://{images}/items/neutral.png',
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
    }, {
        img: 'file://{images}/custom_game/hints/hint_fatOMeter.png',
        txt: '#hintFatOMeter'
    }, {
        img: 'file://{images}/spellicons/meepo_divided_we_stand.png',
        txt: '#hintHost'
    }, {
        img: 'file://{images}/custom_game/hints/hint_UniversalShop.png',
        txt: '#hintUniversalShop'
    },{
        img: 'file://{images}/custom_game/hints/hint_discord.png',
        txt: '#hintDiscord'
    },{
        img: 'file://{images}/custom_game/hints/hint_bots_difficulty.png',
        txt: '#hintBotsDifficulty'
    },
    //{
    //    img: 'file://{images}/custom_game/hints/hint_duels.png',
    //    txt: '#hintDuels'
    //},
    {
        img: 'file://{images}/items/wind_lace.png',
        txt: '#hintBotTalents'
    },{
        img: 'file://{images}/custom_game/hints/hint_perks.png',
        txt: '#hintPerks'
    },{
        img: 'file://{images}/custom_game/hints/hint_Booster.png',
        txt: '#hintBooster'
    },{
        img: 'file://{images}/custom_game/hints/hint_CustomAbility.png',
        txt: '#hintCustomAbility'
    },{
        img: 'file://{images}/custom_game/hints/hint_alt.png',
        txt: '#hintAlt'
    },{
        img: 'file://{images}/custom_game/hints/hint_random.png',
        txt: '#hintRandom'
    },{
        img: 'file://{images}/custom_game/hints/hint_singleplayer.png',
        txt: '#hintSinglePlayer'
    },{
        img: 'file://{images}/custom_game/hints/hint_ctrl.png',
        txt: '#hintCtrl'
    },{
        img: 'file://{images}/custom_game/hints/hint_RespawnTimes.png',
        txt: '#hintRespawnTimes'
    },{
        img: 'file://{images}/custom_game/hints/hint_Balancing.png',
        txt: '#hintBalancing'
    },{
        img: 'file://{images}/custom_game/hints/hint_GoldBorder.png',
        txt: '#hintGoldBorder'
    },{
        img: 'file://{images}/spellicons/techies_suicide.png',
        txt: '#hintAntiKamikaze'
    },{
        img: 'file://{images}/spellicons/courier_shield.png',
        txt: '#hintChatCheats'
    },{
        img: 'file://{images}/custom_game/hints/hint_silver.png',
        txt: '#hintSilver'
    },
];

var tipsPerks = [{       
        img: 'file://{images}/custom_game/hints/hint_lina.png',
        txt: '#hintLina'
    }, {
        img: 'file://{images}/custom_game/hints/hint_life_stealer.png',
        txt: '#hintLifeStealer'
    }, {
        img: 'file://{images}/custom_game/hints/hint_tide_hunter.png',
        txt: '#hintTideHunter'
    }, {
        img: 'file://{images}/custom_game/hints/hint_enigma.png',
        txt: '#hintEnigma'
    }, {
        img: 'file://{images}/custom_game/hints/hint_legion_commander.png',
        txt: '#hintLegionCommander'
    }, {
        img: 'file://{images}/custom_game/hints/hint_furion.png',
        txt: '#hintFurion'
    }, {
        img: 'file://{images}/custom_game/hints/hint_chen.png',
        txt: '#hintChen'
    }, {
        img: 'file://{images}/custom_game/hints/hint_ursa.png',
        txt: '#hintUrsa'
    }, {
        img: 'file://{images}/custom_game/hints/hint_storm_spirit.png',
        txt: '#hintStormSpirit'
    }, {
        img: 'file://{images}/custom_game/hints/hint_morphling.png',
        txt: '#hintMorphling'
    }, {
        img: 'file://{images}/custom_game/hints/hint_timbersaw.png',
        txt: '#hintTimbersaw'
    }, {
        img: 'file://{images}/custom_game/hints/hint_blood_seeker.png',
        txt: '#hintBloodSeeker'
    }, {
        img: 'file://{images}/custom_game/hints/hint_riki.png',
        txt: '#hintRiki'
    }, {
        img: 'file://{images}/custom_game/hints/hint_batrider.png',
        txt: '#hintBatrider'
    }, {
        img: 'file://{images}/custom_game/hints/hint_brewmaster.png',
        txt: '#hintBrewmaster'
    }, {
        img: 'file://{images}/custom_game/hints/hint_shadowfiend.png',
        txt: '#hintShadowfiend'
    }, {
        img: 'file://{images}/custom_game/hints/hint_puck.png',
        txt: '#hintPuck'
    }, {
        img: 'file://{images}/custom_game/hints/hint_abaddon.png',
        txt: '#hintAbaddon'
    }, {
        img: 'file://{images}/custom_game/hints/hint_winter_wyvern.png',
        txt: '#hintWinterWyvern'
    }, {
        img: 'file://{images}/custom_game/hints/hint_dragon_knight.png',
        txt: '#hintDragonKnight'
    }, {
        img: 'file://{images}/custom_game/hints/hint_centaur.png',
        txt: '#hintCentaur'
    }, {
        img: 'file://{images}/custom_game/hints/hint_phoenix.png',
        txt: '#hintPhoenix'
    }, {
        img: 'file://{images}/custom_game/hints/hint_ancient_apparition.png',
        txt: '#hintAncientApparition'
    }, {
        img: 'file://{images}/custom_game/hints/hint_shadow_shaman.png',
        txt: '#hintShadowShaman'
    }, {
        img: 'file://{images}/custom_game/hints/hint_doom.png',
        txt: '#hintDoom'
    }, {
        img: 'file://{images}/custom_game/hints/hint_lich.png',
        txt: '#hintLich'
    }, {
        img: 'file://{images}/custom_game/hints/hint_spectre.png',
        txt: '#hintSpectre'
    }, {
        img: 'file://{images}/custom_game/hints/hint_dark_seer.png',
        txt: '#hintDarkSeer'
    }, {
        img: 'file://{images}/custom_game/hints/hint_enchantress.png',
        txt: '#hintEnchantress'
    }, {
        img: 'file://{images}/custom_game/hints/hint_invoker.png',
        txt: '#hintInvoker'
    }, {
        img: 'file://{images}/custom_game/hints/hint_qop.png',
        txt: '#hintQOP'
    },/* {
        img: 'file://{images}/custom_game/hints/hint_wisp.png',
        txt: '#hintWisp'
    }, {
        img: 'file://{images}/custom_game/hints/hint_meepo.png',
        txt: '#hintMeepo'
    }*/ {
        img: 'file://{images}/custom_game/hints/hint_pl.png',
        txt: '#hintPL'
    }, {
        img: 'file://{images}/custom_game/hints/hint_cm.png',
        txt: '#hintCM'
    }, {
        img: 'file://{images}/custom_game/hints/hint_anti_mage.png',
        txt: '#hintAntiMage'
    }, {
        img: 'file://{images}/custom_game/hints/hint_elder_titan.png',
        txt: '#hintElderTitan'
    }, {
        img: 'file://{images}/custom_game/hints/hint_lion.png',
        txt: '#hintLion'
    }, {
        img: 'file://{images}/custom_game/hints/hint_tusk.png',
        txt: '#hintTusk'
    }, {
        img: 'file://{images}/custom_game/hints/hint_WD.png',
        txt: '#hintWD'
    }, {
        img: 'file://{images}/custom_game/hints/hint_clinkz.png',
        txt: '#hintClinkz'
    }, {
        img: 'file://{images}/custom_game/hints/hint_ogre_magi.png',
        txt: '#hintOgreMagi'
    }, {
        img: 'file://{images}/custom_game/hints/hint_vs.png',
        txt: '#hintVS'
    }, {
        img: 'file://{images}/custom_game/hints/hint_visage.png',
        txt: '#hintVisage'
    }, {
        img: 'file://{images}/custom_game/hints/hint_naga.png',
        txt: '#hintNaga'
    }, {
        img: 'file://{images}/custom_game/hints/hint_BH.png',
        txt: '#hintBH'
    }, {
        img: 'file://{images}/custom_game/hints/hint_drow.png',
        txt: '#hintDrow'
    }, {
        img: 'file://{images}/custom_game/hints/hint_nyx.png',
        txt: '#hintNyx'
    }, {
        img: 'file://{images}/custom_game/hints/hint_slark.png',
        txt: '#hintSlark'
    }, {
        img: 'file://{images}/custom_game/hints/hint_luna.png',
        txt: '#hintLuna'
    }, {
        img: 'file://{images}/custom_game/hints/hint_alchemist.png',
        txt: '#hintAlchemist'
    }, {
        img: 'file://{images}/custom_game/hints/hint_arc_warden.png',
        txt: '#hintArcWarden'
    }, {
        img: 'file://{images}/custom_game/hints/hint_axe.png',
        txt: '#hintAxe'
    }, {
        img: 'file://{images}/custom_game/hints/hint_bane.png',
        txt: '#hintBane'
    }, {
        img: 'file://{images}/custom_game/hints/hint_beast_master.png',
        txt: '#hintBeastMaster'
    }, {
        img: 'file://{images}/custom_game/hints/hint_earth_spirit.png',
        txt: '#hintEarthSpirit'
    }, {
        img: 'file://{images}/custom_game/hints/hint_ember_spirit.png',
        txt: '#hintEmberSpirit'
    }, {
        img: 'file://{images}/custom_game/hints/hint_faceless_void.png',
        txt: '#hintFacelessVoid'
    }, {
        img: 'file://{images}/custom_game/hints/hint_huskar.png',
        txt: '#hintHuskar'
    }, {
        img: 'file://{images}/custom_game/hints/hint_jakiro.png',
        txt: '#hintJakiro'
    }, {
        img: 'file://{images}/custom_game/hints/hint_juggernaut.png',
        txt: '#hintJuggernaut'
    }, {
        img: 'file://{images}/custom_game/hints/hint_kotl.png',
        txt: '#hintKOTL'
    }, {
        img: 'file://{images}/custom_game/hints/hint_kunkka.png',
        txt: '#hintKunkka'
    }, {
        img: 'file://{images}/custom_game/hints/hint_leshrac.png',
        txt: '#hintLeshrac'
    }, {
        img: 'file://{images}/custom_game/hints/hint_lone_druid.png',
        txt: '#hintLoneDruid'
    }, {
        img: 'file://{images}/custom_game/hints/hint_lycan.png',
        txt: '#hintLycan'
    }, {
        img: 'file://{images}/custom_game/hints/hint_magnus.png',
        txt: '#hintMagnus'
    }, {
        img: 'file://{images}/custom_game/hints/hint_medusa.png',
        txt: '#hintMedusa'
    }, {
        img: 'file://{images}/custom_game/hints/hint_mirana.png',
        txt: '#hintMirana'
    }, {
        img: 'file://{images}/custom_game/hints/hint_necrophos.png',
        txt: '#hintNecrophos'
    }, {
        img: 'file://{images}/custom_game/hints/hint_omniknight.png',
        txt: '#hintOmniknight'
    }, {
        img: 'file://{images}/custom_game/hints/hint_oracle.png',
        txt: '#hintOracle'
    }, {
        img: 'file://{images}/custom_game/hints/hint_OD.png',
        txt: '#hintOD'
    }, {
        img: 'file://{images}/custom_game/hints/hint_PA.png',
        txt: '#hintPA'
    }, {
        img: 'file://{images}/custom_game/hints/hint_pudge.png',
        txt: '#hintPudge'
    }, {
        img: 'file://{images}/custom_game/hints/hint_pugna.png',
        txt: '#hintPugna'
    }, {
        img: 'file://{images}/custom_game/hints/hint_razor.png',
        txt: '#hintRazor'
    }, {
        img: 'file://{images}/custom_game/hints/hint_rubick.png',
        txt: '#hintRubick'
    }, {
        img: 'file://{images}/custom_game/hints/hint_sand_king.png',
        txt: '#hintSandKing'
    }, 
    //{
    //    img: 'file://{images}/custom_game/hints/hint_shadow_demon.png',
    //    txt: '#hintShadowDemon'
    //}, 
    {
        img: 'file://{images}/custom_game/hints/hint_silencer.png',
        txt: '#hintSilencer'
    }, {
        img: 'file://{images}/custom_game/hints/hint_skywrath.png',
        txt: '#hintSkywrath'
    }, {
        img: 'file://{images}/custom_game/hints/hint_slardar.png',
        txt: '#hintSlardar'
    }, {
        img: 'file://{images}/custom_game/hints/hint_sniper.png',
        txt: '#hintSniper'
    }
    , {
        img: 'file://{images}/custom_game/hints/hint_spirit_breaker.png',
        txt: '#hintSpiritBreaker'
    }, {
        img: 'file://{images}/custom_game/hints/hint_sven.png',
        txt: '#hintSven'
    }, {
        img: 'file://{images}/custom_game/hints/hint_techies.png',
        txt: '#hintTechies'
    }, {
        img: 'file://{images}/custom_game/hints/hint_ta.png',
        txt: '#hintTA'
    }, {
        img: 'file://{images}/custom_game/hints/hint_terrorblade.png',
        txt: '#hintTerrorblade'
    }, {
        img: 'file://{images}/custom_game/hints/hint_tinker.png',
        txt: '#hintTinker'
    }, {
        img: 'file://{images}/custom_game/hints/hint_tiny.png',
        txt: '#hintTiny'
    }, {
        img: 'file://{images}/custom_game/hints/hint_treant.png',
        txt: '#hintTreant'
    }, {
        img: 'file://{images}/custom_game/hints/hint_troll_warlord.png',
        txt: '#hintTrollWarlord'
    }, {
        img: 'file://{images}/custom_game/hints/hint_underlord.png',
        txt: '#hintUnderlord'
    }, {
        img: 'file://{images}/custom_game/hints/hint_willow.png',
        txt: '#hintDarkWillow'
    }, {
        img: 'file://{images}/custom_game/hints/hint_pangolier.png',
        txt: '#hintPangolier'
    }, {
        img: 'file://{images}/custom_game/hints/hint_undying.png',
        txt: '#hintUndying'
    }, {
        img: 'file://{images}/custom_game/hints/hint_venomancer.png',
        txt: '#hintVenomancer'
    }, {
        img: 'file://{images}/custom_game/hints/hint_viper.png',
        txt: '#hintViper'
    }, {
        img: 'file://{images}/custom_game/hints/hint_warlock.png',
        txt: '#hintWarlock'
    }, {
        img: 'file://{images}/custom_game/hints/hint_weaver.png',
        txt: '#hintWeaver'
    }, {
        img: 'file://{images}/custom_game/hints/hint_windranger.png',
        txt: '#hintWindranger'
    }, {
        img: 'file://{images}/custom_game/hints/hint_WK.png',
        txt: '#hintWK'
    }, {
        img: 'file://{images}/custom_game/hints/hint_zuus.png',
        txt: '#hintZuus'
    }, {
        img: 'file://{images}/custom_game/hints/hint_BM.png',
        txt: '#hintBM'
    }, {
        img: 'file://{images}/custom_game/hints/hint_NS.png',
        txt: '#hintNS'
    }, {
        img: 'file://{images}/custom_game/hints/hint_earth_shaker.png',
        txt: '#hintEarthShaker'
    }/*, {
        img: 'file://{images}/custom_game/hints/hint_gyro.png',
        txt: '#hintGyro'
    }*/, {
        img: 'file://{images}/custom_game/hints/hint_bristle_back.png',
        txt: '#hintBristleBack'
    }, {
        img: 'file://{images}/custom_game/hints/hint_CK.png',
        txt: '#hintCK'
    }, {
        img: 'file://{images}/custom_game/hints/hint_clockwerk.png',
        txt: '#hintClockwerk'
    }, {
        img: 'file://{images}/custom_game/hints/hint_dazzle.png',
        txt: '#hintDazzle'
    }, {
        img: 'file://{images}/custom_game/hints/hint_disruptor.png',
        txt: '#hintDisruptor'
    }, {
        img: 'file://{images}/custom_game/hints/hint_DP.png',
        txt: '#hintDP'
    }, {
        img: 'file://{images}/custom_game/hints/hint_monkey_king.png',
        txt: '#hintMonkeyKing'
    }
];

// Start flag
var isTipStarted = false;

// How long to wait before we show the next tip
var tipDelay = 15;

// Tip context panel
var tipContextPanel = null;

var phase = 0;

// Contains a list of all tip IDs
var allTips = [];
var tipUpto = 0;

var randomLists = [tipsPerks, tipsGeneral];
var randomedTips = {};

function checkCount( lists ) {
    return lists.filter(function(list){
        return Object.keys(list).length > 0;
    }).length > 0;
}

var count = 0;
while (checkCount(randomLists)) {
    for(var i = 0; i < randomLists.length; i++){
        var list = randomLists[i];
        if (Object.keys(list).length == 0)
            continue;

        var key = Object.keys(list)[Math.floor(Math.random() * Object.keys(list).length)];
        randomedTips[count] = list[key];
        count++;

        delete list[key];
    }
}

// Sets the hint
function setHint(img, txt) {
	if (tipContextPanel == null)
		return;

    // Set the image
    var tipImage = tipContextPanel.FindChildTraverse('LoDLoadingTipImage');
    if(tipImage != null) {
        tipImage.SetImage(img);
    }

    var tipText = tipContextPanel.FindChildTraverse('LoDLoadingTipText');
    if(tipText != null) {
        tipText.text = txt;
    }
}

// Show the next hint
function nextHint(stopFunct) {
    // Set the next tip
    var tip = randomedTips[tipUpto++];
    setHint(tip.img, $.Localize(tip.txt));

    if(tipUpto > Object.keys(randomedTips).length - 1) {
        tipUpto = 0;
    }

    // Schedule the next tip
    $.Schedule(tipDelay, function() {
        nextHint();
    });
}

function startTips(panel){
    if (panel == null)
        return;

    if (tipContextPanel != null)
    tipContextPanel.visible = false;

    tipContextPanel = panel;

    if (!isTipStarted){
        // Show the first hint
        nextHint();
        isTipStarted = true;
    }
};
