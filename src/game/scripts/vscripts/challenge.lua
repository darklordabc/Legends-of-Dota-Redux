local constants = require('constants')
local OptionManager = require('optionmanager')

-- Setup the challenge module
local challenge = {}

-- Call to init challenge mode
function challenge:setup(pregame)
	-- Prevent multiple calls
	if self.doneSetup then return end
	self.doneSetup = true

	-- Challenge name
	self.challengeName = 'Debug Test Challenge'

	-- Push options
	pregame:setOption('lodOptionGamemode', 1)
	pregame:setOption('lodOptionGamemode', -1)
	pregame:setOption('lodOptionSlots', 6)
    pregame:setOption('lodOptionUlts', 2)
    pregame:setOption('lodOptionAdvancedHidePicks', 0)
    pregame:setOption('lodOptionGameSpeedUpgradedUlts', 1)
    pregame:setOption('lodOptionGameSpeedStartingLevel', 7)
    pregame:setOption('lodOptionGameSpeedStartingGold', 4375)
    pregame:setOption('lodOptionBanningBanInvis', 1)

    -- Ban some abilities
    pregame:banAbility('slark_essence_shift')
    pregame:banAbility('windrunner_focusfire')
    pregame:banAbility('silencer_glaives_of_wisdom')
    pregame:banAbility('alchemist_chemical_rage')
    pregame:banAbility('necronomicon_warrior_mana_burn_lod')
    pregame:banAbility('necronomicon_warrior_last_will_lod')
    pregame:banAbility('tiny_grow_lod')
    pregame:banAbility('obsidian_destroyer_arcane_orb')
    pregame:banAbility('ursa_overpower')
    pregame:banAbility('life_stealer_feast')
    pregame:banAbility('necrolyte_heartstopper_aura')

    -- Setup bots
    pregame.enabledBots = true
    pregame.desiredRadiant = 1
    pregame.desiredDire = 3

    -- Define bot builds
    pregame.premadeBotBuilds = {
    	dire = {
    		[1] = {
    			heroName = 'npc_dota_hero_lich',
    			build = {
    				[1] = 'lich_frost_nova',
    				[2] = 'lich_frost_armor',
    				[3] = 'lich_dark_ritual',
    				[4] = 'holdout_arcane_aura',
    				[5] = 'holdout_arcane_aura',
    				[6] = 'lich_chain_frost',
    			}
    		},
    		[2] = {
    			heroName = 'npc_dota_hero_witch_doctor',
    			build = {
    				[1] = 'witch_doctor_paralyzing_cask',
    				[2] = 'witch_doctor_voodoo_restoration',
    				[3] = 'witch_doctor_maledict',
    				[4] = 'drow_ranger_marksmanship`',
    				[5] = 'magnataur_empower',
    				[6] = 'witch_doctor_death_ward',
    			}
    		},
    		[3] = {
    			heroName = 'npc_dota_hero_pudge',
    			build = {
    				[1] = 'pudge_meat_hook',
    				[2] = 'pudge_rot',
    				[3] = 'pudge_flesh_heap',
    				[4] = 'skeleton_king_vampiric_aura',
    				[5] = 'skeleton_king_reincarnation',
    				[6] = 'pudge_dismember',
    			}
    		},
    	}
	}

    -- Push everyone onto radiant
    for playerID=0,9 do
    	PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
    end

    -- Swap to option select so we can lock the options
    pregame:setPhase(constants.PHASE_OPTION_SELECTION)

    -- Finish option selection
    pregame:finishOptionSelection()

    -- Move to skill selection phase
	pregame:setPhase(constants.PHASE_SELECTION)
	pregame:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'), OptionManager:GetOption('pickingTime'))

	print('Challenge mode was loaded!')
end

-- Returns the name of this challenge
function challenge:getChallengeName()
	return self.challengeName
end

-- Return the class to use
return challenge