obstacle_models = {
    [1] = {
        name = "Mother Tree",
        model = "models/props_tree/dire_tree007_sfm.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 0.7,
        collisionSize = 2,
        maxCount = 1,
        hits = 4,
        fixedAngle = 70.0
    },
    [2] = {
        name = "Small Tree A",
        model = "models/props_tree/dire_tree007_sfm.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 0.3,
        collisionSize = 1,
        maxCount = 50,
        hits = 2,
        randomDirection = false
    },
	[3] = {
        name = "Oak Tree A",
        model = "models/props_tree/tree_oak_01_sfm.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 0.5,
        collisionSize = 1,
        maxCount = 50,
        hits = 2,
		randomDirection = true
    }
	,
	[4] = {
        name = "Pine Tree A",
        model = "models/props_tree/tree_pine_02_sfm.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 0.5,
        collisionSize = 1,
        maxCount = 50,
        hits = 2,
		randomDirection = true
    },
	[5] = {
        name = "Rock A",
        model = "models/props_rock/riveredge_rock007a.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 2.0,
        collisionSize = 7.0,
        maxCount = 50,
        hits = 2,
		fixedAngle = 50.0
    },
	[6] = {
        name = "Rock B",
        model = "models/props_rock/riveredge_rock006a.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = false,
        scale = 0.6,
        collisionSize = 1.0,
        maxCount = 50,
        hits = 2,
		randomDirection = true
    },
	[7] = {
        name = "Rock C",
        model = "models/props_rock/badside_rocks004.vmdl",
        deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
        blockVision = true,
        scale = 3.5,
        collisionSize = 3.0,
        maxCount = 50,
        hits = 2,
		randomDirection = true
    }
}

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

    local obstacle = SpawnEntityFromTableSynchronous("prop_dynamic", {model = obstacleTable.model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")}) -- CreateUnitByName("npc_dummy_unit",nextPoint,true,nil,nil,DOTA_TEAM_NOTEAM)
    obstacle:SetModelScale(obstacleTable.scale or 1.0)

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

        if obstacle.blockers == false then
            UTIL_Remove(obstacle)
            return nil
        end
    end

    if obstacleTable.fixedAngle then
        obstacle:SetAngles(0, obstacleTable.fixedAngle, 0)
    elseif obstacleTable.randomDirection then
        obstacle:SetAngles(0, math.random(0, 360), 0)
    end

    obstacle:SetAbsOrigin(nextPoint)

    if obstacle_counts then
        obstacle_counts[obstacleTable.name] = obstacle_counts[obstacleTable.name] + 1
    end
    
    return obstacle
end

function precacheObstacles(context)
    for k,v in pairs(obstacle_models) do
        PrecacheResource("model",v.model,context)
    end
end

function blockGridNavSquare(size, location, block_fow)
    local gridNavBlockers = {}
    if size % 2 == 1 then
        for x = location.x - (size-2) * 32, location.x + (size-2) * 32, 64 do
            for y = location.y - (size-2) * 32, location.y + (size-2) * 32, 64 do
                local blockerLocation = Vector(x, y, location.z)

                if GridNav:IsBlocked(blockerLocation) then
                    for k,v in pairs(gridNavBlockers) do
                        UTIL_Remove(v)
                    end
                    return false
                end

                local ent = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = blockerLocation, block_fow = block_fow})
                table.insert(gridNavBlockers, ent)
            end
        end
    else
        for x = location.x - (size / 2) * 32 + 16, location.x + (size / 2) * 32 - 16, 96 do
            for y = location.y - (size / 2) * 32 + 16, location.y + (size / 2) * 32 - 16, 96 do
                local blockerLocation = Vector(x, y, location.z)

                if GridNav:IsBlocked(blockerLocation) then
                    for k,v in pairs(gridNavBlockers) do
                        UTIL_Remove(v)
                    end
                    return false
                end

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