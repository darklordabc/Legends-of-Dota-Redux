    // All options JSON (todo: EXPORT IT)
var basicOptions = {
    // Presets, to make selection FAST
    presets: {
        default: true,
        fields: [
            {
                name: 'lodOptionGamemode',
                des: 'lodOptionsPresetGamemode',
                about: 'lodOptionAboutPresetGamemode',
                values: [
                    {
                        text: 'lodOptionBalancedAllPick',
                        about: 'lodOptionAboutBalancedAllPick',
                        value: 1
                    },
                    {
                        text: 'lodOptionTraditionalAllPick',
                        about: 'lodOptionAboutTraditionalAllPick',
                        value: 2
                    },
                    {
                        text: 'lodOptionSingleDraft',
                        about: 'lodOptionAboutSingleDraft',
                        value: 5
                    },
                    {
                        text: 'lodOptionMirrorDraft',
                        about: 'lodOptionAboutMirrorDraft',
                        value: 3
                    },
                    {
                        text: 'lodOptionBoosterDraft',
                        about: 'lodOptionAboutBoosterDraft',
                        value: 6
                    },
                    {
                        text: 'lodOptionAllRandom',
                        about: 'lodOptionAboutAllRandom',
                        value: 4
                    },
                    {
                        text: 'lodOptionBalancedCustom',
                        about: 'lodOptionAboutBalancedCustom',
                        value: -1
                    }
                ],
                mutators: [
                    {
                        name: 'lodOptionCommonGamemode',
                        default: {
                            'lodMutatorAllPick': 1,
                        },
                        states: {

                            'lodMutatorMirrorDraft': 3,
                            'lodMutatorAllRandom': 4,
                            'lodMutatorSingleDraft': 5,
                            'lodMutatorBoosterDraft': 6,
                        }
                    },
                    {
                        about: 'lodMutatorBalanceMode',
                        values: {
                            enabled: {
                                'lodOptionBanningBalanceMode': 1,
                                'lodOptionBalanceMode': 1
                            },
                            disabled: {
                                'lodOptionBanningBalanceMode': 0,
                                'lodOptionBalanceMode': 0
                            }
                        }
                    },{
                        name: 'lodOptionGameSpeedMaxLevel',
                        states: {
                            'lodMutatorMaxLevel1': 28,
                            'lodMutatorMaxLevel2': 50,
                            'lodMutatorMaxLevel3': 100
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedUpgradedUlts',
                        default: {
                            'lodMutatorUpgradedUlts': 0,
                        },
                        states: {
                            'lodMutatorUpgradedUlts': 1,
                            'lodMutatorUpgradedUltsNoBots': 2,
                        }
                    },
                    {
                        about: 'lodMutatorFastStart',
                        values: {
                            enabled: {
                                'lodOptionGameSpeedStartingGold': 1000,
                                'lodOptionGameSpeedStartingLevel': 3
                            },
                            disabled: {
                                'lodOptionGameSpeedStartingGold': 0,
                                'lodOptionGameSpeedStartingLevel': 1
                            }
                        }
                    },
                    {
                        about: 'lodMutatorTurboCourier',
                        patreon: false,
                        values: {
                            enabled: {
                                'lodOptionTurboCourier': 1
                            },
                            disabled: {
                                'lodOptionTurboCourier': 0
                            }
                        }
                    },
                    {
                        about: 'lodMutatorFastBuybackCooldown1',
                        default: {
                            'lodOptionBuybackCooldownTimeConstant': 420,
                            'lodOptionGameSpeedRespawnTimePercentage': 100
                        },
                        states: {
                            'lodMutatorFastBuybackCooldown2': {
                                'lodOptionBuybackCooldownTimeConstant': 210,
                                'lodOptionGameSpeedRespawnTimePercentage': 25
                            },
                            'lodMutatorFastBuybackCooldown3': {
                                'lodOptionBuybackCooldownTimeConstant': 0,
                                'lodOptionGameSpeedRespawnTimePercentage': 5
                            }
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedStrongTowers',
                        about: 'lodMutatorStrongTowers'
                    },
                    {
                        name: 'lodOptionPocketTowers',
                        patreon: true,
                        extraInfo: 'lodOptionAboutPocketTowers',
                        default: {
                            'lodMutatorNoPocketTowers': 0,
                        },
                        states: {
                            'lodMutatorPocketTowersConsumable': 1,
                            'lodMutatorPocketTowersCooldown': 300,
                            'lodMutatorPocketTowersCooldown1': 600
                        }
                    },
                    {
                        about: 'lodMutatorDoubleTowers',
                        values: {
                            enabled: {
                                'lodOptionGameSpeedTowersPerLane': 5
                            },
                            disabled: {
                                'lodOptionGameSpeedTowersPerLane': 3
                            }
                        }
                    },
                    {
                        name: 'lodOptionCreepPower',
                        default: {
                            'lodMutatorCreepNoPower': 0
                        },
                        states: {
                            'lodMutatorCreepPowerNormal': 120,
                            'lodMutatorCreepPowerHigh': 60,
                            'lodMutatorCreepPowerExtreme': 30
                        }
                    },
                    {
                        name: 'lodOptionLaneMultiply',
                        extraInfo: 'lodOptionAboutLaneMultiplyMutator',
                        about: 'lodMutatorDoubleCreeps'
                    },
                    {
                        name: 'lodOptionNeutralCreepPower',
                        default: {
                            'lodMutatorNeutralCreepNoPower': 0
                        },
                        states: {
                            'lodMutatorNeutralCreepPowerNormal': 120,
                            'lodMutatorNeutralCreepPowerHigh': 60,
                            'lodMutatorNeutralCreepPowerExtreme': 30
                        }
                    },
                    {
                        name: 'lodOptionNeutralMultiply',
                        default: {
                            'lodMutatorCreepNoMultiply': 1
                        },
                        states: {
                            'lodMutatorCreepDouble': 2,
                            'lodMutatorCreepTriple': 3,
                            'lodMutatorCreepQuadruple': 4
                        }
                    },
                    {
                        name: 'lodOptionCommonMaxUlts',
                        default: {
                            'lodMutatorMaxUlts1': 2
                        },
                        states: {
                            'lodMutatorMaxUlts2': 3,
                            'lodMutatorMaxUlts3': 4,
                            'lodMutatorMaxUlts4': 6
                        }
                    },
                    {
                        name: 'lodOptionAdvancedCustomSkills',
                        about: 'lodMutatorCustomSkills'
                    },
                    {
                        about: 'lodMutatorOPAbilities',
                        values: {
                            enabled: {
                                'lodOptionAdvancedOPAbilities': 1
                            },
                            disabled: {
                                'lodOptionAdvancedOPAbilities': 0
                            }
                        }
                    },
                    {
                       name: 'lodOptionBanningBanInvis',
                        default: {
                            'lodMutatorBanningBanInvis': 0
                        },
                        states: {
                            'lodMutatorBanningBanInvis': 1,
                            'lodMutatorBanningBanInvis2': 2
                        }
                    },
                    {
                        name: 'lodOptionBanningHostBanning',
                        about: 'lodMutatorUnlimitedBans'
                    },
                    {
                        about: 'lodMutatorPlayerBans',
                        values: {
                            enabled: {
                                'lodOptionBanningMaxHeroBans': 1,
                                'lodOptionBanningMaxBans': 3
                            },
                            disabled: {
                                'lodOptionBanningMaxHeroBans': 0,
                                'lodOptionBanningMaxBans': 0
                            }
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedGoldTickRate',
                        default: {
                            'lodMutatorGoldTickRate1': 1
                        },
                        states: {
                            'lodMutatorGoldTickRate2': 2,
                         //   'lodMutatorGoldTickRate3': 3
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedGoldModifier',
                        default: {
                            'lodMutatorGoldModifier1': 100
                        },
                        states: {
                            'lodMutatorGoldModifier2': 150,
                            'lodMutatorGoldModifier3': 300
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedEXPModifier',
                        default: {
                            'lodMutatorEXPModifier1': 100
                        },
                        states: {
                            'lodMutatorEXPModifier2': 150,
                            'lodMutatorEXPModifier3': 300
                        }
                    },
                    {
                        name: 'lodOptionGameSpeedSharedEXP',
                        about: 'lodMutatorShareEXP'
                    },
                    {
                       name: 'lodOptionResurrectAllies',
                       patreon: true,
                       //extraInfo: 'lodOptionAboutResurrectAllies',
                       about: 'lodMutatorResurrectAllies'
                    },
                    {
                        name: 'lodOptionBotsRadiant',
                        default: {
                            'lodMutatorBotsRadiant1': 1
                        },
                        states: {
                            'lodMutatorBotsRadiant2': 5,
                            'lodMutatorBotsRadiant3': 10
                        }
                    },
                    {
                        name: 'lodOptionBotsDire',
                        default: {
                            'lodMutatorBotsDire1': 1
                        },
                        states: {
                            'lodMutatorBotsDire2': 5,
                            'lodMutatorBotsDire3': 10
                        }
                    },
					//{
                    //    name: 'lodOptionBotsBonusPoints',
                    //    about: 'lodMutatorBotsBuff1'
                    //},
                    {
                        name: 'lodOptionBotsUniqueSkills',
                        extraInfo: 'lodOptionAboutBotsUniqueSkills',
                        default: {
                            'lodMutatorUniqueBotSkillsOff': 0
                        },
                        states: {
                            'lodMutatorUniqueBotSkillsTeam': 1,
                            'lodMutatorUniqueBotSkillsGlobal': 2
                        }
                    },
                    /*{
                        name: 'lodOptionBotsUnique',
                        extraInfo: 'lodOptionAboutBotsUnique',
                        about: 'lodMutatorBotsUnique'
                    },*/
                    {
                        name: 'lodOptionLaneCreepBonusAbility',
                        extraInfo: 'lodOptionAboutLaneCreepBonusAbility',
                        default: {
                            'lodMutatorNoAbility': 0,
                        },
                        states: {
                            'lodMutatorRandomAll': 1,
                            'lodMutatorRandomIndividual': 2,
                            'lodMutatorBashwars': 3,
                            'lodMutatorFeast': 4,
                            'lodMutatorFury': 5,
                            'lodMutatorTakeaim': 6,
                            'lodMutatorSideGunner':7,
                            'lodMutatorReactive':8,
                            'lodMutatorBrawler':9,
                            'lodMutatorNothl':10,
                            'lodMutatorFervor':11,
                            'lodMutatorNether':12,
                            'lodMutatorTimeLock':13,
                            'lodMutatorMjolnir':14,
                        }
                    },
                    {
                        about: 'lodMutatorBotDifficulty1',
                        extraInfo: 'lodOptionAboutBotDifficulty',
                        default: {
                            'lodOptionBotsRadiantDiff': 0,
                            'lodOptionBotsDireDiff': 0
                        },
                        states: {
                            'lodMutatorBotDifficulty2': {
                                'lodOptionBotsRadiantDiff': 1,
                                'lodOptionBotsDireDiff': 1
                            },
                            'lodMutatorBotDifficulty3': {
                                'lodOptionBotsRadiantDiff': 2,
                                'lodOptionBotsDireDiff': 2
                            },
                            'lodMutatorBotDifficulty4': {
                                'lodOptionBotsRadiantDiff': 3,
                                'lodOptionBotsDireDiff': 3
                            },
                            'lodMutatorBotDifficulty5': {
                                'lodOptionBotsRadiantDiff': 4,
                                'lodOptionBotsDireDiff': 4
                            },
                            'lodMutatorBotDifficultyRandom': {
                                'lodOptionBotsRadiantDiff': 5,
                                'lodOptionBotsDireDiff': 5
                            }
                        }
                    },
                    /*{
                        name: 'lodOptionBotsStupid',
                        extraInfo: 'lodOptionAboutBotsStupid',
                        about: 'lodMutatorBotsStupid'
                    },
                    {
                        name: 'lodOptionBotsSameHero',
                        extraInfo: 'lodOptionAboutBotsSameHero',
                        default: {
                            'lodMutatorBotsSameHero': 0,
                        },
                        states: {
                            'lodMutatorRandomBotHero': 1,
                            'lodMutatorAxe': 2,
                            'lodMutatorBane': 3,
                            'lodMutatorBountyHunter': 4,
                            'lodMutatorBloodseeker': 5,
                            'lodMutatorBristleback': 6,
                            'lodMutatorChaosKnight': 7,
                            'lodMutatorCrystalMaiden': 8,
                            'lodMutatorDazzle': 9,
                            'lodMutatorDeathProphet': 10,
                            'lodMutatorDragonKnight': 11,
                            'lodMutatorDrowRanger': 12,
                            'lodMutatorEarthshaker': 13,
                            'lodMutatorJakiro': 14,
                            'lodMutatorJuggernaut': 15,
                            'lodMutatorKunkka': 16,
                            'lodMutatorLich': 17,
                            'lodMutatorLina': 18,
                            'lodMutatorLion': 19,
                            'lodMutatorLuna': 20,
                            'lodMutatorNecrophos': 21,
                            'lodMutatorOmniknight': 22,
                            'lodMutatorOracle': 23,
                            'lodMutatorPhantomAssassin': 24,
                            'lodMutatorPudge': 25,
                            'lodMutatorSandKing': 26,
                            'lodMutatorShadowFiend': 27,
                            'lodMutatorSkywrathMage': 28,
                            'lodMutatorSniper': 29,
                            'lodMutatorSven': 30,
                            'lodMutatorTiny': 31,
                            'lodMutatorVengefulSpirit': 32,
                            'lodMutatorViper': 33,
                            'lodMutatorWarlock': 34,
                            'lodMutatorWindranger': 35,
                            'lodMutatorWitchDoctor': 36,
                            'lodMutatorWraithKing': 37,
                            'lodMutatorZeus': 38,
                        }
                    },*/
                    {
                        name: 'lodOptionAdvancedUniqueSkills',
						extraInfo: 'lodOptionAboutAdvancedUniqueSkills',
                        default: {
                            'lodMutatorUniqueSkillsOff': 0
                        },
                        states: {
                            'lodMutatorUniqueSkillsTeam': 1,
                            'lodMutatorUniqueSkillsGlobal': 2
                        }
                    },
                    {
                        name: 'lodOptionAdvancedHidePicks',
                        about: 'lodMutatorHidePicks'
                    },
                    {
                        name: 'lodOptionDisablePerks',
                        about: 'lodMutatorDisablePerks'
                    },
                    {
                        name: 'lodOptionCrazyAllVision',
                        about: 'lodMutatorAllVision'
                    },
                    //{
                    //    name: 'lodOptionCrazyWTF',
                    //    about: 'lodMutatorWTF'
                   // },
                    {
                        name: 'lodOptionCrazyFatOMeter',
                        extraInfo: 'lodOptionAboutCrazyFatOMeter',
                        default: {
                            'lodMutatorNoFatOMeter': 0
                        },
                        states: {
                            'lodMutatorFarmFatOMeter': 1,
                            'lodMutatorKDAFatOMeter': 2
                        }
                    },
                    {
                        about: 'lodMutatorIngameBuilder1',
						extraInfo: 'lodOptionAboutIngameBuilder',
                        default: {
                            'lodOptionIngameBuilder': 0,
                            'lodOptionIngameBuilderPenalty': 0
                        },
                        states: {
                            'lodMutatorIngameBuilder2': {
                                'lodOptionIngameBuilder': 1,
                                'lodOptionIngameBuilderPenalty': 60
                            },
                            'lodMutatorIngameBuilder3': {
                                'lodOptionIngameBuilder': 1,
                                'lodOptionIngameBuilderPenalty': 30
                            },
                            'lodMutatorIngameBuilder4': {
                                'lodOptionIngameBuilder': 1,
                                'lodOptionIngameBuilderPenalty': 0
                            }
                        }
                    },
					//{
                    //    name: 'lodOptionDuels',
                    //    extraInfo: 'lodOptionAboutDuels',
                    //    about: 'lodMutatorDuel'
                    //},
                    {
                        name: 'lodOptionRefreshCooldownsOnDeath',
                        about: 'lodMutatorRefreshCooldownsOnDeath'
                    },
                    {
                        name: 'lodOption322',
                        extraInfo: 'lodOptionAbout322',
                        about: 'lodMutator322'
                    },
                    {
                        name: 'lodOptionGottaGoFast',
                        extraInfo: 'lodOptionAboutGottaGoFast',
                        default: {
                            'lodMutatorGottaGoFastOff': 0,
                        },
                        states: {
                            'lodMutatorGottaGoQuickOn': 1,
                            'lodMutatorGottaGoFastOn': 2,
                            'lodMutatorGottaGoREALLYFast': 3,
                            'lodMutatorGottaGoSlow': 4
                        }
                    },
                    {
                        name: 'lodOptionExtraAbility',
                        default: {
                            'lodMutatorFreeAbility': 0,
                        },
                        states: {
                            'lodMutatorRandom': 1,
                            'lodMutatorSliders': 2,
                            'lodMutatorNothl': 3,
                            'lodMutatorMonkeyBusiness': 4,
                            'lodMutatorEcho': 5,
                            'lodMutatorFleashHeaps': 6,
                            'lodMutatorFury': 7,
                            'lodMutatorBashwars': 8,
                            'lodMutatorWitch': 9,
                            'lodMutatorTakeaim': 10,
                            'lodMutatorAether': 11,
                            'lodMutatorGreed': 12,
                            'lodMutatorNether': 13,
                            'lodMutatorShift': 14,
                            'lodMutatorMulticast': 15,
                            'lodMutatorCoup': 16,
                            'lodMutatorPermaInvis': 17,
                            'lodMutatorMultishot': 18,
                            'lodMutatorRespawn': 19,
                            'lodMutatorTrickshot': 20,
                            'lodMutatorBorrowed': 21,
                            'lodMutatorTesla': 22,
                            'lodMutatorSurvival': 23,
                        }
                    },
                    {
                        name: 'lodOptionGlobalCast',
                        about: 'lodMutatorGlobalCast'
                    },
                    {
                        name: 'lodOptionCooldownReduction',
                        patreon: true,
                        extraInfo: 'lodOptionAboutCooldownReduction',
                        about: 'lodMutatorCooldownReduction'
                    },
                    {
                        name: 'lodOptionMemesRedux',
                        extraInfo: 'lodOptionAboutMemesRedux',
                        about: 'lodMutatorMemesRedux'
                    },
                    {
                        name: 'lodOptionBattleThirst',
                        extraInfo: 'lodOptionAboutBattleThirst',
                        about: 'lodMutatorBattleThirst'
                    },
                    {
                        name: 'lodOptionDarkMoon',
                        extraInfo: 'lodOptionAboutDarkMoon',
                        about: 'lodMutatorDarkMoon'
                    },
                    {
                        name: 'lodOptionGoldDropOnDeath',
                        //patreon: false,
                        //extraInfo: 'lodOptionAboutGoldDropOnDeath',
                        about: 'lodMutatorGoldDropOnDeath'
                    },
                    {
                        name: 'lodOptionBlackForest',
                        extraInfo: 'lodOptionAboutBlackForest',
                        about: 'lodMutatorBlackForest'
                    },
                    {
                        name: 'lodOptionAntiRat',
                        extraInfo: 'lodOptionAboutAntiRat',
                        about: 'lodMutatorAntiRat'
                    },
                    {
                        name: 'lodOptionConsumeItems',
                        extraInfo: 'lodOptionAboutConsumeItems',
                        about: 'lodMutatorConsumeItems'
                    },
                    {
                        about: 'lodMutatorOGBonus',
                        default: {
                            'lodOptionNewAbilitiesBonusGold': 0,
                            'lodOptionNewAbilitiesThreshold': 0
                        },
                        states: {
                            'lodMutatorOGBonus1': {
                                'lodOptionNewAbilitiesBonusGold': 100,
                                'lodOptionNewAbilitiesThreshold': 20
                            },
                            'lodMutatorOGBonus2': {
                                'lodOptionNewAbilitiesBonusGold': 500,
                                'lodOptionNewAbilitiesThreshold': 20
                            },
                            'lodMutatorOGBonus3': {
                                'lodOptionNewAbilitiesBonusGold': 1000,
                                'lodOptionNewAbilitiesThreshold': 20
                            }
                        }
                    },
                    {
                        name: 'lodOptionLimitPassives',
                        extraInfo: 'lodOptionAboutLimitPassives',
                        about: 'lodMutatorLimitPassives'
                    },
                    {
                        name: 'lodOptionAntiBash',
                        extraInfo: 'lodOptionAboutAntiBash',
                        about: 'lodMutatorAntiBash'
                    },                   
                    {
                        name: 'lodOptionFastRunes',
                        //extraInfo: 'lodOptionAboutFastRunes',
                        about: 'lodMutatorFastRunes'
                    },
                    //{
                    //    name: 'lodOptionSuperRunes', 
                    //    extraInfo: 'lodOptionAboutSuperRunes',
                    //    about: 'lodMutatorSuperRunes'
                    //},
                    {
                        name: 'lodOptionPeriodicSpellCast',
                        patreon: true,
                        extraInfo: 'lodOptionAboutPeriodicSpellCast',
                        about: 'lodMutatorPeriodicSpellCast'
                    },
                    {
                        name: 'lodOptionDoubleTalents',
                        extraInfo: 'lodOptionAboutDoubleTalents',
                        about: 'lodMutatorDoubleTalents'
                    },
                    {
                        name: 'lodOptionConvertableTowers',
                        patreon: true,
                        //extraInfo: 'lodOptionAboutConvertableTowers',
                        about: 'lodMutatorConvertableTowers'
                    },
                    /*{
                        name: 'lodOptionVampirism',
                        extraInfo: 'lodOptionAboutVampirism',
                        about: 'lodMutatorVampirism'
                    },*/
                    {
                        name: 'lodOptionKillStreakPower',
                        //patreon: true,
                        extraInfo: 'lodOptionAboutKillStreakPower',
                        about: 'lodMutatorKillStreakPower'
                    }, 
                    {
                        name: 'lodOptionExplodeOnDeath',
                        //patreon: true,
                        //extraInfo: 'lodOptionAboutExplodeOnDeath',
                        about: 'lodMutatorExplodeOnDeath'
                    },
                    {
                        name: 'lodOptionNoHealthbars',
                        //patreon: true,
                        //extraInfo: 'lodOptionAboutNoHealthbars',
                        about: 'lodMutatorNoHealthbars'
                    },
                    
                    // {
                    //     name: 'lodOptionInstantCast',
                    //     extraInfo: 'lodOptionAboutInstantCast',
                    //     about: 'lodMutatorInstantCast'
                    // },
                    {
                         name: 'lodOptionRandomLaneCreeps',
                         patreon: true,
                         extraInfo: 'lodOptionAboutRandomLaneCreeps',
                         about: 'lodMutatorRandomLaneCreeps'
                    },            
                    {
                        about: 'lodMutatorRandomOnDeath',
                        patreon: true,
                        extraInfo: 'lodOptionAboutRandomOnDeath',
                        values: {
                            enabled: {
                                'lodOptionRandomOnDeath': 1
                            },
                            disabled: {
                                'lodOptionRandomOnDeath': 0
                            }
                        }
                    },	
                ]
            }
        ]
    }
}

var advancedOptions = {
    // The common stuff people play with
    common_selection: {
        custom: true,
        fields: [
            {
                name: 'lodOptionCommonGamemode',
                des: 'lodOptionDesCommonGamemode',
                about: 'lodOptionAboutCommonGamemode',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionAllPick',
                        value: 1
                    },
                    {
                        text: 'lodOptionSingleDraft',
                        value: 5
                    },
                    {
                        text: 'lodOptionMirrorDraft',
                        value: 3
                    },
                    {
                        text: 'lodOptionAllRandom',
                        value: 4
                    },
                    {
                        text: 'lodOptionBoosterDraft',
                        value: 6
                    }
                ]
            },
            {
                name: 'lodOptionCommonMaxSlots',
                des: 'lodOptionDesCommonMaxSlots',
                about: 'lodOptionAboutCommonMaxSlots',
                sort: 'range',
                min: 4,
                max: 6,
                step: 1,
                default: 6
            },
            {
                name: 'lodOptionCommonMaxSkills',
                des: 'lodOptionDesCommonMaxSkills',
                about: 'lodOptionAboutCommonMaxSkills',
                sort: 'range',
                min: 0,
                max: 6,
                step: 1,
                default: 6
            },
            {
                name: 'lodOptionCommonMaxUlts',
                des: 'lodOptionDesCommonMaxUlts',
                about: 'lodOptionAboutCommonMaxUlts',
                sort: 'range',
                min: 0,
                max: 6,
                step: 1,
                default: 2
            },
            {
                name: 'lodOptionCommonDraftAbilities',
                des: 'lodOptionsCommonDraftAbilities',
                about: 'lodOptionAboutCommonDraftAbilities',
                sort: 'range',
                min: 10,
                max: 400,
                step: 1,
                default: 100
            },
            {
                name: 'lodOptionBalanceMode',
                des: 'lodOptionDesBalanceMode',
                about: 'lodOptionAboutBalanceMode',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBalanceModePoints',
                des: 'lodOptionDesBalanceModePoints',
                about: 'lodOptionAboutBalanceModePoints',
                sort: 'range',
                min: 60,
                max: 400,
                step: 10,
                default: 120
            },
            //{
            //    name: 'lodOptionDuels',
            //    des: 'lodOptionDesDuels',
            //    about: 'lodOptionAboutDuels',
            //    sort: 'toggle',
            //    values: [
            //        {
            //            text: 'lodOptionNo',
            //            value: 0
            //        },
            //        {
            //            text: 'lodOptionYes',
            //            value: 1
            //        }
            //    ]
            //},
            {
                name: 'lodOptionIngameBuilder',
                des: 'lodOptionDesIngameBuilder',
                about: 'lodOptionAboutIngameBuilder',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionIngameBuilderPenalty',
                des: 'lodOptionDesIngameBuilderPenalty',
                about: 'lodOptionAboutIngameBuilderPenalty',
                sort: 'range',
                min: 0,
                max: 180,
                step: 1,
                default: 0,
            },
            {
                name: 'lodOptionNewAbilitiesBonusGold',
                des: 'lodOptionDesNewAbilitiesBonusGold',
                about: 'lodOptionAboutNewAbilitiesBonusGold',
                sort: 'range',
                min: 0,
                max: 2500,
                step: 50,
                default: 1000
            },
            {
                name: 'lodOptionNewAbilitiesThreshold',
                des: 'lodOptionDesNewAbilitiesThreshold',
                about: 'lodOptionAboutNewAbilitiesThreshold',
                sort: 'range',
                min: 0,
                max: 100,
                step: 1,
                default: 20
            },
            {
                name: 'lodOptionGlobalNewAbilitiesBonusGold',
                des: 'lodOptionDesGlobalNewAbilitiesBonusGold',
                about: 'lodOptionAboutGlobalNewAbilitiesBonusGold',
                sort: 'range',
                min: 0,
                max: 2500,
                step: 50,
                default: 1000
            },
            {
                name: 'lodOptionGlobalNewAbilitiesThreshold',
                des: 'lodOptionDesGlobalNewAbilitiesThreshold',
                about: 'lodOptionAboutGlobalNewAbilitiesThreshold',
                sort: 'range',
                min: 0,
                max: 100,
                step: 1,
                default: 20
            },
            {
                name: 'lodOptionBalancedBuildBonusGold',
                des: 'lodOptionDesBalancedBuildBonusGold',
                about: 'lodOptionAboutBalancedBuildBonusGold',
                sort: 'range',
                min: 0,
                max: 3000,
                step: 100,
                default: 0
            },
        ]
    },

    // Advanced stuff, for pros
    advanced_selection: {
        custom: true,
        fields: [
            {
                name: 'lodOptionAdvancedHeroAbilities',
                des: 'lodOptionDesAdvancedHeroAbilities',
                about: 'lodOptionAboutAdvancedHeroAbilities',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAdvancedNeutralAbilities',
                des: 'lodOptionDesAdvancedNeutralAbilities',
                about: 'lodOptionAboutAdvancedNeutralAbilities',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAdvancedCustomSkills',
                des: 'lodOptionDesAdvancedCustomSkills',
                about: 'lodOptionAboutAdvancedCustomSkills',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
               name: 'lodOptionAdvancedImbaAbilities',
               des: 'lodOptionDesAdvancedIMBASkills',
               about: 'lodOptionAboutAdvancedIMBASkills',
               sort: 'toggle',
               values: [
                   {
                       text: 'lodOptionNo',
                       value: 0
                   },
                   {
                       text: 'lodOptionYes',
                       value: 1
                   }
               ]
            },
            {
                name: 'lodOptionAdvancedHidePicks',
                des: 'lodOptionDesAdvancedHidePicks',
                about: 'lodOptionAboutAdvancedHidePicks',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAdvancedUniqueSkills',
                des: 'lodOptionDesAdvancedUniqueSkills',
                about: 'lodOptionAboutAdvancedUniqueSkills',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodUniqueSkillsOff',
                        value: 0
                    },
                    {
                        text: 'lodUniqueSkillsTeam',
                        value: 1
                    },
                    {
                        text: 'lodUniqueSkillsGlobal',
                        value: 2
                    },
                ]
            },       
            {
                name: 'lodOptionAdvancedUniqueHeroes',
                des: 'lodOptionDesAdvancedUniqueHeroes',
                about: 'lodOptionAboutAdvancedUniqueHeroes',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAdvancedSelectPrimaryAttr',
                des: 'lodOptionDesAdvancedSelectPrimaryAttr',
                about: 'lodOptionAboutAdvancedSelectPrimaryAttr',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionGameSpeedFreeCourier',
                des: 'lodOptionDesGameSpeedFreeCourier',
                about: 'lodOptionAboutGameSpeedFreeCourier',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionTurboCourier',
                des: 'lodOptionDesTurboCourier',
                about: 'lodOptionAboutTurboCourier',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionExtraAbility',
                des: 'lodOptionDesExtraAbility',
                about: 'lodOptionAboutExtraAbility',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionRandom',
                        value: 1
                    },
                    {
                        text: 'DOTA_Tooltip_ability_gemini_unstable_rift',
                        value: 2
                    },
                    {
                        text: 'DOTA_Tooltip_ability_imba_dazzle_shallow_grave_passive',
                        value: 3
                    },
                    {
                        text: 'DOTA_Tooltip_ability_imba_tower_forest',
                        value: 4
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ebf_rubick_arcane_echo',
                        value: 5
                    },
                    {
                        text: 'lodMutatorFleashHeaps',
                        value: 6
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ursa_fury_swipes',
                        value: 7
                    },
                    {
                        text: 'DOTA_Tooltip_ability_spirit_breaker_greater_bash',
                        value: 8
                    },
                    {
                        text: 'DOTA_Tooltip_ability_death_prophet_witchcraft',
                        value: 9
                    },
                    {
                        text: 'DOTA_Tooltip_ability_sniper_take_aim',
                        value: 10
                    },
                    {
                        text: 'DOTA_Tooltip_ability_aether_range_lod',
                        value: 11
                    },
                    {
                        text: 'DOTA_Tooltip_ability_alchemist_goblins_greed',
                        value: 12
                    },
                    {
                        text: 'DOTA_Tooltip_ability_angel_arena_nether_ritual',
                        value: 13
                    },
                    {
                        text: 'DOTA_Tooltip_ability_slark_essence_shift',
                        value: 14
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ogre_magi_multicast',
                        value: 15
                    },
                    {
                        text: 'DOTA_Tooltip_ability_phantom_assassin_coup_de_grace',
                        value: 16
                    },
                    {
                        text: 'DOTA_Tooltip_ability_riki_permanent_invisibility',
                        value: 17
                    },
                    {
                        text: 'DOTA_Tooltip_ability_imba_tower_multihit',
                        value: 18
                    },
                    {
                        text: 'DOTA_Tooltip_ability_skeleton_king_reincarnation',
                        value: 19
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ebf_clinkz_trickshot_passive',
                        value: 20
                    },
                    {
                        text: 'DOTA_Tooltip_ability_abaddon_borrowed_time',
                        value: 21
                    },
                    {
                        text: 'DOTA_Tooltip_ability_summoner_tesla_coil',
                        value: 22
                    },
                    {
                        text: 'lodMutatorSurvival',
                        value: 23
                    }
                ]
            },
        ]
    },

    // Changing what stuff is banned
    banning: {
        custom: true,
        fields: [
            {
                name: 'lodOptionBanningHostBanning',
                des: 'lodOptionDesBanningHostBanning',
                about: 'lodOptionAboutHostBanning',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBanningMaxBans',
                des: 'lodOptionDesBanningMaxBans',
                about: 'lodOptionAboutBanningMaxBans',
                sort: 'range',
                min: 0,
                max: 25,
                step: 1,
                default: 10
            },
            {
                name: 'lodOptionBanningMaxHeroBans',
                des: 'lodOptionDesBanningMaxHeroBans',
                about: 'lodOptionAboutBanningMaxHeroBans',
                sort: 'range',
                min: 0,
                max: 5,
                step: 1,
                default: 2
            },
            {
                name: 'lodOptionBanningBlockTrollCombos',
                des: 'lodOptionDesBanningBlockTrollCombos',
                about: 'lodOptionAboutBanningBlockTrollCombos',
                sort: 'toggle',
                requiresServerCheck: true,
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBanningUseBanList',
                des: 'lodOptionDesBanningUseBanList',
                about: 'lodOptionAboutBanningUseBanList',
                sort: 'toggle',
                requiresServerCheck: true,
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAdvancedOPAbilities',
                des: 'lodOptionDesAdvancedOPAbilities',
                about: 'lodOptionAboutAdvancedOPAbilities',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }

                ]
            },
            {
                name: 'lodOptionBanningBanInvis',
                des: 'lodOptionDesBanningBanInvis',
                about: 'lodOptionAboutBanningBanInvis',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionSkills',
                        value: 1
                    },
                    {
                        text: 'lodOptionSkillsAndItems',
                        value: 2
                    }
                ]
            },
            {
                name: 'lodOptionBanningBalanceMode',
                des: 'lodOptionDesBanningBalanceMode',
                about: 'lodOptionAboutBanningBalanceMode',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionDisablePerks',
                des: 'lodOptionDesDisablePerks',
                about: 'lodOptionAboutDisablePerks',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionConsumeItems',
                des: 'lodOptionDesConsumeItems',
                about: 'lodOptionAboutConsumeItems',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionLimitPassives',
                des: 'lodOptionDesLimitPassives',
                about: 'lodOptionAboutLimitPassives',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
        ]
    },

    // Changing the speed of the match
    game_speed: {
        custom: true,
        fields: [
            {
                name: 'lodOptionGameSpeedStartingLevel',
                des: 'lodOptionDesGameSpeedStartingLevel',
                about: 'lodOptionAboutGameSpeedStartingLevel',
                sort: 'range',
                min: 1,
                max: 100,
                step: 1,
                default: 1
            },
            {
                name: 'lodOptionGameSpeedMaxLevel',
                des: 'lodOptionDesGameSpeedMaxLevel',
                about: 'lodOptionAboutGameSpeedMaxLevel',
                sort: 'range',
                min: 6,
                max: 100,
                step: 1,
                default: 25
            },
            {
                name: 'lodOptionGameSpeedStartingGold',
                des: 'lodOptionDesGameSpeedStartingGold',
                about: 'lodOptionAboutGameSpeedStartingGold',
                sort: 'range',
                min: 0,
                max: 100000,
                step: 1,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedGoldTickRate',
                des: 'lodOptionDesGameSpeedGoldTickRate',
                about: 'lodOptionAboutGameSpeedGoldTickRate',
                sort: 'range',
                min: 0,
                max: 25,
                step: 1,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedGoldModifier',
                des: 'lodOptionDesGameSpeedGoldModifier',
                about: 'lodOptionAboutGameSpeedGoldModifier',
                sort: 'range',
                min: 0,
                max: 1000,
                step: 10,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedEXPModifier',
                des: 'lodOptionDesGameSpeedEXPModifier',
                about: 'lodOptionAboutGameSpeedEXPModifier',
                sort: 'range',
                min: 0,
                max: 1000,
                step: 10,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedRespawnTimePercentage',
                des: 'lodOptionDesGameSpeedRespawnTimePercentage',
                about: 'lodOptionAboutGameSpeedRespawnTimePercentage',
                sort: 'range',
                min: 0,
                max: 100,
                step: 1,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedRespawnTimeConstant',
                des: 'lodOptionDesGameSpeedRespawnTimeConstant',
                about: 'lodOptionAboutGameSpeedRespawnTimeConstant',
                sort: 'range',
                min: 0,
                max: 120,
                step: 1,
                default: 0
            },
            {
                name: 'lodOptionBuybackCooldownTimeConstant',
                des: 'lodOptionDesBuybackCooldownTimeConstant',
                about: 'lodOptionAboutBuybackCooldownTimeConstant',
                sort: 'range',
                min: 0,
                max: 420,
                step: 1,
                default: 0
            },
            {
                name: 'lodOptionGameSpeedUpgradedUlts',
                des: 'lodOptionDesGameSpeedUpgradedUlts',
                about: 'lodOptionAboutGameSpeedUpgradedUlts',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    },
                    {
                        text: 'lodOptionYesHumansOnly',
                        value: 2
                    },
                ]
            },
            {
                name: 'lodOptionGameSpeedSharedEXP',
                des: 'lodOptionDesGameSpeedSharedEXP',
                about: 'lodOptionAboutGameSpeedSharedEXP',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionRefreshCooldownsOnDeath',
                des: 'lodOptionDesRefreshCooldownsOnDeath',
                about: 'lodOptionAboutRefreshCooldownsOnDeath',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },

            /*{
                name: 'lodOptionCrazyEasymode',
                des: 'lodOptionDesCrazyEasymode',
                about: 'lodOptionAboutCrazyEasymode',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },*/
        ]
    },

    towers_creeps: {
        custom: true,
        fields: [
            {
                name: 'lodOptionGameSpeedTowersPerLane',
                des: 'lodOptionDesGameSpeedTowersPerLane',
                about: 'lodOptionAboutGameSpeedTowersPerLane',
                sort: 'range',
                min: 3,
                max: 10,
                step: 1,
                default: 3
            },
            {
                name: 'lodOptionGameSpeedStrongTowers',
                des: 'lodOptionDesGameSpeedStrongTowers',
                about: 'lodOptionAboutGameSpeedStrongTowers',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionAntiRat',
                des: 'lodOptionDesAntiRat',
                about: 'lodOptionAboutAntiRat',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionPocketTowers',
                des: 'lodOptionDesPocketTowers',
                about: 'lodOptionAboutPocketTowers',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNoPocketTowers',
                        value: 0
                    },{
                        text: 'lodOptionPocketTowersConsumable',
                        value: 1
                    },{
                        text: 'lodOptionPocketTowersCooldown60',
                        value: 60
                    },{
                        text: 'lodOptionPocketTowersCooldown120',
                        value: 120
                    },{
                        text: 'lodOptionPocketTowersCooldown180',
                        value: 180
                    },{
                        text: 'lodOptionPocketTowersCooldown240',
                        value: 240
                    },{
                        text: 'lodOptionPocketTowersCooldown300',
                        value: 300
                    },{
                        text: 'lodOptionPocketTowersCooldown600',
                        value: 600
                    }
                ]
            },
            {
                name: 'lodOptionConvertableTowers',
                des: 'lodOptionDesConvertableTowers',
                about: 'lodOptionAboutConvertableTowers',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionCreepPower',
                des: 'lodOptionDesCreepPower',
                about: 'lodOptionAboutCreepPower',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNoCreepPower',
                        value: 0
                    },
                    {
                        text: 'lodOptionNormal',
                        value: 120
                    },
                    {
                        text: 'lodOptionHigh',
                        value: 60
                    },
                    {
                        text: 'lodOptionExtreme',
                        value: 30
                    }
                ]
            },
            {
                name: 'lodOptionNeutralCreepPower',
                des: 'lodOptionDesNeutralCreepPower',
                about: 'lodOptionAboutNeutralCreepPower',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNoCreepPower',
                        value: 0
                    },
                    {
                        text: 'lodOptionNormal',
                        value: 120
                    },
                    {
                        text: 'lodOptionHigh',
                        value: 60
                    },
                    {
                        text: 'lodOptionExtreme',
                        value: 30
                    }
                ]
            },
            {
                name: 'lodOptionNeutralMultiply',
                des: 'lodOptionDesNeutralMultiply',
                about: 'lodOptionAboutNeutralMultiply',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 1
                    },
                    {
                        text: 'lodOptionDouble',
                        value: 2
                    },
                    {
                        text: 'lodOptionTriple',
                        value: 3
                    },
                    {
                        text: 'lodOptionQuadruple',
                        value: 4
                    }
                ]
            },
            {
                name: 'lodOptionLaneCreepBonusAbility',
                des: 'lodOptionDesLaneCreepBonusAbility',
                about: 'lodOptionAboutLaneCreepBonusAbility',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNoNeutralMultiply',
                        value: 0
                    },
                    {
                        text: 'lodMutatorRandomAll',
                        value: 1
                    },
                    {
                        text: 'lodMutatorRandomIndividual',
                        value: 2
                    },
                    {
                        text: 'lodMutatorBashwars',
                        value: 3
                    },
                    {
                        text: 'lodMutatorFeast',
                        value: 4
                    },
                    {
                        text: 'lodMutatorFury',
                        value: 5
                    },
                    {
                        text: 'lodMutatorTakeaim',
                        value: 6
                    },
                    {
                        text: 'lodMutatorSideGunner',
                        value: 7
                    },
                    {
                        text: 'lodMutatorReactive',
                        value: 8
                    },
                    {
                        text: 'lodMutatorBrawler',
                        value: 9
                    },
                    {
                        text: 'lodMutatorNothl',
                        value: 10
                    },
                    {
                        text: 'lodMutatorFervor',
                        value: 11
                    },
                    {
                        text: 'lodMutatorNether',
                        value: 12
                    },
                    {
                        text: 'lodMutatorTimeLock',
                        value: 13
                    },
                    {
                        text: 'lodMutatorMjolnir',
                        value: 14
                    }
                ]
            },
            {
                name: 'lodOptionLaneMultiply',
                des: 'lodOptionDesLaneMultiply',
                about: 'lodOptionAboutLaneMultiply',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionNoNeutralMultiply',
                        value: 0
                    },
                    {
                        text: 'lodOptionDouble',
                        value: 1
                    },
                    {
                        text: 'lodOptionTriple',
                        value: 2
                    },
                    {
                        text: 'lodOptionQuadruple',
                        value: 3
                    }
                ]
            },
            
            {

                name: 'lodOptionRandomLaneCreeps',
                des: 'lodOptionDesRandomLaneCreeps',
                about: 'lodOptionAboutRandomLaneCreeps',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionNormal',
                        value: 1
                    }/*,  
                    {
                        text: 'lodOptionMadness',
                        value: 2
                    }*/
                ]
            },
        ]
    },

    // Buffing of heroes, towers, etc
    /*buffs: {
        custom: true,
        fields: [

        ]
    },*/

    // Bot related stuff
    bots: {
        bot: true,
        custom: true,
        fields: [
            {
                name: 'lodOptionBotsRadiant',
                des: 'lodOptionDesBotsRadiant',
                about: 'lodOptionAboutBotRadiant',
                sort: 'range',
                min: 1,
                max: 10,
                step: 1,
                default: 5
            },
            {
                name: 'lodOptionBotsDire',
                des: 'lodOptionDesBotsDire',
                about: 'lodOptionAboutBotDire',
                sort: 'range',
                min: 1,
                max: 10,
                step: 1,
                default: 5
            },
            {
                name: 'lodOptionBotsRadiantDiff',
                des: 'lodOptionDesBotsRadiantDiff',
                about: 'lodOptionAboutBotsRadiantDiff',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBotPassive',
                        value: 0
                    },
                    {
                        text: 'lodOptionBotEasy',
                        value: 1
                    },
                    {
                        text: 'lodOptionBotMedium',
                        value: 2
                    },
                    {
                        text: 'lodOptionBotHard',
                        value: 3
                    },
                    {
                        text: 'lodOptionBotUnfair',
                        value: 4
                    },
                    {
                        text: 'lodOptionBotRandomIndividual',
                        value: 5
                    }
                ]
            },
            {
                name: 'lodOptionBotsDireDiff',
                des: 'lodOptionDesBotsDireDiff',
                about: 'lodOptionAboutBotsDireDiff',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionBotPassive',
                        value: 0
                    },
                    {
                        text: 'lodOptionBotEasy',
                        value: 1
                    },
                    {
                        text: 'lodOptionBotMedium',
                        value: 2
                    },
                    {
                        text: 'lodOptionBotHard',
                        value: 3
                    },
                    {
                        text: 'lodOptionBotUnfair',
                        value: 4
                    },
                    {
                        text: 'lodOptionBotRandomIndividual',
                        value: 5
                    }
                ]
            },
            {
                name: 'lodOptionBotsUniqueSkills',
                des: 'lodOptionDesBotsUniqueSkills',
                about: 'lodOptionAboutBotsUniqueSkills',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionUniqueDefault',
                        value: 0
                    },
                    {
                        text: 'lodOptionUniqueTeam',
                        value: 1
                    },
                    {
                        text: 'lodOptionUniqueGlobal',
                        value: 2
                    }
                ]
            },
            {
                name: 'lodOptionBotsSameHero',
                des: 'lodOptionDesBotsSameHero',
                about: 'lodOptionAboutBotsSameHero',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodUniqueSkillsOff',
                        value: 0
                    },
                    {
                        text: 'lodRandomHero',
                        value: 1
                    },
                    {
                        text: 'lodMutatorAxe',
                        value: 2
                    },
                    {
                        text: 'lodMutatorBane',
                        value: 3
                    },
                    {
                        text: 'lodMutatorBountyHunter',
                        value: 4
                    },
                    {
                        text: 'lodMutatorBloodseeker',
                        value: 5
                    },
                    {
                        text: 'lodMutatorBristleback',
                        value: 6
                    },
                    {
                        text: 'lodMutatorChaosKnight',
                        value: 7
                    },
                    {
                        text: 'lodMutatorCrystalMaiden',
                        value: 8
                    },
                    {
                        text: 'lodMutatorDazzle',
                        value: 9
                    },
                    {
                        text: 'lodMutatorDeathProphet',
                        value: 10
                    },
                    {
                        text: 'lodMutatorDragonKnight',
                        value: 11
                    },
                    {
                        text: 'lodMutatorDrowRanger',
                        value: 12
                    },
                    {
                        text: 'lodMutatorEarthshaker',
                        value: 13
                    },
                    {
                        text: 'lodMutatorJakiro',
                        value: 14
                    },
                    {
                        text: 'lodMutatorJuggernaut',
                        value: 15
                    },
                    {
                        text: 'lodMutatorKunkka',
                        value: 16
                    },
                    {
                        text: 'lodMutatorLich',
                        value: 17
                    },
                    {
                        text: 'lodMutatorLina',
                        value: 18
                    },
                    {
                        text: 'lodMutatorLion',
                        value: 19
                    },
                    {
                        text: 'lodMutatorLuna',
                        value: 20
                    },
                    {
                        text: 'lodMutatorNecrophos',
                        value: 21
                    },
                    {
                        text: 'lodMutatorOmniknight',
                        value: 22
                    },
                    {
                        text: 'lodMutatorOracle',
                        value: 23
                    },
                    {
                        text: 'lodMutatorPhantomAssassin',
                        value: 24
                    },
                    {
                        text: 'lodMutatorPudge',
                        value: 25
                    },
                    {
                        text: 'lodMutatorSandKing',
                        value: 26
                    },
                    {
                        text: 'lodMutatorShadowFiend',
                        value: 27
                    },
                    {
                        text: 'lodMutatorSkywrathMage',
                        value: 28
                    },
                    {
                        text: 'lodMutatorSniper',
                        value: 29
                    },
                    {
                        text: 'lodMutatorSven',
                        value: 30
                    },
                    {
                        text: 'lodMutatorTiny',
                        value: 31
                    },
                    {
                        text: 'lodMutatorVengefulSpirit',
                        value: 32
                    },
                    {
                        text: 'lodMutatorViper',
                        value: 33
                    },
                    {
                        text: 'lodMutatorWarlock',
                        value: 34
                    },
                    {
                        text: 'lodMutatorWindranger',
                        value: 35
                    },
                    {
                        text: 'lodMutatorWitchDoctor',
                        value: 36
                    },
                    {
                        text: 'lodMutatorWraithKing',
                        value: 37
                    },
                    {
                        text: 'lodMutatorZeus',
                        value: 38
                    }
                ]
            },
            {
                name: 'lodOptionBotsUnique',
                des: 'lodOptionDesBotsUnique',
                about: 'lodOptionAboutBotsUnique',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBotsStupid',
                des: 'lodOptionDesBotsStupid',
                about: 'lodOptionAboutBotsStupid',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBotsRestrict',
                des: 'lodOptionDesBotsRestrict',
                about: 'lodOptionAboutBotsRestrict',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionRestrictNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionRestrictRadiant',
                        value: 1
                    },
                    {
                        text: 'lodOptionRestrictDire',
                        value: 2
                    },
                    {
                        text: 'lodOptionRestrictBoth',
                        value: 3
                    }
                ]
            },
			//{
           //      name: 'lodOptionBotsBonusPoints',
           //      des: 'lodOptionDesBotsBonusPoints',
           //      about: 'lodOptionAboutBotsBonusPoints',
            //     sort: 'toggle',
            //     values: [
            //         {
            //             text: 'lodOptionNo',
            //             value: 0
           //          },
           //          {
           //              text: 'lodOptionYes',
           //              value: 1
           //          }
           //      ]
           //},

            /*{
                name: 'lodOptionBotsUnfairBalance',
                des: 'lodOptionDesBotsUnfairBalance',
                about: 'lodOptionAboutUnfairBalance',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },*/
        ]
    },

    // Stuff that is just crazy
    crazyness: {
        custom: true,
        fields: [
            {
                name: 'lodOptionCrazyNoCamping',
                des: 'lodOptionDesCrazyNoCamping',
                about: 'lodOptionAboutCrazyNoCamping',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionCrazyUniversalShop',
                des: 'lodOptionDesCrazyUniversalShop',
                about: 'lodOptionAboutCrazyUniversalShop',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionCrazyAllVision',
                des: 'lodOptionDesCrazyAllVision',
                about: 'lodOptionAboutCrazyAllVision',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionCrazyMulticast',
                des: 'lodOptionDesCrazyMulticast',
                about: 'lodOptionAboutCrazyMulticast',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionCrazyWTF',
                des: 'lodOptionDesCrazyWTF',
                about: 'lodOptionAboutCrazyWTF',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
			{
				name: 'lodOptionCrazyFatOMeter',
				des: 'lodOptionDesCrazyFatOMeter',
                about: 'lodOptionAboutCrazyFatOMeter',
                sort: 'dropdown',
				values: [
					{
						text: 'lodOptionNoFatOMeter',
						value: 0
					},
					{
						text: 'lodOptionFarmFatOMeter',
						value: 1
					},
					{
						text: 'lodOptionKDAFatOMeter',
						value: 2
					},
				]
			},
            {
                name: 'lodOption322',
                des: 'lodOptionDes322',
                about: 'lodOptionAbout322',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionGottaGoFast',
                des: 'lodOptionDesGottaGoFast',
                about: 'lodOptionAboutGottaGoFast',
                sort: 'dropdown',
                values: [
                    {
                        text: 'lodOptionGottaGoFastOff',
                        value: 0
                    },
                    {
                        text: 'lodOptionGottaGoQuickOn',
                        value: 1
                    },
                    {
                        text: 'lodOptionGottaGoFastOn',
                        value: 2
                    },
                    {
                        text: 'lodOptionGottaGoREALLYFast',
                        value: 3
                    },
                    {
                        text: 'lodOptionGottaGoSlow',
                        value: 4
                    },
                ]
            },
            {
                name: 'lodOptionGlobalCast',
                des: 'lodOptionDesGlobalCast',
                about: 'lodOptionAboutGlobalCast',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionMemesRedux',
                des: 'lodOptionDesMemesRedux',
                about: 'lodOptionAboutMemesRedux',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBattleThirst',
                des: 'lodOptionDesBattleThirst',
                about: 'lodOptionAboutBattleThirst',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionDarkMoon',
                des: 'lodOptionDesDarkMoon',
                about: 'lodOptionAboutDarkMoon',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionBlackForest',
                des: 'lodOptionDesBlackForest',
                about: 'lodOptionAboutBlackForest',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            
            {
                name: 'lodOptionAntiBash',
                des: 'lodOptionDesAntiBash',
                about: 'lodOptionAboutAntiBash',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionFastRunes',
                des: 'lodOptionDesFastRunes',
                about: 'lodOptionAboutFastRunes',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            /*{
                name: 'lodOptionSuperRunes',
                des: 'lodOptionDesSuperRunes',
                about: 'lodOptionAboutSuperRunes',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },*/
            {
                name: 'lodOptionPeriodicSpellCast',
                des: 'lodOptionDesPeriodicSpellCast',
                about: 'lodOptionAboutPeriodicSpellCast',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionDoubleTalents',
                des: 'lodOptionDesDoubleTalents',
                about: 'lodOptionAboutDoubleTalents',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {
                name: 'lodOptionRandomOnDeath',
                des: 'lodOptionDesRandomOnDeath',
                about: 'lodOptionAboutRandomOnDeath',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            /*{
                name: 'lodOptionVampirism',
                des: 'lodOptionDesVampirism',
                about: 'lodOptionAboutVampirism',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },*/
            {
                name: 'lodOptionKillStreakPower',
                des: 'lodOptionDesKillStreakPower',
                about: 'lodOptionAboutKillStreakPower',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {

                name: 'lodOptionCooldownReduction',
                des: 'lodOptionDesCooldownReduction',
                about: 'lodOptionAboutCooldownReduction',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {

                name: 'lodOptionGoldDropOnDeath',
                des: 'lodOptionDesGoldDropOnDeath',
                about: 'lodOptionAboutGoldDropOnDeath',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },
            {

                name: 'lodOptionExplodeOnDeath',
                des: 'lodOptionDesExplodeOnDeath',
                about: 'lodOptionAboutExplodeOnDeath',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },         
            {

                name: 'lodOptionNoHealthbars',
                des: 'lodOptionDesNoHealthbars',
                about: 'lodOptionAboutNoHealthbars',
                sort: 'toggle',
                values: [
                    {
                        text: 'lodOptionNo',
                        value: 0
                    },
                    {
                        text: 'lodOptionYes',
                        value: 1
                    }
                ]
            },        
            {
               name: 'lodOptionRandomLaneCreeps',
               des: 'lodOptionDesRandomLaneCreeps',
               about: 'lodOptionAboutRandomLaneCreeps',
               sort: 'toggle',
               values: [
                   {
                       text: 'lodOptionNo',
                       value: 0
                   },
                   {
                       text: 'lodOptionYes',
                       value: 1
                   }
               ]
            },
                
            {
               name: 'lodOptionResurrectAllies',
               des: 'lodOptionDesResurrectAllies',
               about: 'lodOptionAboutResurrectAllies',
               sort: 'toggle',
               values: [
                   {
                       text: 'lodOptionNo',
                       value: 0
                   },
                   {
                       text: 'lodOptionYes',
                       value: 1
                   }
               ]
            },
            //{
            //    name: 'lodOptionMonkeyBusiness',
            //    des: 'lodOptionDesMonkeyBusiness',
           //     about: 'lodOptionAboutMonkeyBusiness',
            //    sort: 'toggle',
           //     values: [
            //        {
            //            text: 'lodOptionNo',
            //            value: 0
            //        },
            //        {
            //            text: 'lodOptionYes',
            //            value: 1
            //        }
            //    ]
            //},
        ]
    },

    // items: {
    //     custom: true
    // }
}
