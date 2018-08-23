--local timers = require('easytimers')

local noMulticast = {}
local noWitchcraft = {}

-- Disables the cooldown on multicast
local opSellMode = false

-- Function to work out if we can multicast with a given spell or not
local canMulticast = function(skillName)
    -- No banned multicast spells
    if noMulticast[skillName] then
        return false
    end

    -- Must be a valid spell
    return true
end

-- Stop multicast on weird stuff
local function isValidTargetEntity(ent)
    -- Ensure it's a valid entity
    if not IsValidEntity(ent) then return false end

    -- No buildings
    if ent:IsBuilding() then return false end
    if ent:IsTower() then return false end

    return true
end

-- Multicast

local multicastChannel = {}
ListenToGameEvent('dota_ability_channel_finished', function(keys)
    for i=0,9 do
        -- Is this player channelling?
        local channel = multicastChannel[i]
        if channel and not channel.handled then
            -- Grab the ability
            local ab = channel.ab

            -- Is this the ability we were looking for?
            if IsValidEntity(ab) and ab:GetAbilityName() == keys.abilityname then
                GameRules:GetGameModeEntity():SetThink(function()
                    -- Is it the right ability, and has the ability stopped channelling?
                    if IsValidEntity(ab) and not ab:IsChanneling() then
                        -- This channel is handled
                        channel.handled = true

                        -- Cleanup multicast units
                        if #channel.units > 0 then
                            local unit = table.remove(channel.units, 1)

                            if IsValidEntity(unit) then
                                local ab2 = unit:FindAbilityByName(keys.abilityname)
                                if ab2 then
                                    ab2:EndChannel(keys.interrupted == 1)
                                end

                                GameRules:GetGameModeEntity():SetThink(function()
                                    UTIL_RemoveImmediate(unit)
                                end, 'channel'..DoUniqueString('channel'), 10, nil)
                            end

                            return 0.1
                        else
                            multicastChannel[i] = nil
                        end
                    end
                end, 'channel'..DoUniqueString('channel'), 0.1, nil)
            end
        end
    end
end, nil)

ListenToGameEvent('dota_player_used_ability', function(keys)
    local ply = PlayerResource:GetPlayer(keys.PlayerID or keys.player)
    if ply then
        local hero = ply:GetAssignedHero()
        if hero then
            if OptionManager:GetOption('lodOptionCrazyWTF') == 1 then
                local usedAbility = hero:FindAbilityByName(keys.abilityname)
                if usedAbility then
                    usedAbility:EndCooldown()
                    usedAbility:RefundManaCost()
                end
            end

            --Support for NS's darkness to show it in top bar
            local night_stalker_darkness = hero:FindAbilityByName("night_stalker_darkness")
            if keys.abilityname == "night_stalker_darkness" and night_stalker_darkness then
                CustomGameEventManager:Send_ServerToAllClients("time_nightstalker_darkness", {
                    duration = night_stalker_darkness:GetLevelSpecialValueFor("duration", night_stalker_darkness:GetLevel() - 1)
                })
            end

            -- Check if they tried to illegally use shadow items, if they did, punish them by not refunding the full price
            if OptionManager:GetOption('banInvis') == 2 and (keys.abilityname == "item_invis_sword" or keys.abilityname == "item_silver_edge" or keys.abilityname == "item_shadow_amulet" or keys.abilityname == "item_glimmer_cape") then
                for i=0,11 do
                    local item = hero:GetItemInSlot(i)
                    if item ~= nil then
                        if item:GetName() == "item_invis_sword" or item:GetName() == "item_silver_edge" or item:GetName() == "item_shadow_amulet" or item:GetName() == "item_glimmer_cape" then
                            -- Punish gold is gold that they dont get refunded
                            local punishAmount = 500
                            hero:ModifyGold(item:GetCost() - punishAmount , false, 0)
                            hero:RemoveItem(item)
                            util:DisplayError(keys.PlayerID, "invisbilityItemsAreBanned")
                            break
                        end
                    end
                end
            end  

            -- Check if they have multicast
            local multicastMadness = OptionManager:GetOption('multicastMadness')
            if canMulticast(keys.abilityname) and not hero:PassivesDisabled() and not string.find(keys.abilityname,"consumable") then
                local mab = hero:FindAbilityByName('ogre_magi_multicast_lod')
                if not mab and multicastMadness then
                    mab = hero:AddAbility("ogre_magi_multicast_lod")
                end

                local doubleMode = false

                if multicastMadness or mab then
                    -- Grab the level of the ability
                    local lvl

                    -- Change level based on madness mode
                    if multicastMadness then
                        lvl = 3
                    else
                        lvl = mab:GetLevel()

                        -- Multicast now has a cooldown
                        if not mab:IsCooldownReady() then
                            lvl = 0
                        end
                    end

                    -- If they have no level in it, stop
                    if lvl > 0 then
                        -- How many times we will cast the spell
                        local mult = 0

                        -- Grab a random number
                        local r = math.random(0,100)

                        -- Calculate multiplyer
                        if doubleMode then
                            if lvl == 1 then
                                if r < 25 then
                                    mult = 2
                                end
                            elseif lvl == 2 then
                                if r < 6 then
                                    mult = 4
                                elseif r < 13 then
                                    mult = 3
                                elseif r < 38 then
                                    mult = 2
                                end
                            elseif lvl == 3 then
                                if r < 12 then
                                    mult = 4
                                elseif r < 25 then
                                    mult = 3
                                elseif r < 50 then
                                    mult = 2
                                end
                            elseif lvl == 4 then
                                if r < 19 then
                                    mult = 4
                                elseif r < 38 then
                                    mult = 3
                                elseif r < 63 then
                                    mult = 2
                                end
                            elseif lvl == 5 then
                                if r < 25 then
                                    mult = 4
                                elseif r < 50 then
                                    mult = 3
                                elseif r < 75 then
                                    mult = 2
                                end
                            elseif lvl == 6 then
                                if r < 31 then
                                    mult = 4
                                elseif r < 63 then
                                    mult = 3
                                elseif r < 88 then
                                    mult = 2
                                end
                            end
                        else
                            if lvl == 1 then
                                if r < 60 then
                                    mult = 2
                                end
                            elseif lvl == 2 then
                                if r < 30 then
                                    mult = 3
                                elseif r < 60 then
                                    mult = 2
                                end
                            elseif lvl == 3 then
                                if r < 15 then
                                    mult = 4
                                elseif r < 30 then
                                    mult = 3
                                elseif r < 60 then
                                    mult = 2
                                end
                            end
                        end

                        -- Guarantee the multicast
                        if multicastMadness and mult < 2 then
                            mult = 2
                        end

                        -- Are we doing any multiplying?
                        if mult > 0 then
                            -- Apply cooldown
                            if mab and not opSellMode then
                                local theCooldown = 30
                                if lvl == 2 then
                                    theCooldown = 15
                                elseif lvl == 3 then
                                    theCooldown = 10
                                end
                                mab:StartCooldown(theCooldown)
                            end

                            local ab = hero:FindAbilityByName(keys.abilityname)

                            -- Is this an item based ability?
                            local isItemAb = false

                            -- If we failed to find it, it might hav e been an item
                            if not ab and (hero:HasModifier('modifier_item_ultimate_scepter') or multicastMadness) then
                                for i=0,5 do
                                    -- Grab the slot item
                                    local slotItem = hero:GetItemInSlot(i)

                                    -- Was this the spell that was cast?
                                    if slotItem and slotItem:GetClassname() == keys.abilityname then
                                        -- We found it
                                        ab = slotItem
                                        isItemAb = true
                                        break
                                    end
                                end
                            end

                            if ab then
                                -- How long to delay each cast
                                local delay = mab:GetSpecialValueFor("delay")--getMulticastDelay(keys.abilityname)

                                -- Grab playerID
                                local playerID = hero:GetPlayerID()

                                -- Handle channelled spells
                                if util:isChannelled(keys.abilityname) then
                                    -- Cleanup
                                    if multicastChannel[playerID] ~= nil then
                                        while #multicastChannel[playerID].units > 0 do
                                            local unit = table.remove(multicastChannel[playerID].units, 1)
                                            UTIL_RemoveImmediate(unit)
                                        end
                                    end

                                    -- Create new table
                                    multicastChannel[playerID] = {
                                        ab = ab,
                                        units = {}
                                    }

                                    for multNum=1,mult-1 do
                                        -- Create and store the unit
                                        local multUnit = CreateUnitByName('npc_multicast', hero:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
                                        table.insert(multicastChannel[playerID].units, multUnit)

                                        if multUnit then
                                            multUnit:AddAbility(keys.abilityname)
                                            local multAb = multUnit:FindAbilityByName(keys.abilityname)
                                            if multAb then
                                                -- Level the spell
                                                multAb:SetLevel(ab:GetLevel())

                                                -- Ensure it can't be killed
                                                local dummySpell = multUnit:FindAbilityByName('lod_dummy_unit')
                                                if dummySpell then
                                                    dummySpell:SetLevel(1)
                                                end
                                                multUnit:AddNewModifier(multUnit, nil, 'modifier_invulnerable', {})

                                                -- Give it a scepter, if we have one
                                                if hero:HasModifier('modifier_item_ultimate_scepter') then
                                                    multUnit:AddNewModifier(multUnit, nil, 'modifier_item_ultimate_scepter', {
                                                        bonus_all_stats = 0,
                                                        bonus_health = 0,
                                                        bonus_mana = 0
                                                    })
                                                end

                                                local target = hero:GetCursorCastTarget()
                                                local targets
                                                local pos = hero:GetCursorPosition()

                                                if target then
                                                    targets = FindUnitsInRadius(target:GetTeam(),
                                                        target:GetOrigin(),
                                                        nil,
                                                        256,
                                                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                                        DOTA_UNIT_TARGET_ALL,
                                                        DOTA_UNIT_TARGET_FLAG_NONE,
                                                        FIND_ANY_ORDER,
                                                        false
                                                    )
                                                end

                                                GameRules:GetGameModeEntity():SetThink(function()
                                                    if IsValidEntity(ab) and ab:IsChanneling() and IsValidEntity(multUnit) then
                                                        if target then
                                                            local newTarget = target
                                                            while #targets > 0 do
                                                                newTarget = table.remove(targets, 1)

                                                                if newTarget ~= target and isValidTargetEntity(newTarget) then
                                                                    break
                                                                end
                                                            end

                                                            multUnit:CastAbilityOnTarget(newTarget, multAb, -1)
                                                        elseif pos then
                                                            multUnit:CastAbilityOnPosition(pos, multAb, -1)
                                                        else
                                                            UTIL_RemoveImmediate(multUnit)
                                                        end
                                                    else
                                                        UTIL_RemoveImmediate(multUnit)
                                                    end
                                                end, 'channel'..DoUniqueString('channel'), 0.1 * multNum, nil)
                                            else
                                                UTIL_RemoveImmediate(multUnit)
                                            end
                                        end
                                    end
                                else
                                    -- Grab the position
                                    local pos = hero:GetCursorPosition()
                                    local target = hero:GetCursorCastTarget()
                                    local isaTargetSpell = false

                                    -- Table to store multi units
                                    local multUnits

                                    local targets
                                    if target and util:isTargetSpell(keys.abilityname) then
                                        isaTargetSpell = true

                                        targets = FindUnitsInRadius(target:GetTeam(),
                                            target:GetOrigin(),
                                            nil,
                                            256,
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_ALL,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false
                                        )
                                    end

                                    Timers:CreateTimer(function()
                                        -- Ensure it still exists
                                        if IsValidEntity(ab) then
                                            -- Position cursor
                                            hero:SetCursorPosition(pos)

                                            local ourTarget = target

                                            -- If we have any targets to pick from, pick one
                                            local doneTarget = false
                                            if targets then
                                                -- While there is still possible targets
                                                while #targets > 0 do
                                                    -- Pick a random target
                                                    local index = math.random(#targets)
                                                    local t = targets[index]

                                                    -- Ensure it is valid and still alive
                                                    if IsValidEntity(t) and t:GetHealth() > 0 and t ~= ourTarget and isValidTargetEntity(t) then
                                                        -- Target is valid and alive, target it
                                                        ourTarget = t
                                                        doneTarget = true
                                                        break
                                                    else
                                                        -- Invalid target, remove it and find another
                                                        table.remove(targets, index)
                                                    end
                                                end
                                            end

                                            if isaTargetSpell then
                                                if IsValidEntity(ourTarget) and ourTarget:GetHealth() > 0 then
                                                    hero:SetCursorCastTarget(ourTarget)
                                                else
                                                    return
                                                end
                                            end

                                            -- Run the spell again
                                            --if not isaTargetSpell then
                                                ab:OnSpellStart()
                                            --end

                                            mult = mult-1
                                            if mult > 1 then
                                                return delay
                                            end
                                        end
                                    end, DoUniqueString('multicast'), delay)
                                end

                                -- Create sexy particles
                                local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf', PATTACH_OVERHEAD_FOLLOW, hero)
                                ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                                ParticleManager:ReleaseParticleIndex(prt)

                                prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                                prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, hero)
                                ParticleManager:ReleaseParticleIndex(prt)

                                prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_c.vpcf', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                                ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                                ParticleManager:ReleaseParticleIndex(prt)

                                -- Play the sound
                                hero:EmitSound('Hero_OgreMagi.Fireblast.x'..(mult-1))
                            end
                        end
                    end
                end
            end

            -- Check for witchcraft
            if not noWitchcraft[keys.abilityname] and not hero:PassivesDisabled() then
                local mabWitch = hero:FindAbilityByName('death_prophet_witchcraft')

                if mabWitch then
                    -- Grab the level of the ability
                    local lvl = mabWitch:GetLevel()

                    if lvl > 0 then
                        local ab = hero:FindAbilityByName(keys.abilityname)

                        if ab then
                            local reduction = lvl * -1

                            -- Octarine Core fix
                            --if GameRules:isSource1() then
                                if hero:HasModifier('modifier_item_octarine_core') or hero:HasModifier("modifier_item_octarine_core_consumable") then
                                    reduction = reduction * 0.75
                                end
                            --end

                            local timeRemaining = ab:GetCooldownTimeRemaining()
                            local newCooldown = timeRemaining + reduction
                            if newCooldown < 1 then
                                newCooldown = 1
                            end

                            if newCooldown < timeRemaining then
                                ab:EndCooldown()
                                if newCooldown > 0 then
                                    ab:StartCooldown(newCooldown)
                                end
                            end

                            -- Mana refund
                            local manaRefund = 5 + 5 * lvl
                            local currentMana = hero:GetMana()
                            hero:SetMana(currentMana + manaRefund)
                        end
                    end
                end

                local mabWitchOP = hero:FindAbilityByName('death_prophet_witchcraft_op')
                if mabWitchOP then
                    -- Grab the level of the ability
                    local lvl = mabWitchOP:GetLevel()

                    if lvl > 0 then
                        local ab = hero:FindAbilityByName(keys.abilityname)

                        if ab then
                            local reduction = lvl * -4

                            -- Octarine Core fix
                            --if GameRules:isSource1() then
                                if hero:HasModifier('modifier_item_octarine_core') or hero:HasModifier("modifier_item_octarine_core_consumable") then
                                    reduction = reduction * 0.75
                                end
                            --end

                            local timeRemaining = ab:GetCooldownTimeRemaining()
                            local newCooldown = timeRemaining + reduction
                            if newCooldown < 1 then
                                newCooldown = 1
                            end

                            if newCooldown < timeRemaining then
                                ab:EndCooldown()
                                if newCooldown > 0 then
                                    ab:StartCooldown(newCooldown)
                                end
                            end

                            -- Mana refund
                            local manaRefund = 5 + 5 * lvl
                            local currentMana = hero:GetMana()
                            hero:SetMana(currentMana + manaRefund)
                        end
                    end
                end
            end
        end
    end
end, nil)

-- Abaddon ulty fix
ListenToGameEvent('entity_hurt', function(keys)
    -- Grab the entity that was hurt
    local ent = EntIndexToHScript(keys.entindex_killed)

    -- Ensure it is a valid hero
    if ent and ent:IsRealHero() then
        -- The min amount of hp
        local minHP = 400

        -- Ensure their health has dropped low enough
        if ent:GetHealth() <= minHP then
            -- Do they even have the ability in question?
            local ab = ent:FindAbilityByName('abaddon_borrowed_time')    
            local ab2 = ent:FindAbilityByName('abaddon_borrowed_time_redux')
            if ab and ab:IsCooldownReady() and not ent:PassivesDisabled() then
                    -- Grab the level
                    local lvl = ab:GetLevel()

                    -- Is the skill even skilled?
                    if lvl > 0 then
                        -- Fix their health
                        ent:SetHealth(2*minHP - ent:GetHealth())

                        -- Add the modifier
                        ent:AddNewModifier(ent, ab, 'modifier_abaddon_borrowed_time', {
                            duration = ab:GetSpecialValueFor('duration'),
                            duration_scepter = ab:GetSpecialValueFor('duration_scepter'),
                            redirect = ab:GetSpecialValueFor('redirect'),
                            redirect_range_tooltip_scepter = ab:GetSpecialValueFor('redirect_range_tooltip_scepter')
                        })
							-- Apply the cooldown 
							local cd = ab:GetTrueCooldown(lvl-1)
                            ab:StartCooldown(cd)
                    end    
            elseif ab2 and ab2:IsCooldownReady() and not ent:PassivesDisabled() then  
                    -- Grab the level
                    local lvl = ab2:GetLevel()

                    -- Is the skill even skilled?
                    if lvl > 0 then
                        -- Fix their health
                        ent:SetHealth(2*minHP - ent:GetHealth())

                        -- Add the modifier
                        print(ab2:GetSpecialValueFor('duration'))
                        ent:AddNewModifier(ent, ab2, 'modifier_abaddon_borrowed_time', {
                            duration = ab2:GetSpecialValueFor('duration'),
                            duration_scepter = ab2:GetSpecialValueFor('duration_scepter'),
                            redirect = ab2:GetSpecialValueFor('redirect'),
                            redirect_range_tooltip_scepter = ab2:GetSpecialValueFor('redirect_range_tooltip_scepter')
                        })
                            -- Apply the cooldown
                            local cd = ab2:GetCooldown(lvl-1)
                            ab2:StartCooldown(cd)
                    end
                
            end
        end
    end
end, nil)

-- Allow stuff to be set externally
local SpellFixes = {}
function SpellFixes:SetNoCasting(mc, wc)
    noMulticast = mc
    noWitchcraft = wc
end

function SpellFixes:SetOPMode(enabled)
    opSellMode = enabled
end

return SpellFixes
