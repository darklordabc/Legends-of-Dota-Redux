function PrintTable(t, indent, done)
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    if getmetatable(t) then
        PrintTable(getmetatable(t).__index, indent, done)
    end

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

print("CSP was loaded!\n\n\n")

-- KV Files
local heroKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local subAbilities = LoadKeyValues("scripts/kv/abilityDeps.kv")
local abs = LoadKeyValues("scripts/kv/abilities.kv")
local vAbListSort = {}

-- Build skill list
for k,v in pairs(abs) do
    for kk, vv in pairs(v) do
        -- This comparison is really dodgy for some reason
        if tonumber(vv) == 1 then
            -- Store into the sort container
            if not vAbListSort[k] then
                vAbListSort[k] = {}
            end

            -- Store the sort reference
            table.insert(vAbListSort[k], kk)
        end
    end
end

local currentSkillList = {}
function GetHeroSkills(heroClass)
    local skills = {}

    -- Build list of abilities
    for heroName, values in pairs(heroKV) do
        if heroName == heroClass then
            for i = 1, 16 do
                local ab = values["Ability"..i]
                if ab and ab ~= 'attribute_bonus' then
                    table.insert(skills, ab)
                end
            end
        end
    end

    return skills
end

function RemoveAllSkills(hero)
    -- Check if we've touched this hero before
    if not currentSkillList[hero] then
        -- Grab the name of this hero
        local heroClass = hero:GetUnitName()

        local skills = GetHeroSkills(heroClass)

        -- Store it
        currentSkillList[hero] = skills
    end

    -- Remove all old skills
    for k,v in pairs(currentSkillList[hero]) do
        if hero:HasAbility(v) then
            hero:RemoveAbility(v)
        end
    end
end

function ApplyBuild(hero, build)
    -- Remove all old skills
    RemoveAllSkills(hero)

    -- Table to store all the extra skills we need to give
    local extraSkills = {}

    -- Give all the abilities in this build
    for k,v in ipairs(build) do
        -- Check if this skill has sub abilities
        if subAbilities[v] then
            -- Store that we need this skill
            extraSkills[subAbilities[v]] = true
        end

        -- Add to build
        hero:AddAbility(v)
        currentSkillList[hero][k] = v
    end

    -- Add missing abilities
    local i = #build+1
    for k,v in pairs(extraSkills) do
        -- Add the ability
        hero:AddAbility(k)

        -- Store that we have it
        currentSkillList[hero][i] = k

        -- Move onto the next slot
        i = i + 1
    end
end

function GetRandomAbility(sort)
    if not sort or not vAbListSort[sort] then
        sort = 'Abs'
    end

    return vAbListSort[sort][math.random(1, #vAbListSort[sort])]
end

-- The minimal base a hero can have
local baseAttr = 10

-- How many points to randomly allocate
local bonusPoints = 45

-- The minimal gain
local baseGain = 1

-- Total points to distribute over gains
local bonusGain = 10

-- Max number of points to allocate to speed / armor
local bonusSpeedPoints = 9

local heroStats = {}

function updateHero(hero)
    local playerID = hero:GetPlayerID()
    local stats = heroStats[playerID]

    if not stats then
        -- Create new stat store
        stats = {}

        --[[
            Base Stats
        ]]

        local pointsLeft = bonusPoints
        local n = 0

        local res = {}

        -- Change random seed
        local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
        math.randomseed(tonumber(timeTxt))

        n = math.random(8, math.min(pointsLeft, 30))
        pointsLeft = pointsLeft-n
        table.insert(res, n)

        n = math.random(8, math.min(pointsLeft, 30))
        pointsLeft = pointsLeft-n
        table.insert(res, n)
        table.insert(res, pointsLeft)

        stats.baseStr = baseAttr + table.remove(res, math.random(1, #res))
        stats.baseAgi = baseAttr + table.remove(res, math.random(1, #res))
        stats.baseInt = baseAttr + table.remove(res, math.random(1, #res))

        --[[
            Stat gains
        ]]
        pointsLeft = bonusGain

        n = math.random(1, math.min(pointsLeft, 5))
        pointsLeft = pointsLeft-n
        table.insert(res, n)

        n = math.random(1, math.min(pointsLeft, 5))
        pointsLeft = pointsLeft-n
        table.insert(res, n)
        table.insert(res, pointsLeft)

        stats.gainStr = baseGain + table.remove(res, math.random(1, #res))
        stats.gainAgi = baseGain + table.remove(res, math.random(1, #res))
        stats.gainInt = baseGain + table.remove(res, math.random(1, #res))

        --[[
            Move Speed
        ]]
        local speedPoints = math.random(0, bonusSpeedPoints)
        stats.baseMoveSpeed = 260 + speedPoints*10

        --[[
            Damage
        ]]
        stats.baseDamageMin = 40
        stats.baseDamageMax = 40

        --[[
            Armor Values
        ]]
        local armorPoints = (bonusSpeedPoints - speedPoints)
        stats.baseArmor = armorPoints * 1
        stats.baseMagicResist = 0.25 + armorPoints*0.01

        --[[
            HP + Mana
        ]]
        stats.baseHP = 100
        stats.baseHPRegen = 1
        stats.baseManaRegen = 1

        --[[
            Attacking
        ]]
        stats.baseAttackTime = 1.5

        -- Generate a random build
        stats.build = {
            [1] = GetRandomAbility(),
            [2] = GetRandomAbility(),
            [3] = GetRandomAbility(),
            [4] = GetRandomAbility('Ults')
        }

        --[[
            Store stats
        ]]
        heroStats[playerID] = stats
    end

    local level = hero:GetLevel()

    -- Workout how much stats this hero should have
    local str = stats.baseStr + stats.gainStr * (level-1)
    local agi = stats.baseAgi + stats.gainAgi * (level-1)
    local int = stats.baseInt + stats.gainInt * (level-1)

    -- Fix weird dota stats
    if level > 1 then
        str = str - hero:GetStrengthGain()
        agi = agi - hero:GetAgilityGain()
        int = int - hero:GetIntellectGain()
    end

    -- Change stats
    hero:SetBaseStrength(str)
    hero:SetBaseAgility(agi)
    hero:SetBaseIntellect(int)

    -- Change damage
    hero:SetBaseDamageMin(stats.baseDamageMin)
    hero:SetBaseDamageMax(stats.baseDamageMax)

    -- Change armor
    hero:SetPhysicalArmorBaseValue(stats.baseArmor)
    hero:SetBaseMagicalResistanceValue(stats.baseMagicResist)

    -- Change HP + Mana
    hero:SetBaseMaxHealth(stats.baseHP)
    hero:SetBaseHealthRegen(stats.baseHPRegen)
    hero:SetBaseManaRegen(stats.baseManaRegen)

    -- Move Speed
    hero:SetBaseMoveSpeed(stats.baseMoveSpeed)

    -- Attack time
    hero:SetBaseAttackTime(stats.baseAttackTime)
end

--[[local patchedExp = false
local maxLevel = 3
local baseExp = 1000
local increasePerLevel = 100

local expValues = {}
for i=1, maxLevel do
    print(i.." - "..baseExp+(increasePerLevel*i))
    table.insert(expValues, (baseExp+increasePerLevel*i))
end]]


ListenToGameEvent('npc_spawned', function(self, keys)
    -- Grab the spawned unit
    local spawnedUnit = EntIndexToHScript(keys.entindex)
    if spawnedUnit:IsRealHero() then
        -- Update it
        updateHero(spawnedUnit)

        -- Grab playerID
        local playerID = spawnedUnit:GetPlayerID()

        -- Apply random skills
        if not PlayerResource:IsFakeClient(playerID) then
            ApplyBuild(spawnedUnit, heroStats[playerID].build)
        end
    end
end, {})

ListenToGameEvent('dota_player_gained_level', function(self, keys)
    local hero = PlayerResource:GetSelectedHeroEntity(keys.player-1)
    if hero == nil then
        print("Failed to find hero!")
        return
    end

    -- Update this hero
    updateHero(hero)
end, {})

--PrecacheResource('particles/units/heroes/hero_queenofpain.pcf')

-- Precache everything -- Having issues with the arguments changing
print('Precaching stuff...')



--PrecacheResource('test', 'test')
print('Done precaching!')
