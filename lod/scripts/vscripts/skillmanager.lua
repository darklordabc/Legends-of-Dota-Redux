--[[
    Skill Managing Library for swapping skills during runtime
]]

-- Keeps track of what skills a given hero has
local currentSkillList = {}

-- Contains info on heroes
local heroListKV = LoadKeyValues("scripts/npc/npc_heroes.txt")

-- A list of sub abilities needed to give out when we add an ability
local subAbilities = LoadKeyValues("scripts/kv/abilityDeps.kv")

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

    return skills
end

function skillManager:RemoveAllSkills(hero)
    -- Ensure the hero isn't nil
    if hero == nil then return end

    -- Check if we've touched this hero before
    if not currentSkillList[hero] then
        -- Grab the name of this hero
        local heroClass = hero:GetUnitName()

        -- Grab the skills
        local skills = self:GetHeroSkills(heroClass)

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

function skillManager:ApplyBuild(hero, build)
    -- Ensure the hero isn't nil
    if hero == nil then return end

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

    -- Give all the abilities in this build
    local abNum = 0
    for i=1,12 do
        local v = build[i]
        if v then
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
            if meleeMap[v] then
                v = meleeMap[v]
            end

            -- Add to build
            hero:AddAbility(v)
            currentSkillList[hero][abNum] = v

            -- Do we need to manually activate this skill?
            if manualActivate[v] then
                hero:FindAbilityByName(v):SetActivated(true)
            end

            -- Remove auras
            fixModifiers(hero, v)
        end
    end

    -- Add missing abilities
    for k,v in pairs(extraSkills) do
        -- Move onto the next slot
        abNum = abNum + 1

        -- Add the ability
        hero:AddAbility(k)

        -- Remove auras
        fixModifiers(hero, k)

        -- Store that we have it
        currentSkillList[hero][abNum] = k
    end
end

-- Define the export
SkillManager = skillManager
