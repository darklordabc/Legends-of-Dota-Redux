
modifier_queenofpain_blink_ai = class({})

--------------------------------------------------------------------------------

function modifier_queenofpain_blink_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_queenofpain_blink_ai:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------

function modifier_queenofpain_blink_ai:OnCreated( params )
    if IsServer() then
        self:OnIntervalThink()
        self:StartIntervalThink( 1 )
    end
end

--------------------------------------------------------------------------------

function modifier_queenofpain_blink_ai:OnIntervalThink()
    local caster = self:GetParent()
    local target = caster:GetAttackTarget()
    local ability = caster:FindAbilityByName("queenofpain_blink")
    local shouldBlink = false
    local shouldBlinkAggressive = false
    local shouldBlinkEscape = false
    
    if ability and ability:IsFullyCastable() and caster:IsAlive() and not caster:IsChanneling() and caster:IsRealHero() then
        if target then
            distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
            -- blinks aggressively if health and mana are high enough.
            if caster:GetHealthPercent() > 90 and caster:GetManaPercent() > 40 and distance > caster:GetAttackRange() + 150 then
                shouldBlink = true
                shouldBlinkAggressive = true
                --print("aggresive blink")
            end
        -- blinks automatically if health and mana are high enough
        --[[elseif caster:GetHealthPercent() > 80 and caster:GetManaPercent() > 80 and not target then
                local random = math.random(1, 100)
                if random <= 3 then
                    --print("auto blink")
                    shouldBlink = true
                end]]
        -- Bots will retreat at low health, prioritizing blink
        elseif caster:GetHealthPercent() < 30 and not target and not caster:HasModifier("modifier_bloodseeker_rupture") then
            local enemyHeroes = FindUnitsInRadius(  caster:GetTeam(),
              caster:GetAbsOrigin(),
              nil,
              600, 
              DOTA_UNIT_TARGET_TEAM_ENEMY, 
              DOTA_UNIT_TARGET_HERO, 
              DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
              0, 
              false)
            if #enemyHeroes == 0 then
                shouldBlink = true
                shouldBlinkEscape = true
            end
            --print("blink retreat")
        elseif not GridNav:IsTraversable(caster:GetAbsOrigin()) then
            shouldBlink = true
            --print("blocked!")
        end
    end

    if shouldBlink == true then
        local cooldown = ability:GetCooldown( ability:GetLevel() )

        local origin = caster:GetAbsOrigin()
        local vector = caster:GetForwardVector()
        local range = ability:GetLevelSpecialValueFor("blink_range", ability:GetLevel() - 1)

        if shouldBlinkAggressive == true then
            vector = (target:GetAbsOrigin() - origin):Normalized()
            aggroRange = (origin - target:GetAbsOrigin()):Length2D() + 200
            if range > aggroRange then range = aggroRange end   
        end

        if shouldBlinkEscape == true then 
            local escapeTarget
            local targets = FindUnitsInRadius(  caster:GetTeam(),
                caster:GetAbsOrigin(),
                nil,
                FIND_UNITS_EVERYWHERE, 
                DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
                DOTA_UNIT_TARGET_ALL, 
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
                0, 
                false)
                                                                        
            for _,unit in pairs(targets) do 
                if unit:GetUnitName() == "dota_fountain" then
                    escapeTarget = unit
                    vector = (unit:GetAbsOrigin() - origin):Normalized()
                end
            end
        end

        local location = origin + vector * range

        --DebugDrawCircle(location, Vector(0,0,255), 1, 250, false, 2 ) 

        local preorder = 
        {
            UnitIndex = caster:GetEntityIndex(), 
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = location, 
            Queue = true
        }
        local order =
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            AbilityIndex = ability:GetEntityIndex(),
            Position = location,
            Queue = false
        }

        ExecuteOrderFromTable(preorder)
        caster:Interrupt()
        ExecuteOrderFromTable(order)
    end
end
