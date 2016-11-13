local Timers = require('easytimers')
require('obstacles')

AAR_SMALL_ARENA = 1
AAR_BIG_ARENA = 2
AAR_GIANT_ARENA = 3

arenas = {}
arenas[AAR_SMALL_ARENA] = {
	polygon = {
		[1] = Vector(1561.12, -5262.92, 295.968), [2] = Vector(1555.84, -4122.01, 257), [3] = Vector(4348.23, -4122.07, 257), [4] = Vector(4358.79, -5207.59, 282.345)
	},
	tribune_points = {
		radiant = {
			[1] = Vector(1263.93, -4192, 257),
		},
		dire = {
			[1] = Vector(4514.9, -4088.89, 257),
		}
	},
	duel_points = {
		radiant = {
			[1] = Vector(1907.01, -4406.56, 257),
		},
		dire = {
			[1] = Vector(3750.69, -4362.2, 257),
		}
	},
	random_obstacles = 10,
	obstacle_models = {
		[1] = {
			name = "Mother Tree",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.7,
			collisionSize = 2,
			maxCount = 1,
			hits = 4
		},
		[2] = {
			name = "Small Tree A",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.3,
			collisionSize = 1,
			maxCount = 50,
			hits = 2
		}
	},
	wallModel = "models/props_structures/tower_good4.vmdl",
	towerModel = "models/props_structures/tower_good2.vmdl"
}
arenas[AAR_BIG_ARENA] = {
	polygon = {
		[1] = Vector(-235.689, -6139.83, 262.252), [2] = Vector(-226.721, -3866.71, 291.518), [3] = Vector(5519, -3839.78, 257), [4] = Vector(5526.66, -6118.56, 271.501)
	},
	tribune_points = {
		radiant = {
			[1] = Vector(-583.137, -4057.1, 257),
		},
		dire = {
			[1] = Vector(5736.05, -4348.62, 257),
		}
	},
	duel_points = {
		radiant = {
			[1] = Vector(1907.01, -4406.56, 257),
		},
		dire = {
			[1] = Vector(3750.69, -4362.2, 257),
		}
	},
	random_obstacles = 25,
	obstacle_models = {
		[1] = {
			name = "Mother Tree",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.7,
			collisionSize = 2,
			maxCount = 1,
			hits = 4
		},
		[2] = {
			name = "Small Tree A",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.3,
			collisionSize = 1,
			maxCount = 50,
			hits = 2
		}
	},
	wallModel = "models/props_structures/tower_good4.vmdl",
	towerModel = "models/props_structures/tower_good2.vmdl"
}
arenas[AAR_GIANT_ARENA] = {
	polygon = {
		[1] = Vector(-1256.13, -7178.7, 257), [2] = Vector(-1384.51, -5792.31, 301.099), 
		[3] = Vector(-1894.97, -4985.5, 283.667), [4] = Vector(-2651.49, -3477.07, 129),
		[5] = Vector(-1710.43, -2119.33, 129), [6] = Vector(-658.098, -1711.48, 129),
		[7] = Vector(211.006, -1998.87, 268.876), [8] = Vector(2105.04, -2220.36, 60.0008),
		[9] = Vector(2836.18, -2726.16, 255.578), [10] = Vector(3418.14, -3282.93, 288.287),
		[11] = Vector(3443, -3584.1, 284.458), [12] = Vector(4005.46, -3655.42, 282.417),
		[13] = Vector(4056.13, -3258.43, 264.392), [14] = Vector(7642.01, -3110.64, 257),
		[15] = Vector(7723.77, -4796.05, 282.028), [16] = Vector(7459.8, -5119.99, 288.688),
		[17] = Vector(7400.76, -6215.87, 281.567), [18] = Vector(6114.49, -7238.02, 298.057)
	},
	tribune_points = {
		radiant = {
			[1] = Vector(-2117.77, -5658.65, 129),
		},
		dire = {
			[1] = Vector(-2112.69, -5980, 129),
		}
	},
	duel_points = {
		radiant = {
			[1] = Vector(1907.01, -4406.56, 257),
		},
		dire = {
			[1] = Vector(3750.69, -4362.2, 257),
		}
	},
	random_obstacles = 40,
	obstacle_models = {
		[1] = {
			name = "Mother Tree",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.7,
			collisionSize = 2,
			maxCount = 1,
			hits = 4
		},
		[2] = {
			name = "Small Tree A",
			model = "models/props_tree/dire_tree007_sfm.vmdl",
			deathsim = "particles/world_destruction_fx/dire_tree007_destruction.vpcf",
			blockVision = true,
			scale = 0.3,
			collisionSize = 1,
			maxCount = 50,
			hits = 2
		}
	},
	wallModel = "models/props_structures/tower_good4.vmdl",
	towerModel = "models/props_structures/tower_good2.vmdl"
}

LinkLuaModifier("modifier_duel_out_of_game", "lib/util_aar.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tribune", "lib/util_aar.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invis_reveal", "lib/util_aar.lua",LUA_MODIFIER_MOTION_NONE)

modifier_invis_reveal = class({})

function modifier_invis_reveal:IsHidden()
	return true
end

function modifier_invis_reveal:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_invis_reveal:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
	return state
end

modifier_tribune = class({})

function modifier_tribune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
 
	return funcs
end

function modifier_tribune:IsHidden()
	return true
end

function modifier_tribune:GetDisableHealing()
	return true
end

function modifier_tribune:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
	return state
end

modifier_duel_out_of_game = class({})

function modifier_duel_out_of_game:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
 
	return funcs
end

function modifier_duel_out_of_game:IsHidden()
	return true
end

function modifier_duel_out_of_game:GetDisableHealing()
	return true
end

function modifier_duel_out_of_game:CheckState()
	local state = {
		-- [MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
	return state
end

DUEL_INTERVAL = 30
DUEL_NOBODY_WINS = 60
DUEL_PREPARE = 2.0

duel_active = false

local duel_interval = 300
local duel_draw_time = 120
local duel_count = 0
local duel_radiant_warriors = {}
local duel_dire_warriors = {}
local duel_radiant_heroes = {}
local duel_dire_heroes = {}
local duel_end_callback
local duel_victory_team = 0

temp_obstacles = {}
temp_entities = {}
temp_vision = {}

winners = -1
current_arena = 1

function getHeroesCount(radiant_heroes, dire_heroes)
    local rp = 0
    local dp = 0
   
    if not radiant_heroes or not dire_heroes then return end
    for _, x in pairs(radiant_heroes) do
        if x and x:IsRealHero() and isConnected(x) then rp = rp + 1 end
    end
   
    for _, x in pairs(dire_heroes) do
        if x and x:IsRealHero() and isConnected(x) then dp = dp + 1 end
    end
 
    return rp, dp
end

function clearDuelFromHeroes(heroes_table)
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() then
            x.IsDueled = false
        end
    end
end

function getAliveHeroesCount(heroes_table)
    if not heroes_table then
        return 0
    end
    local lc = 0
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and isConnected(x) then
            lc = lc + 1
        end
    end
    return lc
end

function moveHeroesToTribune(heroes_table, tribune_points_table)
    local cur = 1
    local max = #tribune_points_table
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsAlive() then
            if x:HasAbility("meepo_divided_we_stand") then -- x:GetUnitName() == "npc_dota_hero_meepo" and not x:IsIllusion()
                local meepo_duel_table = Entities:FindAllByName(x:GetUnitName())
                if meepo_duel_table then
                	for k,v in pairs(meepo_duel_table) do
                        if v and not v:IsIllusion() and x:GetPlayerOwner() == v:GetPlayerOwner() then
                            v.duel_old_point = x:GetAbsOrigin()

                            v:Stop()

                            FindClearSpaceForUnit(v,tribune_points_table[cur],true)

                            v:SetForwardVector(-(tribune_points_table[cur] - getMidPoint(arenas[current_arena].polygon)):Normalized())

			                if x.duelParticle then
								ParticleManager:DestroyParticle(x.duelParticle,false)
								x:EmitSound("Portal.Hero_Disappear")
			                end

                            v:Stop()
                            v:AddNewModifier(x, nil, "modifier_tribune", {})
                        end
                	end
                end
            else
                x.duel_old_point = x:GetAbsOrigin()
                x:Stop()

                FindClearSpaceForUnit(x,tribune_points_table[cur],true)

                x:SetForwardVector(-(tribune_points_table[cur] - getMidPoint(arenas[current_arena].polygon)):Normalized())

                if x.duelParticle then
					ParticleManager:DestroyParticle(x.duelParticle,false)
					x:EmitSound("Portal.Hero_Disappear")
                end

                x:Stop()
                x:AddNewModifier(x, nil, "modifier_tribune", {})
            end
 
            cur = cur + 1
            cur = cur + 1
            if cur >= max then cur = 1 end
        end
    end
end

function moveToDuel(duel_heroes, team_heroes, duel_points_table)
    local cur = 1
    local max = #duel_points_table
    local first_time = false
    for _, x in pairs(duel_heroes) do
        x:Stop()

        FindClearSpaceForUnit(x,duel_points_table[cur],true)

        x:Stop()

        x:RemoveModifierByName('modifier_tribune')
        x:AddNewModifier(x, nil, "modifier_phased", { duration = 4 })
 
        local duel_gem = CreateItem("item_gem", x, x)
        x:AddNewModifier(x, duel_gem, "modifier_item_gem_of_true_sight", {})
        UTIL_Remove(duel_gem)
        x.duel_cooldowns = saveAbilitiesCooldowns(x)
        resetAllAbilitiesCooldown(x, x.duel_cooldowns)
        x.tempHealth = x:GetHealth()
        x.tempMana = x:GetMana()
        x:SetHealth(9999999)
        x:SetMana(9999999)
        x:Purge(true, true, false, true, false )

        local ents = Entities:FindAllInSphere(Vector(), 100000)

        for k,v in pairs(ents) do
        	if v.GetOwnerEntity and IsValidEntity(v:GetOwnerEntity()) and v:GetOwnerEntity():entindex() == x:entindex() then
        		pcall(function (  )
        			v:Kill(nil, nil)
        		end)
        	end
        end
       
        while(x:HasModifier("modifier_huskar_burning_spear_counter")) do
            x:RemoveModifierByName("modifier_huskar_burning_spear_counter")
        end
 
        while(x:HasModifier("modifier_razor_eye_of_the_storm")) do
            x:RemoveModifierByName("modifier_razor_eye_of_the_storm")
        end
       
        x:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
        x:RemoveModifierByName("modifier_kings_bar_magic_immune_active")
        x:RemoveModifierByName("modifier_black_king_bar_immune")
        x:RemoveModifierByName("modifier_venomancer_poison_nova")
        x:RemoveModifierByName("modifier_dazzle_weave_armor")
        x:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")
        x:RemoveModifierByName("modifier_life_stealer_infest")
        x:RemoveModifierByName("modifier_maledict")
        x:RemoveModifierByName("modifier_bloodseeker_rupture")

	    if x.duelParticle then
			ParticleManager:DestroyParticle(x.duelParticle,false)
			x:EmitSound("Portal.Hero_Disappear")
	    end

		Timers:CreateTimer(function()
			if not duel_active or not x:IsAlive() then
				return
			end
            isHeroOnDuel(x)
        	return 0.5
        end, "duel_check_id" .. x:GetPlayerOwnerID(), 1)

		PlayerResource:SetCameraTarget(x:GetPlayerOwnerID(),x)

		Timers:CreateTimer(function()
			PlayerResource:SetCameraTarget(x:GetPlayerOwnerID(),nil)
		end, DoUniqueString("camera"), 0.06)

        -- Timers:CreateTimer(function()
        --     endDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
        -- 	return nil
        -- end, "duel_check_id" .. x:GetPlayerOwnerID(), DUEL_NOBODY_WINS)

        cur = cur + 1
        if cur >= max then cur = 1 end
 
        if first_time == false then

            first_time = true
        end
    end
end

function moveToDuelHero(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then
        return
    end
 
    x:SetAbsOrigin(getMidPoint( arenas[current_arena].polygon ))

    hero:RemoveModifierByName("modifier_tribune")
end

function isHeroOnDuel(hero)
    if not hero then return false end
   
	if not isPointInsidePolygon(hero:GetAbsOrigin(), arenas[current_arena].polygon) and not hero:HasModifier("modifier_tribune") then
		FindClearSpaceForUnit(hero, GetGroundPosition(hero.oldArenaPos or getMidPoint( arenas[current_arena].polygon ),hero),true)
	else
		hero.oldArenaPos = hero:GetAbsOrigin()
	end
end

function removeHeroesFromDuel(heroes_table)
    if not heroes_table or type(heroes_table) ~= type({}) then
        return
    end
 
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) then
            if x:HasAbility("meepo_divided_we_stand") then -- x:GetUnitName() == "npc_dota_hero_meepo"
                local meepo_return_table = Entities:FindAllByName(x:GetUnitName())
                if meepo_return_table then
                    for i = 1, #meepo_return_table do
                        if meepo_return_table[i] and not meepo_return_table[i]:IsIllusion() and x:GetPlayerOwner() == meepo_return_table[i]:GetPlayerOwner() then
                            meepo_return_table[i]:Purge(true, true, false, true, true )
 
                            while(meepo_return_table[i]:HasModifier("modifier_huskar_burning_spear_counter")) do
                                meepo_return_table[i]:RemoveModifierByName("modifier_huskar_burning_spear_counter")
                             end
                            meepo_return_table[i]:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
       
                            local point = meepo_return_table[i].duel_old_point
                            if not point then
                                point = getMidPoint( arenas[current_arena].polygon ) --Entities:FindByName(nil,  GetTeamPointNameByTeamNumber(base_points, meepo_return_table[i]:GetTeamNumber())):GetAbsOrigin()
                            end      
 
                            if meepo_return_table[i].duel_cooldowns then
                                setAbilitiesCooldowns(meepo_return_table[i], meepo_return_table[i].duel_cooldowns)
                                meepo_return_table[i].duel_cooldowns = nil
                            end
 
                            if meepo_return_table[i]:IsAlive() then
                                meepo_return_table[i]:RemoveModifierByName('modifier_tribune')
                            end
 
                            if meepo_return_table[i] then
                                meepo_return_table[i]:RemoveModifierByName("modifier_item_gem_of_true_sight")
                            end
 
                            if meepo_return_table[i].item_gem then
                                meepo_return_table[i]:AddNewModifier(meepo_return_table[i], meepo_return_table[i].item_gem, "modifier_item_gem_of_true_sight", {})
                            end
                            if meepo_return_table[i].duel_gem then
                                meepo_return_table[i].duel_gem:RemoveSelf()
                                meepo_return_table[i].duel_gem = nil
                            end
 
                            if point then
                                if meepo_return_table[i]:IsAlive() then
                                    FindClearSpaceForUnit(meepo_return_table[i],point,true)

									PlayerResource:SetCameraTarget(meepo_return_table[i]:GetPlayerOwnerID(),x)

									Timers:CreateTimer(function()
										PlayerResource:SetCameraTarget(meepo_return_table[i]:GetPlayerOwnerID(),nil)
										ParticleManager:DestroyParticle(x.duelParticle, false)
										x:EmitSound("Portal.Hero_Disappear")
									end, "meepo_cam"..meepo_return_table[i]:GetPlayerID(), 0.06)
                                end
                                meepo_return_table[i].duel_old_point = nil
                            else
                                print("Duel system error, base points not found!")
                            end
                        end
                    end
                end
            else
                x:Purge(true, true, false, true, true )
                while(x:HasModifier("modifier_huskar_burning_spear_counter")) do
                    x:RemoveModifierByName("modifier_huskar_burning_spear_counter")
                end
                x:RemoveModifierByName("modifier_huskar_burning_spear_debuff")

		        while(x:HasModifier("modifier_huskar_burning_spear_counter")) do
		            x:RemoveModifierByName("modifier_huskar_burning_spear_counter")
		        end
		 
		        while(x:HasModifier("modifier_razor_eye_of_the_storm")) do
		            x:RemoveModifierByName("modifier_razor_eye_of_the_storm")
		        end
		       
		        x:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
		        x:RemoveModifierByName("modifier_kings_bar_magic_immune_active")
		        x:RemoveModifierByName("modifier_black_king_bar_immune")
		        x:RemoveModifierByName("modifier_venomancer_poison_nova")
		        x:RemoveModifierByName("modifier_dazzle_weave_armor")
		        x:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")
		        x:RemoveModifierByName("modifier_life_stealer_infest")
		        x:RemoveModifierByName("modifier_maledict")
		        x:RemoveModifierByName("modifier_bloodseeker_rupture")
 
                local point = x.duel_old_point
                if not point then
                    point = getMidPoint( arenas[current_arena].polygon ) -- Entities:FindByName(nil,  GetTeamPointNameByTeamNumber(base_points, x:GetTeamNumber())):GetAbsOrigin()
                end
 
                if x.duel_cooldowns then
                    setAbilitiesCooldowns(x, x.duel_cooldowns)
                    x.duel_cooldowns = nil
                end
 
                if x:IsAlive() then
                    x:RemoveModifierByName('modifier_tribune')
                end
 
                x:RemoveModifierByName("modifier_item_gem_of_true_sight")
 
                if x.item_gem then
                    x:AddNewModifier(x, x.item_gem, "modifier_item_gem_of_true_sight", {})
                end

                if x.tempHealth then
                	x:SetHealth(x.tempHealth)
                end

                if x.tempMana then
                	x:SetMana(x.tempMana)
                end
               
                --if x.duel_gem then
                --    x.duel_gem:RemoveSelf()
                --    x.duel_gem = nil
                --end
                if point then
                    if x:IsAlive() then
                    	FindClearSpaceForUnit(x,point,true)

						PlayerResource:SetCameraTarget(x:GetPlayerOwnerID(),x)

						Timers:CreateTimer(function()
							PlayerResource:SetCameraTarget(x:GetPlayerOwnerID(),nil)
							ParticleManager:DestroyParticle(x.duelParticle, false)
							x:EmitSound("Portal.Hero_Disappear")
						end, DoUniqueString("camera"), 0.06)
                    end
                    x.duel_old_point = nil
                else
                    print("Duel system error, base points not found!")
                end
            end
        end
    end
end

function getHeroesToDuelFromTeamTable(heroes_table, hero_count)
    if getAliveHeroesCount(heroes_table) < hero_count then
        print("Duel system error, alive heroes < hero count. Fix it!")
        return
    end

    local heroes_table = shuffle(heroes_table)

    local counter_local = 0;
    local output_table = {}

    local function checkHero( x )
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and x.IsDueled == false and isConnected(x) then --x.IsDisconnect == false then
            if x:HasAbility("meepo_divided_we_stand") then
                local meepo_duel_table = Entities:FindAllByName(x:GetUnitName())
                if meepo_duel_table then
                    for i = 1, #meepo_duel_table do
                        if meepo_duel_table[i] and not meepo_duel_table[i]:IsIllusion() and x:GetPlayerOwner() == meepo_duel_table[i]:GetPlayerOwner()  then
                            meepo_duel_table[i].IsDueled = true
                            table.insert(output_table, meepo_duel_table[i])
                        end
                    end
                end
            else
                x.IsDueled = true
                table.insert(output_table, x)
            end
            counter_local = counter_local + 1
        end
    end

    local anyHuman = false

    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and isConnected(x) then
        	if PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID()) > 0 then
        		anyHuman = true
        		break
        	end
        end
    end

    local addedHuman = false

    if anyHuman then
	    for _, x in pairs(heroes_table) do
	    	if PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID()) > 0 then
	    		x.IsDueled = false
	    		checkHero( x )
	    		addedHuman = true
		        if counter_local == hero_count then
		            return output_table
		        end
	    	end
	    end
    end
 
    for _, x in pairs(heroes_table) do
    	checkHero( x )
        if counter_local == hero_count then
            return output_table
        end
    end

    if anyHuman then
    	print("added: ", addedHuman)
    end

    if counter_local < hero_count then -- if some heroes already dueled
        clearDuelFromHeroes(heroes_table)
        return getHeroesToDuelFromTeamTable(heroes_table, hero_count)
    end
end

function toTribune(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then
        print("[DS]Duel system error, invalid unit, expected hero (global func ToTribune)")
        return
    end
    local team = hero:GetTeamNumber()
    if team == DOTA_TEAM_GOODGUYS then
    	local x = arenas[current_arena].tribune_points.radiant[hero:GetPlayerID() + 1]
    	FindClearSpaceForUnit(hero,x,true)
    	hero:SetForwardVector(-(x - getMidPoint(arenas[current_arena].polygon)):Normalized())
    	hero:RemoveModifierByName("modifier_tribune")
        hero:AddNewModifier(hero, nil, "modifier_tribune", {})
    else
    	local x = arenas[current_arena].tribune_points.dire[hero:GetPlayerID() + 1]
        FindClearSpaceForUnit(hero,x,true)
        hero:SetForwardVector(-(x - getMidPoint(arenas[current_arena].polygon)):Normalized())
        hero:RemoveModifierByName("modifier_tribune")
        hero:AddNewModifier(hero, nil, "modifier_tribune", {})
    end
end

function isHeroDuelWarrior(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then
        return false
    end
    for _, x in pairs(duel_radiant_warriors) do
        if x == hero then return true end
    end
    for _, x in pairs(duel_dire_warriors) do
        if x == hero then return true end
    end
    return false
end

function endDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, duel_victory_team)
	if not duel_active then return end
    duel_active = false

    winners = duel_victory_team

    if winners > 0 then
    	print("winners: ", winners)
    	EmitGlobalSound("Hero_LegionCommander.Duel.Victory")
    end

    local function prepareHero( x )
    	x:AddNewModifier(x,nil,"modifier_tribune",{duration = 4})

		x:RemoveGesture(ACT_DOTA_DEFEAT)
		x:RemoveGesture(ACT_DOTA_VICTORY)
        if x:GetTeamNumber() == duel_victory_team then
        	x:StartGesture(ACT_DOTA_VICTORY)

        	CustomGameEventManager:Send_ServerToPlayer(x:GetPlayerOwner(),"duel_win",{})
        else
        	x:StartGesture(ACT_DOTA_DEFEAT)
        end
        local t = 0
        Timers:CreateTimer(function()
        	if t > 4 then 
        		x:RemoveGesture(ACT_DOTA_DEFEAT)
        		x:RemoveGesture(ACT_DOTA_VICTORY)
        		return nil
        	end
	    	t = t + 0.03
	    	return 0.03
	    end, DoUniqueString("duel_end_point"), 0.03)
    end

	for _,x in pairs(Entities:FindAllByName("npc_dota_hero*")) do
		if IsValidEntity(x) == true and x.GetPlayerOwnerID and x:IsNull() == false and not x:IsClone() then
            if x:HasAbility("meepo_divided_we_stand") then
                local meepo_return_table = Entities:FindAllByName(x:GetUnitName())

                for k,v in pairs(meepo_return_table) do
                	if v and not v:IsIllusion() and x:GetPlayerOwner() == v:GetPlayerOwner() then
                		prepareHero( v )
                	end
                end
            else
            	prepareHero( x )
            end
		end
	end

	Timers:CreateTimer(function()
	    if radiant_heroes and dire_heroes then
	    	winners = duel_victory_team
	        if duel_victory_team ~= -1 then
	            removeHeroesFromDuel(radiant_heroes)
	            removeHeroesFromDuel(dire_heroes)
	            duel_radiant_warriors = {}
	            duel_dire_warriors = {}
	            duel_radiant_heroes = {}
	            duel_dire_heroes = {}
	        end

			local ents = Entities:FindAllInSphere(Vector(0,0,0), 100000)

			for k,v in pairs(ents) do
				if IsValidEntity(v) and v.IsRealHero and v:IsRealHero() == false and v:IsAlive() and (v:IsCreep() or v:IsCreature() or v:IsBuilding() or v:IsCourier()) then
					if v:IsBuilding() and not v:IsTower() then

					else
						if v:IsNeutralUnitType() then

						else
							v:RemoveNoDraw()
						end
						v:RemoveModifierByName("modifier_duel_out_of_game")
						v:RemoveModifierByName("modifier_tribune")
					end
					if v._duelDayVisionRange and v._duelNightVisionRange then
						v:SetDayTimeVisionRange(v._duelDayVisionRange)
						v:SetNightTimeVisionRange(v._duelNightVisionRange)
					end
				end
			end

			for k,v in pairs(temp_vision) do
				UTIL_Remove(v)
			end

			for k,v in pairs(temp_entities) do
				UTIL_Remove(v)
			end

			for k,v in pairs(temp_obstacles) do
				if v.blockers then
					for k2,v2 in pairs(v.blockers) do
						UTIL_Remove(v2)
					end
				end
				UTIL_Remove(v)
			end

			local tempTrees = Entities:FindAllByClassname("dota_temp_tree")

			for k,v in pairs(tempTrees) do
				UTIL_Remove(v)
			end

			GridNav:RegrowAllTrees()

			Convars:SetBool("dota_creeps_no_spawning", false)

	        if type(end_duel_callback) == "function" then
	            end_duel_callback(duel_victory_team)
	        end
	    else
	        print("ERROR, INVALID HEROES TABLE(EndDuel(...))")
	    end
	end, DoUniqueString("duel_end_timer"), 4.0)

    GameRules:SendCustomMessage("#duel_end", 0, 0)
end

function startDuel(radiant_heroes, dire_heroes, hero_count, draw_time, error_callback, end_duel_callback, arena)
    if not radiant_heroes or not dire_heroes then
        local err ="[DS] Duel system error, {} tables of heroes! "
        print(err)
        return
    end
 
    for i,x in pairs(radiant_heroes) do
        if not x then
            table.remove(radiant_heroes, i)
        end
    end
 
    for i,x in pairs(dire_heroes) do
        if not x then
            table.remove(dire_heroes, i)
        end
    end
   
    if duel_active == true then
        local err ="Duel system error, duel already started "
        print(err)
        if type(error_callback) == "function" then
            error_callback({ err_code = -1, err_string = err})
        end
        return
    end
    local radiant_count, dire_count = getHeroesCount(radiant_heroes, dire_heroes)
    if (radiant_count < hero_count) or (dire_count < hero_count) or (hero_count <= 0) then
        local err = "Duel system error, not enought players / invalid players count waiting for " .. hero_count .. " got rh = " .. radiant_count .. " dh = " .. dire_count
        print(err)
        GameRules:SendCustomMessage("#duel_error", 0, 0)
        endDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end
 
 
    local radiant_warriors = getHeroesToDuelFromTeamTable(radiant_heroes, hero_count)
    local dire_warriors = getHeroesToDuelFromTeamTable(dire_heroes, hero_count)
 
    if (not radiant_warriors) or (not dire_warriors) then
        local err = "[DS] Duel system error, not enought heroes for duel[2]. waiting "
        print(err)
        GameRules:SendCustomMessage("#duel_error", 0, 0)
        endDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end
 
    GameRules:SendCustomMessage("#duel_start", 0, 0)
 
    duel_radiant_warriors = radiant_warriors
    duel_dire_warriors = dire_warriors
    duel_end_callback = end_duel_callback
    duel_radiant_heroes = radiant_heroes
    duel_dire_heroes = dire_heroes
 
    duel_count = duel_count + 1
    duel_active = true

    current_arena = arena

    for _,v in pairs(Entities:FindAllByName("npc_dota_hero*")) do
	    if IsValidEntity(v) == true and v:IsNull() == false and v.GetPlayerOwnerID and v:IsAlive() == true then
	    	v:AddNewModifier(v,nil,"modifier_tribune",{})
			v.duelParticle = ParticleManager:CreateParticle( "particles/items2_fx/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
			ParticleManager:SetParticleControl(v.duelParticle, 0, v:GetAbsOrigin() + Vector(0,0,30))
			ParticleManager:SetParticleControl(v.duelParticle, 1, v:GetAbsOrigin() + Vector(0,0,30))
			ParticleManager:SetParticleControl(v.duelParticle, 2, Vector(40,40,200))
			ParticleManager:SetParticleControl(v.duelParticle, 3, v:GetAbsOrigin() + Vector(0,0,30))
	    end
    end

    Timers:CreateTimer(function()
	    moveHeroesToTribune(radiant_heroes, arenas[current_arena].tribune_points.radiant)
	    moveHeroesToTribune(dire_heroes, arenas[current_arena].tribune_points.dire)
	    moveToDuel(radiant_warriors, radiant_heroes, arenas[current_arena].duel_points.radiant)
	    moveToDuel(dire_warriors, dire_heroes, arenas[current_arena].duel_points.dire)
    end, "duel_move_heroes", DUEL_PREPARE)

    freezeGameplay()

    spawnEntitiesAlongPath( arenas[current_arena].polygon )

    Convars:SetBool("dota_creeps_no_spawning", true)
 
    Timers:CreateTimer(function()
    	print("draw")
        endDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
    end, "DS_DRAW_ITERNAL", draw_time)

    local visionTimer = 0
    local revealTime = 5
    local revealThreshold = 7

    Timers:CreateTimer(function()
    	if not duel_active then
    		return
    	end

    	local radiantSeesDire = false

    	for k,v in pairs(dire_warriors) do
    		if radiant_warriors[1]:CanEntityBeSeenByMyTeam(v) and not v:HasModifier("modifier_tribune") and v:IsAlive() then
    			radiantSeesDire = true 
    			break
    		end
    	end

    	local direSeesRadiant = false

    	for k,v in pairs(radiant_warriors) do
    		if dire_warriors[1]:CanEntityBeSeenByMyTeam(v) and not v:HasModifier("modifier_tribune") and v:IsAlive() then
    			direSeesRadiant = true 
    			break
    		end
    	end

    	if not direSeesRadiant and not radiantSeesDire then
    		if visionTimer == revealThreshold then
	    		for k,v in pairs(radiant_warriors) do
	    			if not v:HasModifier("modifier_tribune") and v:IsAlive() then
	    				-- local dummy = CreateUnitByName("npc_dummy_unit",v:GetAbsOrigin(),false,nil,nil,DOTA_TEAM_BADGUYS)
	    				-- dummy:SetNightTimeVisionRange(512)
	    				-- dummy:SetDayTimeVisionRange(512)
	    				-- dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration = revealTime})
	    				v:AddNewModifier(dire_warriors[1],nil,"modifier_truesight",{duration = revealTime})
	    				-- dummy:AddNewModifier(dummy,nil,"modifier_invis_reveal",{duration = revealTime})

	    				AddFOWViewer(DOTA_TEAM_BADGUYS,v:GetAbsOrigin(),512,revealTime,true)
	    			end
	    		end
	    		for k,v in pairs(dire_warriors) do
	    			if not v:HasModifier("modifier_tribune") and v:IsAlive() then
	    				-- local dummy = CreateUnitByName("npc_dummy_unit",v:GetAbsOrigin(),false,nil,nil,DOTA_TEAM_GOODGUYS)
	    				-- dummy:SetNightTimeVisionRange(512)
	    				-- dummy:SetDayTimeVisionRange(512)
	    				-- dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration = revealTime})
	    				v:AddNewModifier(radiant_warriors[1],nil,"modifier_truesight",{duration = revealTime})
	    				-- dummy:AddNewModifier(dummy,nil,"modifier_invis_reveal",{duration = revealTime})

	    				AddFOWViewer(DOTA_TEAM_GOODGUYS,v:GetAbsOrigin(),512,revealTime,true)
	    			end
	    		end
	    		visionTimer = 0
    		else
    			visionTimer = visionTimer + 1
    		end
    	end

    	return 1.0
    end, "vision_check", 0.0)
end

function _OnHeroDeathOnDuel(warriors_table, hero )
    for i, x in pairs(warriors_table) do
        if x == hero then
            table.remove(warriors_table, i)

            if hero:HasAbility("meepo_divided_we_stand") then
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == hero:GetUnitName() and hero:GetPlayerOwner() == y:GetPlayerOwner() then
                        table.remove(warriors_table, j)
                    end
                end
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == hero:GetUnitName() and hero:GetPlayerOwner() == y:GetPlayerOwner() then
                        table.remove(warriors_table, j)
                    end
                end
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == hero:GetUnitName() and hero:GetPlayerOwner() == y:GetPlayerOwner() then
                        table.remove(warriors_table, j)
                    end
                end
            end
 
            if #warriors_table == 0 then
                duel_victory_team = ((x:GetTeamNumber() == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS) or ((x:GetTeamNumber() == DOTA_TEAM_BADGUYS) and DOTA_TEAM_GOODGUYS)
                print("all play dead")
                endDuel(duel_radiant_heroes, duel_dire_heroes, duel_radiant_warriors, duel_dire_warriors, duel_end_callback, duel_victory_team )
                print("team victory = " , duel_victory_team)
            end

            if winners ~= -1 and hero:GetTeamNumber() ~= winners then
            	hero:SetTimeUntilRespawn(3)
            else
            	hero:SetTimeUntilRespawn(3)
            end
            return
        end
    end
end

function deathListener( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then return end
	if killedUnit.deathsim then
		local particle = ParticleManager:CreateParticle("particles/world_destruction_fx/dire_tree007_destruction.vpcf",PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(particle,0,killedUnit:GetAbsOrigin())
		killedUnit:AddNoDraw()
	end
    if killedUnit.blockers then
    	for k,v in pairs(killedUnit.blockers) do
    		UTIL_Remove(v)
    	end
    end
    if not duel_active then return end
    if not event.entindex_attacker then return end

    local killedTeam = killedUnit:GetTeam()
    local hero = EntIndexToHScript( event.entindex_attacker )
    local heroTeam = hero:GetTeam()
   
    if not killedUnit or not IsValidEntity(killedUnit) or not killedUnit:IsRealHero() then return end

    if killedUnit:IsReincarnating() then
    	killedUnit.duelReincarnation = true
    	return
    end
 
    if duel_active then
       _OnHeroDeathOnDuel(duel_radiant_warriors, killedUnit )
       _OnHeroDeathOnDuel(duel_dire_warriors, killedUnit )
    end
end

function getTeamPointNameByTeamNumber(table_of_points, teamnumber)
    if teamnumber == DOTA_TEAM_GOODGUYS then
        return table_of_points.radiant
    elseif teamnumber == DOTA_TEAM_BADGUYS then
        return table_of_points.dire
    else
    end
end

function spawnListener(event)
    if not duel_active then return end
    local spawnedUnit = EntIndexToHScript( event.entindex )
    if not spawnedUnit or not IsValidEntity(spawnedUnit) or not spawnedUnit:IsRealHero() then
        return
    end

    if spawnedUnit:IsRealHero() then
        if duel_active and not isHeroDuelWarrior(spawnedUnit) then
            toTribune(spawnedUnit)
        end
    end
 
	Timers:CreateTimer(function()
        if not spawnedUnit then return nil end
 
        if not spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
            if spawnedUnit:IsRealHero() then
            	if spawnedUnit.duelReincarnation then
            		spawnedUnit.duelReincarnation = false
            		return
            	end

                if duel_active then -- and not isHeroDuelWarrior(spawnedUnit)
                    toTribune(spawnedUnit)
                end
            end
        end
       
		return nil
	end, DoUniqueString('preventcamping'), 0.15)
end

function getMaximumAliveHeroes(hero_table1, hero_table2)
    local alive_max = 0
    for _, x in pairs(hero_table1) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and isConnected(x) then alive_max = alive_max + 1 end
    end
 
    local al = alive_max
    alive_max = 0
    for _, x in pairs(hero_table2) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and isConnected(x) then alive_max = alive_max + 1 end
    end
    if alive_max > al then
        return al
    else
        return alive_max
    end
end
 
function isConnected(unit)
    return not isDisconnected(unit)
end
 
function isDisconnected(unit)
    if not unit or not IsValidEntity(unit) then
        return false
    end
 
    local playerid = unit:GetPlayerOwnerID()
    if not playerid then
        return false
    end
 
    local connection_state = PlayerResource:GetConnectionState(playerid)
    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
        return true
    else
        return false
    end
end
 
function isAbadoned(unit)
    if not unit or not IsValidEntity(unit) then return false end
 
    local playerid = unit:GetPlayerOwnerID()
    if not playerid then return false end
    local connection_state = PlayerResource:GetConnectionState(playerid)
 
    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then
        return true
    else
        return false
    end
end
 
ListenToGameEvent("entity_killed", deathListener, nil)
ListenToGameEvent('npc_spawned', spawnListener, nil )

function destroyTrees(pos, radius)
	local trees = GridNav:GetAllTreesAroundPoint(pos, radius, true)

	GridNav:DestroyTreesAroundPoint(pos, radius, true)
end

function generatePoints( initial, p )
	for k,v in pairs(initial) do -- arenas
		for k2,v2 in pairs(v[p]) do -- teams
			destroyTrees(v2[1], 32)
			for i=2,10 do
				local xOffset = 0
				local yOffset = 0
				if i >= 6 then
					xOffset = -128
					yOffset = 128 * 5
				end
				v2[i] = v2[1] + Vector(xOffset, (-128 * i) + yOffset, 0)
				destroyTrees(v2[i], 32)

				-- AddFOWViewer(DOTA_TEAM_GOODGUYS, initial[k][k2][i], 128, 5.0, false)
				-- AddFOWViewer(DOTA_TEAM_BADGUYS, initial[k][k2][i], 128, 5.0, false)
			end
		end
	end
end

function initDuel(restart)
	winners = -1

	generatePoints( arenas, "tribune_points" )
	generatePoints( arenas, "duel_points" )

	local radiantHeroes = {}
	local direHeroes = {}

	restart = restart or (function (  ) end)

	for _,v in pairs(Entities:FindAllByName("npc_dota_hero*")) do
		if IsValidEntity(v) and v:IsNull() == false and v.GetPlayerOwnerID and isConnected(v) and not v:IsClone() and not v:HasModifier("modifier_arc_warden_tempest_double") then
	  		if v:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
	  			table.insert(radiantHeroes, v)
	  		else
	  			table.insert(direHeroes, v)
	  		end
		end
	end

	local max_alives = getMaximumAliveHeroes(radiantHeroes, direHeroes)
  	if max_alives < 1 then max_alives = 1 end
  	local c = RandomInt(1, max_alives)

  	local arena = AAR_SMALL_ARENA

  	if c == 5 then
  		arena = AAR_GIANT_ARENA
  	end
  	if c > 1 and c < 5 then
  		arena = AAR_BIG_ARENA
  	end

	startDuel(radiantHeroes, direHeroes, c, DUEL_NOBODY_WINS + DUEL_PREPARE, function(err_arg) DeepPrintTable(err_arg) end, function(winner_side)
		restart()
	end, arena)
end

-- function endDuel()

-- end

function freezeGameplay()
	Convars:SetBool("dota_creeps_no_spawning", true)

	local ents = Entities:FindAllInSphere(Vector(0,0,0), 100000)

	for k,v in pairs(ents) do
		if v.HasModifier and v:HasModifier("modifier_arc_warden_tempest_double") then
			v:ForceKill(false)
			return
		end
		if IsValidEntity(v) and v.IsRealHero and v:IsRealHero() == false and v:IsAlive() and (v:IsCreep() or v:IsCreature() or v:IsBuilding() or v:IsCourier()) then
			if v:IsBuilding() and not v:IsTower() then

			else
				if v:IsNeutralUnitType() then
				else
					v:AddNoDraw()
				end

				v:AddNewModifier(v,nil,"modifier_duel_out_of_game",{})

				-- if v:IsCreature() and v:IsCreep() then
				if duel_radiant_heroes[1]:CanEntityBeSeenByMyTeam(v) or duel_dire_heroes[1]:CanEntityBeSeenByMyTeam(v) then
					local p = ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf",PATTACH_CUSTOMORIGIN,nil)
					ParticleManager:SetParticleControl(p,0,v:GetAbsOrigin())
				end
				-- end

				AddFOWViewer(v:GetTeamNumber(),v:GetAbsOrigin(),300,1.0,true)
			end
			v._duelDayVisionRange = v:GetDayTimeVisionRange()
			v._duelNightVisionRange = v:GetNightTimeVisionRange()
			v:SetDayTimeVisionRange(1)
			v:SetNightTimeVisionRange(1)
		end
	end
end

function spawnEntitiesAlongPath( path )
	temp_obstacles = {}
	temp_vision = {}
	temp_entities = {}

	local tempTrees = Entities:FindAllByClassname("dota_temp_tree")

	for k,v in pairs(tempTrees) do
		v:CutDown(-1)
	end

	if current_arena == AAR_SMALL_ARENA or current_arena == AAR_BIG_ARENA then
		local obstacle_counts = {}
		for i=1,arenas[current_arena].random_obstacles do
			local nextPoint = randomPointInPolygon( arenas[current_arena].polygon )
			nextPoint = GetGroundPosition(nextPoint,obstacle)

			local obstacleTable = arenas[current_arena].obstacle_models[RandomInt(1,#arenas[current_arena].obstacle_models)]

			local obstacleTable
			repeat
				obstacleTable = arenas[current_arena].obstacle_models[RandomInt(1,#arenas[current_arena].obstacle_models)]
				obstacle_counts[obstacleTable.name] = obstacle_counts[obstacleTable.name] or 0
			until obstacle_counts[obstacleTable.name] < obstacleTable.maxCount

			table.insert(temp_obstacles, spawnObstacleFromTable( obstacleTable, nextPoint, obstacle_counts ))
		end
	end

    Timers:CreateTimer(function()
		local j = #path
		for i = 1, #path do
			local offset = 128

			local direction = (path[i] - path[j]):Normalized()
			local distance = (path[j] - path[i]):Length2D()

			for x=0,distance,128 do
				local pos = GetGroundPosition(path[j] + (direction * x),obstacle)
				local scale = 1.0
				local model = arenas[current_arena].wallModel
				if x == 0 then
					model = arenas[current_arena].towerModel
					scale = 1.5
				end
				local obstacle = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
				obstacle:SetAbsOrigin(pos)
				obstacle:SetModelScale(scale)

				if x == 0 then
					obstacle:SetForwardVector((pos - getMidPoint(path)):Normalized())
				end

				for x=-1,1 do
					for y=-1,1 do
						table.insert(temp_entities, SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos + Vector(x * 32,y * 32,0), block_fow = true}))
					end
				end
				
				destroyTrees(pos, 256)

				AddFOWViewer(DOTA_TEAM_GOODGUYS, pos, 256, 5.0, false)
				AddFOWViewer(DOTA_TEAM_BADGUYS, pos, 256, 5.0, false)

				table.insert(temp_entities, obstacle)
			end

		    j = i
		end
    end, DoUniqueString("walls"), 0.5)

	local tempTrees = Entities:FindAllByClassname("dota_temp_tree")

	for k,v in pairs(temp_entities) do
		for k2,v2 in pairs(tempTrees) do
			if v2:GetOrigin() == v:GetOrigin() then
				v2:SetModel("models/development/invisiblebox.vmdl")
			end
		end
	end

	Timers:CreateTimer(function()
		if current_arena == AAR_SMALL_ARENA or current_arena == AAR_BIG_ARENA then
			local trees = Entities:FindAllByClassname("ent_dota_tree")

			for k,v in pairs(trees) do
				if isPointInsidePolygon(v:GetAbsOrigin(), path) then
					local pos = v:GetAbsOrigin()
					destroyTrees(pos, 256)

					Timers:CreateTimer(function()
						AddFOWViewer(DOTA_TEAM_GOODGUYS, pos, 256, DUEL_PREPARE+2, false)
						AddFOWViewer(DOTA_TEAM_BADGUYS, pos, 256, DUEL_PREPARE+2, false)
				    end, DoUniqueString("tree_workaround"), DUEL_PREPARE + 1)
				end
			end
		end

	end, DoUniqueString("clear_trees"), 1.0)
end

function isPointInsidePolygon(point, polygon)
	local oddNodes = false
	local j = #polygon
	for i = 1, #polygon do
	    if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
	        if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
	            oddNodes = not oddNodes
	        end
	    end
	    j = i
	end
	return oddNodes
end

function getMidPoint( points )
	local midPoint = Vector(0,0,0)
    for i=1,#points do
    	midPoint = midPoint + points[i]
    end
    midPoint = midPoint / #points
    return midPoint
end

function saveAbilitiesCooldowns(unit)
    if not unit then
        return
    end
   
    local savetable = {}
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            savetable[i] = unit:GetAbilityByIndex(i):GetCooldownTimeRemaining()
            --print("Save Ability Cooldown abilityname='" .. unit:GetAbilityByIndex(i):GetAbilityName() .. "' cooldown = " .. savetable[i])
        end
    end
 
    savetable.items = {}
 
    for i = 0, 5 do
        if unit:GetItemInSlot(i) then
            savetable.items[unit:GetItemInSlot(i)] = unit:GetItemInSlot(i):GetCooldownTimeRemaining()
        end
    end
 
    return savetable
end
 
function setAbilitiesCooldowns(unit, settable)
    local abilities = unit:GetAbilityCount() - 1
    if not settable or not unit then
        return
    end
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):StartCooldown(settable[i])
            if settable[i] == 0 then
                unit:GetAbilityByIndex(i):EndCooldown()
            end
        end
    end
 
    if settable.items then
        for item, cooldown in pairs(settable.items) do
            if item and IsValidEntity(item) then
                item:EndCooldown()
                print("start cooldown for ", item:GetName(), item, cooldown)
                item:StartCooldown(cooldown)
            end
        end
    end
end
 
function resetAllAbilitiesCooldown(unit, item_table)
    if not unit then return end
 
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):EndCooldown()
        end
    end
 
    if item_table then
        if item_table.items then
            for i,x in pairs(item_table.items) do
                i:EndCooldown()
                if i:GetName() == "item_tpscroll" or i:GetName() == "item_travel_boots" or i:GetName() == "item_travel_boots_2" then
                	i:StartCooldown(DUEL_NOBODY_WINS + DUEL_PREPARE)
                end
            end
        end
    end
end

function sendEventTimer(text, time)
	local t = time
    local minutes = math.floor(t / DUEL_NOBODY_WINS)
    local seconds = t - (minutes * DUEL_NOBODY_WINS)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local timer_text = m10 .. m01 .. ":" .. s10 .. s01

    local text_color = "#FFFFFF"
    if time < 11 then
    	text_color = "#FF0000"
    end

    local data = 
    {
    	string = text,
    	time_string = timer_text,
    	color = text_color,
	}
    --CustomGameEventManager:Send_ServerToAllClients( "duel_text_update", data )
    CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_GOODGUYS, "duel_text_update", data )
    CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_BADGUYS, "duel_text_update", data )

end

function customAttension(text, time)
	local data = {
		string = text
	}
	CustomGameEventManager:Send_ServerToAllClients( "attension_text", data )

    Timers:CreateTimer(function()
    	CustomGameEventManager:Send_ServerToAllClients( "attension_close", nil )
		return nil 
    end, DoUniqueString(text), time)
end

function randomPointInPolygon( polygon )
	local minX = polygon[1].x
	local maxX = polygon[1].x
	local minY = polygon[1].y
	local maxY = polygon[1].y

	for k,v in pairs(polygon) do
      	minX = math.min( v.x, minX );
        maxX = math.max( v.x, maxX );
        minY = math.min( v.y, minY );
        maxY = math.max( v.y, maxY );
	end

	local nextPoint
	repeat
		nextPoint = Vector(RandomFloat(minX,maxX), RandomFloat(minY,maxY), 0)
	until isPointInsidePolygon(nextPoint, polygon)

	return nextPoint
end

function shuffle(list)
    local indices = {}
    for i = 1, #list do
        indices[#indices+1] = i
    end

    local shuffled = {}
    for i = 1, #list do
        local index = math.random(#indices)

        local value = list[indices[index]]

        table.remove(indices, index)

        shuffled[#shuffled+1] = value
    end

    return shuffled
end