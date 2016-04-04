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

    -- Setup bots
    pregame.enabledBots = true
    pregame.desiredRadiant = 1
    pregame.desiredDire = 3

    -- Define bot builds
    pregame.premadeBotBuilds = {
    	dire = {
    		[1] = {
    			heroName = 'npc_dota_hero_axe',
    			build = {
    				[1] = 'antimage_blink',
    				[2] = 'antimage_mana_break',
    				[3] = 'antimage_mana_void',
    				[4] = 'antimage_spell_shield',
    				[5] = 'alchemist_acid_spray',
    				[6] = 'abyssal_underlord_pit_of_malice',
    			}
    		},
    		[2] = {
    			heroName = 'npc_dota_hero_pudge',
    			build = {
    				[1] = 'antimage_blink',
    				[2] = 'antimage_mana_break',
    				[3] = 'antimage_mana_void',
    				[4] = 'antimage_spell_shield',
    				[5] = 'alchemist_acid_spray',
    				[6] = 'abyssal_underlord_pit_of_malice',
    			}
    		},
    		[3] = {
    			heroName = 'npc_dota_hero_witch_doctor',
    			build = {
    				[1] = 'antimage_blink',
    				[2] = 'antimage_mana_break',
    				[3] = 'antimage_mana_void',
    				[4] = 'antimage_spell_shield',
    				[5] = 'alchemist_acid_spray',
    				[6] = 'abyssal_underlord_pit_of_malice',
    			}
    		},
    	}
	}

    -- Push everyone onto radiant
    for playerID=0,9 do
    	PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
    end

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