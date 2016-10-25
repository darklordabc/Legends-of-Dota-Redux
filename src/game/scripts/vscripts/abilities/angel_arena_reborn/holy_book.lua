if IsServer() then
	require('lib/timers')
end

function GetDamagePercent(caster, ability)
	summ_pct = ability:GetSpecialValueFor("damage_percent")
	damage_decreased = 1
	--local damage_decreased = 2
	--if caster:GetUnitName() == "npc_dota_hero_storm_spirit" then
	--	damage_decreased = 3
	--end

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item and item~= ability and item:GetName() == ability:GetName() then
			summ_pct = summ_pct + (item:GetSpecialValueFor("damage_percent") or 0) / damage_decreased
		end
	end
	return summ_pct
end

function HolyBook_attack( keys )
	local caster = keys.caster
	if caster and not caster:IsRealHero() then return end
	if caster:PassivesDisabled() then return end
	local target = keys.target
	local ability = keys.ability
	local projectiles = require('lib/projectiles')
	local position = keys.target:GetAbsOrigin()
	local team = keys.target:GetOpposingTeamNumber()  
	local radius = keys.Radius
	local damage_percent = GetDamagePercent(caster, ability)--keys.ability:GetLevelSpecialValueFor( "damage_percent", keys.ability:GetLevel() - 1 )
	
	--GetDamagePercent(caster, ability)
	print(damage_percent)
	local damage = keys.Damage*(damage_percent/100)
	local fly_time
	local projectile_temp = projectiles[caster:GetUnitName()]
	local projectile_model, projectile_speed
	
	if projectile_temp then
		projectile_model = projectile_temp.model
		projectile_speed = projectile_temp.speed
	else
		projectile_model = ""
		projectile_speed = 2000
	end

	local damage_int_pct_add = 1

	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

	damage = damage / damage_int_pct_add


	local units = FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false) 
	local caster_attack_speed = caster:GetAttacksPerSecond()

	for _, x in pairs(units) do
		if x ~= keys.target then
			if x and caster and x:GetTeamNumber() ~= caster:GetTeamNumber() and IsValidEntity(x) and x:IsAlive() then
				
				if projectile_model and caster_attack_speed < 8 then
					local info = {
	      				Target = x,
        				Source = keys.target,
        				EffectName = projectile_model,
	        			bDodgeable = false,
        				bProvidesVision = true,
        				iMoveSpeed = projectile_speed,
        				iVisionRadius = 0,
        				iVisionTeamNumber = caster:GetTeamNumber(),
	    			}
    				ProjectileManager:CreateTrackingProjectile( info )
    				fly_time = FindDistance(x:GetAbsOrigin(), position) / projectile_speed
    			else
	    			fly_time = 0.1
   				end
   				Timers:CreateTimer(fly_time, function() -- таймер для спавна нейтралов
      							if x and IsValidEntity(x) and x:IsAlive() and caster and IsValidEntity(caster) then
      								if x:GetUnitName() == "npc_dota_hero_meepo" then
      									damage = damage/4
      								end
      								if target then
      									if x:IsIllusion() or target:IsIllusion() then
	      									damage = damage / 4
      									end
      								else
      									if x:IsIllusion() then
	      									damage = damage / 4
      									end
      								end
      								ApplyDamage({ victim = x, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_PURE })
      							end
				      			return nil
  								end )
			end
			
		end
	end
end

function FindDistance(vec1, vec2)
	return math.sqrt(math.abs(vec1.x - vec2.x)^2 + math.abs(vec1.y - vec2.y)^2 + math.abs(vec1.z - vec2.z)^2 )
end