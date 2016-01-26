-- Imports
local constants = require('constants')

-- A store for all the net table stuff
local Network = class({})

-- Init network stuff
function Network:init()

end

-- Updates which phase we are currently in
function Network:setPhase(newPhaseNumber)
    CustomNetTables:SetTableValue('phase_pregame', 'phase', {v = newPhaseNumber})
end

-- Sets when this phase will end
function Network:setEndOfPhase(endTime)
    CustomNetTables:SetTableValue('phase_pregame', 'endOfTimer', {v = endTime})
end

-- Sets the active tab
function Network:setActiveOptionsTab(newActiveTab)
    CustomNetTables:SetTableValue('phase_pregame', 'activeTab', {v = newActiveTab})
end

-- Set an option
function Network:setOption(optionName, optionValue)
    CustomNetTables:SetTableValue('options', optionName, {v = optionValue})
end

-- Sets the network hero data
function Network:setHeroData(heroName, heroData)
    CustomNetTables:SetTableValue('heroes', heroName, heroData)
end

-- Sets a player's selected hero
function Network:setSelectedHero(playerID, heroName)
    CustomNetTables:SetTableValue('selected_heroes', tostring(playerID), {
        heroName = heroName,
        playerID = playerID
    })
end

-- Return an instance of it
return Network()
