LinkLuaModifier("modifier_destructible_obstacle", "obstacles.lua",LUA_MODIFIER_MOTION_NONE)

modifier_destructible_obstacle = class({})

function modifier_destructible_obstacle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
 
    return funcs
end

function modifier_destructible_obstacle:GetModifierMagicalResistanceBonus(  )
    return 100
end

function modifier_destructible_obstacle:GetModifierHealthBonus( )
    return math.max(1,self:GetStackCount()) - 1
end

function modifier_destructible_obstacle:GetModifierIncomingDamage_Percentage(  )
    if self:GetParent().hits == 0 then
        return 0
    end
    return -100
end

function modifier_destructible_obstacle:OnAttacked(args)
    local victim = self:GetParent()
    local attacker = args.attacker

    if IsServer() then
        if args.attacker ~= self:GetParent() and args.target == self:GetParent() then
            if not victim.hits then
                if self:GetStackCount() > 0 then
                    victim.hits = self:GetStackCount()
                else
                    victim.hits = 1
                end
            end
            victim.hits = victim.hits - 1
            if victim.hits == 0 then
                victim:ForceKill(false)
                return
            end
        end
    end
end

function modifier_destructible_obstacle:IsHidden()
    return true
end

function modifier_destructible_obstacle:GetDisableHealing()
    return true
end

function modifier_destructible_obstacle:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
        [MODIFIER_STATE_NO_TEAM_SELECT] = true,
    }
    return state
end

function spawnObstacleFromTable( obstacleTable, nextPoint, obstacle_counts )
    local size = obstacleTable.collisionSize or 1

    if size % 2 ~= 0 then
        nextPoint.x = snapToGrid32(nextPoint.x)
        nextPoint.y = snapToGrid32(nextPoint.y)
    else
        nextPoint.x = snapToGrid64(nextPoint.x)
        nextPoint.y = snapToGrid64(nextPoint.y)
    end

    local obstacle = CreateUnitByName("npc_dummy_unit",nextPoint,true,nil,nil,DOTA_TEAM_NOTEAM)
    obstacle:SetOriginalModel(obstacleTable.model)
    obstacle:SetModel(obstacleTable.model)
    obstacle:SetModelScale(obstacleTable.scale or 1.0)

    obstacle:AddNewModifier(obstacle,nil,"modifier_destructible_obstacle",{})
    obstacle:SetModifierStackCount("modifier_destructible_obstacle",obstacle,obstacleTable.hits or 1)

    obstacle:SetHealth(999)

    obstacle.deathsim = obstacleTable.deathsim

    obstacle.blockers = blockGridNavSquare(size, nextPoint, obstacleTable.blockVision)

    FindClearSpaceForUnit(obstacle,nextPoint,true)

    if obstacle_counts then
        obstacle_counts[obstacleTable.name] = obstacle_counts[obstacleTable.name] + 1
    end
    
    return obstacle
end