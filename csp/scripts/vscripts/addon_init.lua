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

        --[[
            Store stats
        ]]
        heroStats[playerID] = stats

        -- Generate a random build
        stats.build = {
            [1] = GetRandomAbility(),
            [2] = GetRandomAbility(),
            [3] = GetRandomAbility(),
            [4] = GetRandomAbility('Ults')
        }

        -- Bot fix
        if not PlayerResource:IsFakeClient(hero:GetPlayerID()) then
            -- Worst precache EVER
            hero = shittyPrecache(hero, stats.build[1])
            hero = shittyPrecache(hero, stats.build[2])
            hero = shittyPrecache(hero, stats.build[3])
            hero = shittyPrecache(hero, stats.build[4])
        end
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

    return hero
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
        -- Grab playerID
        local playerID = spawnedUnit:GetPlayerID()

        -- Update it
        spawnedUnit = updateHero(spawnedUnit)

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

function findOwningHero(ability)
    for heroName, values in pairs(heroKV) do
        if heroName ~= 'Version' then
            for i=1,8 do
                if values["Ability"..i] == ability then
                    return heroName
                end
            end
        end
    end

    return nil
end

function shittyPrecache(hero, ability)
    -- Grab info on old hero
    local oldHero = hero:GetClassname()
    local playerID = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(playerID)

    -- Attempt to cache shit
    local owner = findOwningHero(ability)
    if owner then
        local a = CreateHeroForPlayer(owner, player)
        if a then
            a:Remove()

            -- Create old  hero
            a = CreateHeroForPlayer(oldHero, player)
            if a then
                -- Remove old hero
                 hero:Remove()

                -- Return new hero
                return a
            else
                print("Failed to recreate "..oldHero)
            end
        else
            print("Failed to precache "..ability.." (2)")
        end
    else
        print("Failed to precache "..ability.." (1))")
    end
end

--PrecacheResource('particles/units/heroes/hero_queenofpain.pcf')

-- Precache everything -- Having issues with the arguments changing
--print('Precaching stuff...')

local models = {
    "models/heroes/juggernaut/jugg_healing_ward.mdl",
    "models/heroes/tiny_01/tiny_01.mdl",
    "models/heroes/tiny_02/tiny_02.mdl",
    "models/heroes/tiny_03/tiny_03.mdl",
    "models/heroes/tiny_04/tiny_04.mdl",
    "models/heroes/tiny_01/tiny_01_tree.mdl",
    "models/props_gameplay/frog.mdl",
    "models/props_gameplay/chicken.mdl",
    "models/heroes/shadowshaman/shadowshaman_totem.mdl",
    "models/heroes/witchdoctor/witchdoctor_ward.mdl",
    "models/heroes/enigma/eidelon.mdl",
    "models/heroes/enigma/eidelon.mdl",
    "models/heroes/beastmaster/beastmaster_bird.mdl",
    "models/heroes/beastmaster/beastmaster_beast.mdl",
    "models/heroes/venomancer/venomancer_ward.mdl",
    "models/heroes/death_prophet/death_prophet_ghost.mdl",
    "models/heroes/pugna/pugna_ward.mdl",
    "models/heroes/witchdoctor/witchdoctor_ward.mdl",
    "models/heroes/dragon_knight/dragon_knight_dragon.mdl",
    "models/heroes/rattletrap/rattletrap_cog.mdl",
    "models/heroes/furion/treant.mdl",
    "models/heroes/nightstalker/nightstalker_night.mdl",
    "models/heroes/nightstalker/nightstalker.mdl",
    "models/heroes/broodmother/spiderling.mdl",
    "models/heroes/weaver/weaver_bug.mdl",
    "models/heroes/gyro/gyro_missile.mdl",
    "models/heroes/invoker/forge_spirit.mdl",
    "models/heroes/lycan/lycan_wolf.mdl",
    "models/heroes/lone_druid/true_form.mdl",
    "models/heroes/undying/undying_flesh_golem.mdl",
    "models/development/invisiblebox.mdl"
}

local particles = {
    "particles/units/heroes/hero_antimage.pcf",
    "particles/units/heroes/hero_axe.pcf",
    "particles/units/heroes/hero_bane.pcf",
    "particles/units/heroes/hero_bloodseeker.pcf",
    "particles/units/heroes/hero_crystalmaiden.pcf",
    "particles/units/heroes/hero_drow.pcf",
    "particles/units/heroes/hero_earthshaker.pcf",
    "particles/units/heroes/hero_juggernaut.pcf",
    "particles/units/heroes/hero_mirana.pcf",
    "particles/units/heroes/hero_nevermore.pcf",
    "particles/units/heroes/hero_morphling.pcf",
    "particles/units/heroes/hero_phantom_lancer.pcf",
    "particles/units/heroes/hero_puck.pcf",
    "particles/units/heroes/hero_pudge.pcf",
    "particles/units/heroes/hero_razor.pcf",
    "particles/units/heroes/hero_sandking.pcf",
    "particles/units/heroes/hero_stormspirit.pcf",
    "particles/units/heroes/hero_sven.pcf",
    "particles/units/heroes/hero_tiny.pcf",
    "particles/units/heroes/hero_vengeful.pcf",
    "particles/units/heroes/hero_zuus.pcf",
    "particles/units/heroes/hero_kunkka.pcf",
    "particles/units/heroes/hero_lina.pcf",
    "particles/units/heroes/hero_lich.pcf",
    "particles/units/heroes/hero_lion.pcf",
    "particles/units/heroes/hero_shadowshaman.pcf",
    "particles/units/heroes/hero_slardar.pcf",
    "particles/units/heroes/hero_tidehunter.pcf",
    "particles/units/heroes/hero_witchdoctor.pcf",
    "particles/units/heroes/hero_riki.pcf",
    "particles/units/heroes/hero_enigma.pcf",
    "particles/units/heroes/hero_tinker.pcf",
    "particles/units/heroes/hero_sniper.pcf",
    "particles/units/heroes/hero_necrolyte.pcf",
    "particles/units/heroes/hero_warlock.pcf",
    "particles/units/heroes/hero_queenofpain.pcf",
    "particles/units/heroes/hero_venomancer.pcf",
    "particles/units/heroes/hero_faceless_void.pcf",
    "particles/units/heroes/hero_skeletonking.pcf",
    "particles/units/heroes/hero_death_prophet.pcf",
    "particles/units/heroes/hero_phantom_assassin.pcf",
    "particles/units/heroes/hero_pugna.pcf",
    "particles/units/heroes/hero_templar_assassin.pcf",
    "particles/units/heroes/hero_viper.pcf",
    "particles/units/heroes/hero_luna.pcf",
    "particles/units/heroes/hero_dragon_knight.pcf",
    "particles/units/heroes/hero_dazzle.pcf",
    "particles/units/heroes/hero_rattletrap.pcf",
    "particles/units/heroes/hero_leshrac.pcf",
    "particles/units/heroes/hero_furion.pcf",
    "particles/units/heroes/hero_life_stealer.pcf",
    "particles/units/heroes/hero_dark_seer.pcf",
    "particles/units/heroes/hero_clinkz.pcf",
    "particles/units/heroes/hero_omniknight.pcf",
    "particles/units/heroes/hero_enchantress.pcf",
    "particles/units/heroes/hero_huskar.pcf",
    "particles/units/heroes/hero_night_stalker.pcf",
    "particles/units/heroes/hero_broodmother.pcf",
    "particles/units/heroes/hero_bounty_hunter.pcf",
    "particles/units/heroes/hero_weaver.pcf",
    "particles/units/heroes/hero_jakiro.pcf",
    "particles/units/heroes/hero_batrider.pcf",
    "particles/units/heroes/hero_chen.pcf",
    "particles/units/heroes/hero_spectre.pcf",
    "particles/units/heroes/hero_doom_bringer.pcf",
    "particles/units/heroes/hero_ancient_apparition.pcf",
    "particles/units/heroes/hero_ursa.pcf",
    "particles/units/heroes/hero_spirit_breaker.pcf",
    "particles/units/heroes/hero_gyrocopter.pcf",
    "particles/units/heroes/hero_alchemist.pcf",
    "particles/units/heroes/hero_invoker.pcf",
    "particles/units/heroes/hero_silencer.pcf",
    "particles/units/heroes/hero_obsidian_destroyer.pcf",
    "particles/units/heroes/hero_lycan.pcf",
    "particles/units/heroes/hero_brewmaster.pcf",
    "particles/units/heroes/hero_shadow_demon.pcf",
    "particles/units/heroes/hero_lone_druid.pcf",
    "particles/units/heroes/hero_chaos_knight.pcf",
    "particles/units/heroes/hero_meepo.pcf",
    "particles/units/heroes/hero_treant.pcf",
    "particles/units/heroes/hero_ogre_magi.pcf",
    "particles/units/heroes/hero_undying.pcf",
    "particles/units/heroes/hero_rubick.pcf",
    "particles/units/heroes/hero_disruptor.pcf",
    "particles/units/heroes/hero_nyx_assassin.pcf",
    "particles/units/heroes/hero_siren.pcf",
    "particles/units/heroes/hero_keeper_of_the_light.pcf",
    "particles/units/heroes/hero_wisp.pcf",
    "particles/units/heroes/hero_visage.pcf",
    "particles/units/heroes/hero_slark.pcf",
    "particles/units/heroes/hero_medusa.pcf",
    "particles/units/heroes/hero_troll_warlord.pcf",
    "particles/units/heroes/hero_centaur.pcf",
    "particles/units/heroes/hero_magnataur.pcf",
    "particles/units/heroes/hero_shredder.pcf",
    "particles/units/heroes/hero_bristleback.pcf",
    "particles/units/heroes/hero_tusk.pcf",
    "particles/units/heroes/hero_skywrath_mage.pcf",
    "particles/units/heroes/hero_abaddon.pcf",
    "particles/units/heroes/hero_elder_titan.pcf",
    "particles/units/heroes/hero_legion_commander.pcf",
    "particles/units/heroes/hero_ember_spirit.pcf",
    "particles/units/heroes/hero_earth_spirit.pcf",
    "particles/units/heroes/hero_abyssal_underlord.pcf",
    "particles/units/heroes/hero_terrorblade.pcf",
    "particles/units/heroes/hero_phoenix.pcf"
}

--[[PrecacheEntityFromTable("npc_dota_creep", {
    particlefile = "particles/units/heroes/hero_queenofpain.pcf"
}, {
    particlefile = "particles/units/heroes/hero_queenofpain.pcf"
})]]

--local a = {}
--setmetatable(a, CScriptPrecacheContext)
--print(a.AddResource)


--PrecacheResource("particlefile","particles/units/heroes/hero_queenofpain.pcf", a)


--local a = CScriptPrecacheContext()
--print(a)

--PrecacheResource("particlefile", "particles/units/heroes/hero_phoenix.pcf", {})

--PrecacheResource('test', 'test')
--print('Done precaching!')
