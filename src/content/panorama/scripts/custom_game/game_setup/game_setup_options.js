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
                            'lodMutatorMaxLevel1': 25,
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
                                'lodOptionGameSpeedStartingLevel': 6
                            },
                            disabled: {
                                'lodOptionGameSpeedStartingGold': 0,
                                'lodOptionGameSpeedStartingLevel': 1
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
                        name: 'lodOptionGameSpeedStrongTowers',
                        about: 'lodMutatorStrongTowers'
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
                    },{
                        name: 'lodOptionBanningBanInvis',
                        about: 'lodMutatorBanningBanInvis'
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
                            'lodMutatorGoldTickRate3': 3
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
					{
                        name: 'lodOptionDuels',
                        extraInfo: 'lodOptionAboutDuels',
                        about: 'lodMutatorDuel'
                    },
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
                            'lodMutatorSliders': 1,
                            'lodMutatorNothl': 2,
                            'lodMutatorMonkeyBusiness': 3,
                            'lodMutatorEcho': 4,
                            'lodMutatorFleashHeaps': 5,
                            'lodMutatorFury': 6,
                            'lodMutatorBashwars': 7,
                            'lodMutatorWitch': 8,
                            'lodMutatorTakeaim': 9,
                            'lodMutatorAether': 10,
                            'lodMutatorGreed': 11,
                            'lodMutatorNether': 12,
                        }
                    },
                    {
                        name: 'lodOptionGlobalCast',
                        about: 'lodMutatorGlobalCast'
                    },
                    {
                         name: 'lodOptionMemesRedux',
                         extraInfo: 'lodOptionAboutMemesRedux',
                        about: 'lodMutatorMemesRedux'
                    },
                    //{
                   //     name: 'lodOptionMonkeyBusiness',        
                   //     extraInfo: 'lodOptionAboutMonkeyBusiness',
                   //     about: 'lodMutatorMonkeyBusiness',
                   // },
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
                name: 'lodOptionDuels',
                des: 'lodOptionDesDuels',
                about: 'lodOptionAboutDuels',
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
                        text: 'DOTA_Tooltip_ability_gemini_unstable_rift',
                        value: 1
                    },
                    {
                        text: 'DOTA_Tooltip_ability_imba_dazzle_shallow_grave',
                        value: 2
                    },
                    {
                        text: 'DOTA_Tooltip_ability_imba_tower_forest',
                        value: 3
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ebf_rubick_arcane_echo',
                        value: 4
                    },
                    {
                        text: 'lodMutatorFleashHeaps',
                        value: 5
                    },
                    {
                        text: 'DOTA_Tooltip_ability_ursa_fury_swipes',
                        value: 6
                    },
                    {
                        text: 'DOTA_Tooltip_ability_spirit_breaker_greater_bash',
                        value: 7
                    },
                    {
                        text: 'DOTA_Tooltip_ability_death_prophet_witchcraft',
                        value: 8
                    },
                    {
                        text: 'DOTA_Tooltip_ability_sniper_take_aim',
                        value: 9
                    },
                    {
                        text: 'DOTA_Tooltip_ability_aether_range_lod',
                        value: 10
                    },
                    {
                        text: 'DOTA_Tooltip_ability_alchemist_goblins_greed',
                        value: 11
                    },
                    {
                        text: 'DOTA_Tooltip_ability_angel_arena_nether_ritual',
                        value: 12
                    }
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
    }
}