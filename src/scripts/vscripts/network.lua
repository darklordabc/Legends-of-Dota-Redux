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

-- Networks flag info
function Network:setFlagData(abilityName, flagData)
    CustomNetTables:SetTableValue('flags', abilityName, flagData)
end

-- Sets a player's selected hero
function Network:setSelectedHero(playerID, heroName)
    CustomNetTables:SetTableValue('selected_heroes', tostring(playerID), {
        heroName = heroName,
        playerID = playerID
    })
end

-- Sets a player's selected primary attribute
function Network:setSelectedAttr(playerID, newAttr)
    CustomNetTables:SetTableValue('selected_attr', tostring(playerID), {
        newAttr = newAttr,
        playerID = playerID
    })
end

-- Puts a skill into a slot, NO VALIDATION
function Network:setSelectedAbilities(playerID, skills)
    -- Push to everyone
    CustomNetTables:SetTableValue('selected_skills', tostring(playerID), {
        playerID = playerID,
        skills = skills
    })
end

-- Return an instance of it
return Network()
