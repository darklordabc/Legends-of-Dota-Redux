--[[
    Skill Managing Library for swapping skills during runtime
]]

-- Keeps track of what skills a given hero has
local currentSkillList = {}

-- Contains info on heroes
local heroListKV = LoadKeyValues("scripts/npc/npc_heroes.txt")

-- A list of sub abilities needed to give out when we add an ability
local subAbilities = LoadKeyValues("scripts/kv/abilityDeps.kv")

-- List of units that we can precache
local unitList = LoadKeyValues("scripts/npc/npc_units_custom.txt")

-- This object will be exported
local skillManager = {}

local meleeMap = {
    -- Remap troll ulty
    troll_warlord_berserkers_rage = 'troll_warlord_berserkers_rage_melee'
}

local meleeList = {}
for heroName, values in pairs(heroListKV) do
    if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' then
        if values.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK' then
            meleeList[heroName] = true
        end
    end
end

local manualActivate = {
    keeper_of_the_light_blinding_light_lod = true,
    keeper_of_the_light_recall_lod = true
}

local heroIDToName = {}
local skillOwningHero = {}
for k,v in pairs(heroListKV) do
    if k ~= 'Version' and k ~= 'npc_dota_hero_base' then
        -- If this hero has an ID
        if v.HeroID then
            -- Store the heroID lookup
            heroIDToName[v.HeroID] = k

            -- Loop over all possible 16 slots
            for i=1,16 do
                -- Grab the ability
                local ab = v['Ability'..i]

                -- Did we actually find an ability?
                if ab then
                    -- Yep, store this hero as the owner
                    skillOwningHero[ab] = v.HeroID
                end
            end
        end
    end
end

function lod:precacheAll(context)
    --[[for k,v in pairs(heroIDToName) do
        PrecacheUnitByNameSync('npc_precache_'..v, context)
    end]]

    --PrecacheUnitByNameSync('npc_precache_everything', context)
end

local ownersKV = LoadKeyValues('scripts/kv/owners.kv')
for k,v in pairs(ownersKV) do
    skillOwningHero[k] = tonumber(v)
end

-- Tells you if a given heroName is melee or not
local function isMeleeHero(heroName)
    if meleeList[heroName] then
        return true
    end

    return false
end

local function fixModifiers(hero, skill)
    -- Remove it
    hero:RemoveModifierByName('modifier_'..skill)
    hero:RemoveModifierByName('modifier_'..skill..'_aura')
end

local function unitExists(unitName)
    -- Check if the unit exists
    if unitList[unitName] then return true end

    return false
end

-- Precaches a skill -- DODGY!
local alreadyCached = {}
local function precacheSkill(skillName)
    local heroID = skillOwningHero[skillName]

    if heroID then
        local heroName = heroIDToName[heroID]

        if heroName then
            -- Have we already cached this?
            if alreadyCached[heroName] then return end
            alreadyCached[heroName] = true

            -- Cache it
            if GameRules:isSource1() then
                -- Ensure it exists
                if unitExists('npc_precache_'..heroName..'_s1') then
                    CreateUnitByName('npc_precache_'..heroName..'_s1', Vector(-10000, -10000, 0), false, nil, nil, 0)
                else
                    print('Failed to precache unit: npc_precache_'..heroName..'_s1')
                end
            else
                -- Ensure it exists
                if unitExists('npc_precache_'..heroName..'_s2') then
                    -- Precache source2 style
                    PrecacheUnitByNameAsync('npc_precache_'..heroName..'_s2', function()
                        CreateUnitByName('npc_precache_'..heroName..'_s2', Vector(-10000, -10000, 0), false, nil, nil, 0)
                    end)
                else
                    print('Failed to precache unit: npc_precache_'..heroName..'_s2')
                end
            end
        end
    end
end

function skillManager:GetHeroSkills(heroClass)
    local skills = {}

    -- Build list of abilities
    for heroName, values in pairs(heroListKV) do
        if heroName == heroClass then
            for i = 1, 16 do
                local ab = values["Ability"..i]
                if ab and ab ~= 'attribute_bonus' then
                    table.insert(skills, ab)
                end
            end
        end
    end

    if heroClass == 'npc_dota_lone_druid_bear2' then
        table.insert(skills, 'lone_druid_spirit_bear_return')
    elseif heroClass == 'npc_dota_lone_druid_bear3' then
        table.insert(skills, 'lone_druid_spirit_bear_return')
        table.insert(skills, 'lone_druid_spirit_bear_entangle')
    elseif heroClass == 'npc_dota_lone_druid_bear4' then
        table.insert(skills, 'lone_druid_spirit_bear_return')
        table.insert(skills, 'lone_druid_spirit_bear_entangle')
        table.insert(skills, 'lone_druid_spirit_bear_demolish')
    end

    return skills
end

function skillManager:BuildSkillList(hero)
    -- Check if we've touched this hero before
    if not currentSkillList[hero] then
        -- Grab the name of this hero
        local heroClass = hero:GetUnitName()

        -- Grab the skills
        local skills = self:GetHeroSkills(heroClass)

        -- Store it
        currentSkillList[hero] = skills
    end
end

function skillManager:RemoveAllSkills(hero)
    -- Ensure the hero isn't nil
    if hero == nil then return end

    -- Build the skill list
    self:BuildSkillList(hero)

    -- Remove all old skills
    for k,v in pairs(currentSkillList[hero]) do
        if hero:HasAbility(v) then
            hero:FindAbilityByName(v):SetHidden(true)
        end
    end
end

local inSwap = false
function skillManager:ApplyBuild(hero, build)
    -- Ensure the hero isn't nil
    if hero == nil or not hero:IsAlive() then return end

    -- If we are currently swapping a hero, ignore
    if inSwap then return end

    -- Check if there is a new hero
    if hero:IsHero() then
        local playerID = hero:GetPlayerID()
        local realHero = PlayerResource:GetSelectedHeroEntity(playerID)

        if hero:IsRealHero() and build.hero and (not realHero or realHero == hero) then
            -- Reset current skills
            currentSkillList[hero] = nil

            -- Store gold
            local ug = PlayerResource:GetUnreliableGold(playerID)
            local rg = PlayerResource:GetReliableGold(playerID)

            -- Grab HP and mana percent
            local hp = hero:GetHealthPercent()
            local mana = hero:GetManaPercent()

            -- Get their position
            local pos = hero:GetOrigin()

            -- Store items
            local items = {}
            for i=0,11 do
                local item = hero:GetItemInSlot(i)
                if item then
                    items[i] = {
                        class = item:GetClassname(),
                        charges = item:GetCurrentCharges(),
                        purchaser = item:GetPurchaser(),
                        purchaseTime = item:GetPurchaseTime(),
                    }

                    -- Check if we need to replace the purchaser
                    if item:GetPurchaser() == hero then
                        items[i].replacePurchaser = true
                    end

                    item:Remove()
                end
            end

            -- Replace the hero
            inSwap = true
            hero = PlayerResource:ReplaceHeroWith(playerID, build.hero, 0, hero:GetCurrentXP())
            inSwap = false

            -- Ensure swap is successful
            if not hero then return end

            -- Replace gold
            PlayerResource:SetGold(playerID, ug, false)
            PlayerResource:SetGold(playerID, rg, true)

            -- Replace HP and mana percent
            hero:SetHealth(math.ceil(hp/100 * hero:GetMaxHealth()))
            hero:SetMana(mana/100 * hero:GetMaxMana())

            -- Reset their position
            hero:SetOrigin(pos)

            -- Replace items
            local removeMe = {}
            for i=0,11 do
                local item = items[i]

                if item then
                    local purchaser = item.purchaser
                    if item.replacePurchaser then
                        purchaser = hero
                    end

                    local newItem = CreateItem(item.class, purchaser, purchaser)
                    newItem:SetCurrentCharges(item.charges)
                    newItem:SetPurchaser(purchaser)
                    newItem:SetPurchaseTime(item.purchaseTime)

                    hero:AddItem(newItem)
                else
                    local tmpItem = CreateItem('item_branches', hero, hero)
                    hero:AddItem(tmpItem)
                    table.insert(removeMe, tmpItem)
                end
            end

            for k,v in pairs(removeMe) do
                v:Remove()
            end

            -- Reset current skills
            currentSkillList[hero] = nil

            -- Reset ability points
            hero:SetAbilityPoints(hero:GetLevel())
        end
    end

    -- Store the hero of this build
    build.hero = hero:GetClassname()

    -- Build the skill list
    self:BuildSkillList(hero)

    -- Remove all the skills from this hero
    self:RemoveAllSkills(hero)

    -- Table to store all the extra skills we need to give
    local extraSkills = {}

    -- Check if this hero is a melee hero
    local melee = isMeleeHero(hero:GetClassname())

    -- Devour fix
    --[[for i=1,6 do
        local v = build[i]
        if v == 'doom_bringer_devour' then
            -- We need the empty slots in 4 & 5
            build[4] = 'doom_bringer_empty1'
            build[5] = 'doom_bringer_empty2'
            break
        end
    end]]

    -- Spell steal fix
    local spellSteal = false
    for i=1,6 do
        local v = build[i]
        if v == 'rubick_spell_steal' then
            table.remove(build, i)
            spellSteal = true
        end
    end

    if spellSteal then
        build[4] = 'rubick_spell_steal'
        build[5] = nil
        build[6] = nil
    end

    -- Devour fix
    local devFix = false
    for i=1,6 do
        local v = build[i]
        if v == 'doom_bringer_devour' then
            table.remove(build, i)
            devFix = true
        end
    end

    if devFix then
        build[4] = 'doom_bringer_devour'
        build[5] = nil
        build[6] = nil
    end

    -- List of abilities we've already seen
    local seenAbilities = {}

    -- Build slot list for swapping
    --[[local slotList = {}
    local slotCount = 0
    for i=1,16 do
        local ab = hero:GetAbilityByIndex(i)
        if ab then
            slotList[i] = ab:GetClassname()
            slotCount = slotCount+1
        end
    end]]

    -- Copy
    local abs = {}
    for k,v in ipairs(currentSkillList[hero]) do
        table.insert(abs, v)
    end

    local isTower = hero:GetClassname() == 'npc_dota_tower'

    -- Give all the abilities in this build
    local abNum = 0
    for i=1,16 do
        local v = build[i]
        if v then
            --slotCount = slotCount+1
            abNum=abNum+1
            -- Check if this skill has sub abilities
            if subAbilities[v] then
                local skillSplit = vlua.split(subAbilities[v], '||')

                for kk,vv in pairs(skillSplit) do
                    -- Store that we need this skill
                    extraSkills[vv] = true
                end
            end

            -- Do melee heroes need a different skill?
            if melee and meleeMap[v] then
                build[i] = meleeMap[v]
                v = meleeMap[v]
            end

            -- Precache
            precacheSkill(v)

            -- Add to build
            if not seenAbilities[v] and hero:HasAbility(v) then
                -- Hero already has, lets hook and move it
                local oldAb = hero:FindAbilityByName(v)

                -- Enable it
                oldAb:SetHidden(false)
            else
                hero:AddAbility(v)

                -- Insert
                table.insert(abs, v)
            end

            -- If it's a tower, level it
            if isTower then
                local ab = hero:FindAbilityByName(v)
                if ab then
                    local requiredLevel = ab:GetMaxLevel()
                    ab:SetLevel(requiredLevel)
                end
            end

            -- We need to actually add it next time
            seenAbilities[v] = true

            currentSkillList[hero][abNum] = v

            -- Do we need to manually activate this skill?
            if manualActivate[v] then
                hero:FindAbilityByName(v):SetActivated(true)
            end

            -- Remove auras
            if not isTower then
                fixModifiers(hero, v)
            end
        end
    end

    -- Tower patcher
    --[[if isTower then
        if hero:HasAbility('backdoor_protection') then
            --build[7] = 'backdoor_protection'
            table.insert(abs, 'backdoor_protection')
        elseif hero:HasAbility('backdoor_protection_in_base') then
            --build[7] = 'backdoor_protection_in_base'
            table.insert(abs, 'backdoor_protection_in_base')
        else
            --hero:AddAbility('backdoor_protection')
        end
    end]]

    -- Do a nice little sort
    for i=1,16 do
        local v = build[i]
        if v then
            local inSlot = abs[i]

            if inSlot and inSlot ~= v then
                -- Swap in dota
                hero:SwapAbilities(v, inSlot, true, true)

                -- Perform swap internally
                for j=i+1,16 do
                    if build[i] == abs[j] then
                        abs[j] = abs[i]
                        break
                    end
                end
                abs[i] = build[i]
            end

            if i > 6 and not isTower then
                local ab = hero:FindAbilityByName(v)
                if ab then
                    ab:SetHidden(true)
                end
            end
        else
            local inSlot = abs[i]

            if inSlot then
                local ab = hero:FindAbilityByName(inSlot)
                if ab and not isTower then
                    ab:SetHidden(true)
                end
            end
        end
    end

    -- Add missing abilities
    for k,v in pairs(extraSkills) do
        -- Do they already have this skill?
        if not hero:HasAbility(k) then
            -- Move onto the next slot
            abNum = abNum + 1

            -- Precache
            precacheSkill(k)

            -- Add the ability
            hero:AddAbility(k)

            -- Remove auras
            fixModifiers(hero, k)

            -- Store that we have it
            currentSkillList[hero][abNum] = k
        end
    end
end

function skillManager:overrideHooks()
    -- Implement the get ability by slot index method
    if GameRules:isSource1() then
        function CDOTA_BaseNPC:GetAbilityByIndex(index)
            if currentSkillList[self] then
                local skillName = currentSkillList[self][index]
                if skillName then
                    return self:FindAbilityByName(skillName)
                end
            end
        end
    end
end

-- Attempt to store the precacher of everything
--CreateUnitByName('npc_precache_everything', Vector(-10000, -10000, 0), false, nil, nil, 0)

--PrecacheUnitByNameAsync('npc_precache_everything', function()end)

-- Define the export
return skillManager
