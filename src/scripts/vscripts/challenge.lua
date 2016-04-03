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
	self:setOption('lodOptionGamemode', 1)
	self:setOption('lodOptionSlots', 6)
    self:setOption('lodOptionUlts', 2)

    pregame.doneBotStuff = true
    pregame.enabledBots = true

    -- Move to skill selection phase
	self:setPhase(constants.PHASE_SELECTION)
	self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'), OptionManager:GetOption('pickingTime'))
end

-- Return the class to use
return challenge