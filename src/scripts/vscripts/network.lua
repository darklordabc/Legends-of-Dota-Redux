-- Imports
local constants = require('constants')

-- A store for all the net table stuff
local Network = class({})

-- Init network stuff
function Network:init()

end

-- Updates which phase we are currently in
function Network:setPhase(newPhaseNumber)
    CustomNetTables:SetTableValue('phase_pregame', 'phase', {v = newPhaseNumber});
end

-- Sets when this phase will end
function Network:setEndOfPhase(endTime)
    CustomNetTables:SetTableValue('phase_pregame', 'endOfTimer', {v = endTime});
end

-- Return an instance of it
return Network()
