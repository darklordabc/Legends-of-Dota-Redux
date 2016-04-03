local constants = require('constants')
local OptionManager = require('optionmanager')

-- Setup the challenge module
local challenge = {}

-- Call to init challenge mode
function challenge:setup(pregame)
	-- Prevent multiple calls
	if self.doneSetup then return end
	self.doneSetup = true

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

-- Return the class to use
return challenge