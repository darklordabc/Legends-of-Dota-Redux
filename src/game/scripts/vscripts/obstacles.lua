LinkLuaModifier("modifier_undestructible_obstacle", "obstacles.lua",LUA_MODIFIER_MOTION_NONE)

modifier_undestructible_obstacle = class({})

function modifier_undestructible_obstacle:DeclareFunctions()
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

function modifier_undestructible_obstacle:GetModifierMagicalResistanceBonus(  )
    return 100
end

function modifier_undestructible_obstacle:GetModifierHealthBonus( )
    return math.max(1,self:GetStackCount()) - 1
end

function modifier_undestructible_obstacle:GetModifierIncomingDamage_Percentage(  )
    if self:GetParent().hits == 0 then
        return 0
    end
    return -100
end

function modifier_undestructible_obstacle:OnAttacked(args)
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

function modifier_undestructible_obstacle:IsHidden()
    return true
end

function modifier_undestructible_obstacle:GetDisableHealing()
    return true
end

function modifier_undestructible_obstacle:CheckState()
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
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE]= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function spawnObstacleFromTable( obstacleTable, nextPoint, obstacle_counts )
    local size = obstacleTable.collisionSize or 1

    local obstacle = CreateUnitByName("npc_dummy_unit",nextPoint,true,nil,nil,DOTA_TEAM_NOTEAM)
    obstacle:SetOriginalModel(obstacleTable.model)
    obstacle:SetModel(obstacleTable.model)
    obstacle:SetModelScale(obstacleTable.scale or 1.0)

    obstacle:AddNewModifier(obstacle,nil,"modifier_undestructible_obstacle",{})
    obstacle:SetModifierStackCount("modifier_undestructible_obstacle",obstacle,obstacleTable.hits or 1)

    obstacle:SetHealth(999)

    obstacle.deathsim = obstacleTable.deathsim

    if size == 1 then
        obstacle.blockers = {}
        table.insert(obstacle.blockers, SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = nextPoint, block_fow = obstacleTable.blockVision}))
    else
        if size % 2 ~= 0 then
            nextPoint.x = snapToGrid32(nextPoint.x)
            nextPoint.y = snapToGrid32(nextPoint.y)
        else
            nextPoint.x = snapToGrid64(nextPoint.x)
            nextPoint.y = snapToGrid64(nextPoint.y)
        end

        obstacle.blockers = blockGridNavSquare(size, nextPoint, obstacleTable.blockVision)
    end

    obstacle:SetAbsOrigin(nextPoint)

    if obstacle_counts then
        obstacle_counts[obstacleTable.name] = obstacle_counts[obstacleTable.name] + 1
    end
    
    return obstacle
end

function blockGridNavSquare(size, location, block_fow)
    local gridNavBlockers = {}
    if size % 2 == 1 then
        for x = location.x - (size-2) * 32, location.x + (size-2) * 32, 64 do
            for y = location.y - (size-2) * 32, location.y + (size-2) * 32, 64 do
                local blockerLocation = Vector(x, y, location.z)
                local ent = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = blockerLocation, block_fow = block_fow})
                table.insert(gridNavBlockers, ent)
            end
        end
    else
        for x = location.x - (size / 2) * 32 + 16, location.x + (size / 2) * 32 - 16, 96 do
            for y = location.y - (size / 2) * 32 + 16, location.y + (size / 2) * 32 - 16, 96 do
                local blockerLocation = Vector(x, y, location.z)
                local ent = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = blockerLocation, block_fow = block_fow})
                table.insert(gridNavBlockers, ent)
            end
        end
    end
    return gridNavBlockers
end

function snapToGrid64(coord)
    return 64*math.floor(0.5+coord/64)
end

function snapToGrid32(coord)
    return 32+64*math.floor(coord/64)
end