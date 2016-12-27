require('lib/physics')
require('lib/util_dusk')
require('lib/timers')
function summon_vassal(keys)
	local caster = keys.caster
	local vassal = keys.vassal -- 1 red, 2 green, 3 blue
	local lvl = keys.ability:GetLevel()
	local origin = caster:GetAbsOrigin() + (caster:GetForwardVector()*125) + Vector(0,0,-100)
	local unit = caster
	local FindClearSpace = true
	local killunit = false
	local PutSwitchOnCooldown = false
	if caster:GetUnitName() == "npc_dota_unit_vassal_red" or caster:GetUnitName() == "npc_dota_unit_vassal_blue" then
		origin = caster:GetAbsOrigin()
		caster = caster:GetOwner()
		killunit = true
		FindClearSpace = false
		PutSwitchOnCooldown = true
	end
	local player = caster:GetPlayerID()
	local unit_name = {
		[1] = "npc_dota_unit_vassal_red",
		[2] = "npc_dota_unit_vassal_green",
		[3] = "npc_dota_unit_vassal_blue",
		[4] = "npc_dota_unit_sentinel_1",
		[5] = "npc_dota_unit_forcefield",
		[6] = "npc_dota_unit_cloakfield",
		[7] = "npc_dota_unit_tesla_coil"
	}
	local sent_abilities = {
		[1] = "sentinel_spin_up",
		[2] = "sentinel_shields",
		[3] = "sentinel_rockets",
		[4] = "sentinel_armor_piercing_round"
	}
	local unit_times = {
		[1] = nil,
		[2] = nil,
		[3] = nil,
		[4] = 24,
		[5] = 25,
		[6] = 30,
		[7] = 160
	}
	print("KILLING VASSAL #1")
	
	if caster.vassals ~= nil then

		if vassal ~= 4 and vassal ~= 7 then -- if we're dealing with something there can only be one of
			if vassal <= 3 then -- we're dealing with a vassal, not a normal unit
				if IsValidEntity(caster.vassals[1]) then
					if caster.vassals[1]:IsAlive() then
						caster.vassals[1]:ForceKill(false)
					end
				end
				if IsValidEntity(caster.vassals[3]) then
					if caster.vassals[3]:IsAlive() then
						caster.vassals[3]:ForceKill(false)
					end
				end
			end
			if IsValidEntity(caster.vassals[vassal]) then
				if caster.vassals[vassal]:IsAlive() then
					caster.vassals[vassal]:ForceKill(false)
				end
			end
		end

		
	end
	local v = CreateUnitByName(unit_name[vassal], origin, FindClearSpace, caster, caster, caster:GetTeamNumber())
	--v:SetPlayerID(caster:GetPlayerID())
	v:SetControllableByPlayer(player, true)
	v:CreatureLevelUp(lvl-1)

	if vassal == 3 then v.mode = 0 end

	if PutSwitchOnCooldown then v:GetAbilityByIndex(2):StartCooldown(45) end

	if caster.vassals == nil then caster.vassals = {} else caster.vassals = caster.vassals end

	caster.vassals[vassal] = v

	if vassal == 4 then -- if we're creating the Sentinel instead of a Vassal

		for i = 1,4 do
			if i <= lvl then
				v:AddAbility(sent_abilities[i]) --[[Returns:void
				Add an ability to this unit by name.
				]]
				local ab = v:FindAbilityByName(sent_abilities[i]) --[[Returns:handle
				Retrieve an ability by name from the unit.
				]]
				ab:SetLevel(1)
			end 
		end

		local found = FindUnitsInRadius( caster:GetTeamNumber(),
                          caster:GetAbsOrigin(),
                          nil,
                        1100,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

		local hero_target = found[1]

		found = FindUnitsInRadius( caster:GetTeamNumber(),
                          caster:GetAbsOrigin(),
                          nil,
                        1100,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_BUILDING,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

		local building_target = found[1]

		found = FindUnitsInRadius( caster:GetTeamNumber(),
                          caster:GetAbsOrigin(),
                          nil,
                        1100,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

		local other_target = found[1]

		--v:MoveToPositionAggressive(v:GetAbsOrigin())

		if hero_target then
			print("targeting hero")
			Orders:IssueAttackOrder(v,hero_target)
			v:SetForceAttackTarget(hero_target) --[[Returns:void
			No Description Set
			]]
			v:SetForceAttackTarget(nil) --[[Returns:void
			No Description Set
			]]
		elseif building_target then
			print("targeting building")
			Orders:IssueAttackOrder(v,building_target)
			v:SetForceAttackTarget(hero_target) --[[Returns:void
			No Description Set
			]]
			v:SetForceAttackTarget(nil) --[[Returns:void
			No Description Set
			]]
		elseif other_target then
			print("targeting other")
			Orders:IssueAttackOrder(v,other_target)
			v:SetForceAttackTarget(hero_target) --[[Returns:void
			No Description Set
			]]
			v:SetForceAttackTarget(nil) --[[Returns:void
			No Description Set
			]]
		end



	else
		v.owner_caster = caster
		for i = 0,3 do
			local ab = v:GetAbilityByIndex(i) --[[Returns:handle
			Retrieve an ability by index from the unit.
			]]
			v:Purge(true, true, false, true, true)

			if ab ~= nil then

				ab:SetLevel(math.ceil(lvl))


			end
		end

	end

	if unit_times[vassal] ~= nil then
		v:AddNewModifier(caster, nil, "modifier_kill", {Duration=unit_times[vassal]}) --[[Returns:void
			No Description Set
			]]
	end

	if killunit == true then unit:RemoveSelf() end
end

function build(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin() + (caster:GetForwardVector()*200) + Vector(0,0,-200)

	caster.buildpart = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/build.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
	Creates a new particle effect
	]]
	ParticleManager:SetParticleControl(caster.buildpart, 0, origin) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

end

function buildend(keys)
	local caster = keys.caster

	if caster.buildpart ~= nil then
		ParticleManager:DestroyParticle(caster.buildpart,false)
	end
end

function StopSound( event )
	local target = event.target
	target:StopSound("Hero_ShadowShaman.Shackles")
end

function electric_flare(keys)
	local caster = keys.caster
	local target = keys.target_points[1]

	local dummy = FastDummy(target, caster:GetTeam(), 8, 0)

	
end

function ForcefieldCheck(keys)
	local caster = keys.caster
	local target = keys.target -- owner

	local targetPos = target:GetAbsOrigin()

	local casterPos = caster:GetAbsOrigin()

	local direction = (targetPos-casterPos):Normalized()

	local distance = caster:GetRangeToUnit(target)

	if target:IsInvulnerable() then return end

	if distance > 1000 and distance < 3000 then
		FindClearSpaceForUnit(target, casterPos+(direction*999), true)
	end

	local ab = target:GetAbilityByIndex(0) --[[Returns:handle
	Retrieve an ability by index from the unit.
	]]

	if ab ~= nil then

		ab:CreateVisibilityNode(casterPos, 100, 0.09) --[[Returns:void
		No Description Set
		]]

	end

end

function ChainLightning( event )

  local hero = event.caster
  local ability = event.ability

  local damage = event.damage
  local bounce_range = 400
  local decay = 0.0

  local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetOrigin(), hero, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)

  local target = units[math.random(1,#units)]

  if target == nil then return end

  local lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/tesla_coil_bolt.vpcf", PATTACH_CUSTOMORIGIN, hero)
  ParticleManager:SetParticleControl(lightningBolt,0,Vector(hero:GetAbsOrigin().x,hero:GetAbsOrigin().y,hero:GetAbsOrigin().z + hero:GetBoundingMaxs().z )) 
  ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z )) 
  --ParticleManager:SetParticleControlEnt(lightningBolt, 1, target, 1, "attach_hitloc", target:GetAbsOrigin(), true)

  EmitSoundOn("Hero_Zuus.ArcLightning.Target", target)  
  ApplyDamage({ victim = target, attacker = hero, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
  event.ability:ApplyDataDrivenModifier(hero, target, "modifier_tesla_coil_slow", {}) --[[Returns:void
      No Description Set
      ]]
end

function nanobots(keys)
	local caster = keys.caster
	local target = keys.target

	local stacks = target:GetModifierStackCount("modifier_nanobots",caster)

	target:SetModifierStackCount("modifier_nanobots",caster,stacks+1)
end

function short_range_teleport_start(keys)
	local caster = keys.caster
	local target = caster:GetCursorPosition()

	local caster_owner = caster:GetPlayerOwner()
	local delay = keys.delay

	local pos = caster:GetAbsOrigin()

	caster.srt = target

	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_short_range_teleport_delay", {Duration=delay})

	local unit = FastDummy(target,caster:GetTeam(),delay+0.25,250)

	caster.srt_part = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/teleport_show_des.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)


end

function short_range_teleport_go(keys)
	local caster = keys.target

	local position = caster.srt or caster:GetAbsOrigin()
	local radius = keys.radius

	local found = FindUnitsInRadius( caster:GetTeamNumber(),
                          caster:GetAbsOrigin(),
                          nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                        DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

	ParticleManager:DestroyParticle(caster.srt_part,false)

	for k,v in pairs(found) do
		if v:GetPlayerOwner() == caster:GetPlayerOwner() then
			local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
			Creates a new particle effect
			]]

			local vpos = v:GetAbsOrigin()
			local pos = caster:GetAbsOrigin()
			local f = position+(vpos-pos)

			FindClearSpaceForUnit(v, f, true)

			Timers:CreateTimer(0.06,function()

				local p = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
				Creates a new particle effect
				]]

			end)
		end
	end
end

function change_vassal(keys)
	local vassal = keys.caster
	local caster = vassal:GetOwner()
	local BLUE = 0
	local RED = 1

	local lvl = vassal:GetLevel()

	vassal:RemoveAbility("vassal_hel_array")
	vassal:RemoveAbility("vassal_mark")
	vassal:RemoveAbility("vassal_shield")
	vassal:RemoveAbility("vassal_lightning_leash")

	if vassal.mode == BLUE then
		-- Replace abilities.
		vassal:RemoveModifierByName("modifier_vassal_shield_aura")

		local ab1 = vassal:AddAbility("vassal_hel_array")
		local ab2 = vassal:AddAbility("vassal_mark")

		ab1:SetLevel(lvl)
		ab2:SetLevel(lvl)

		vassal:SetModel("models/summoner/summoner_vassal_red.vmdl") --[[Returns:void
		No Description Set
		]]
		vassal:SetOriginalModel("models/summoner/summoner_vassal_red.vmdl") --[[Returns:void
		Sets the original model of this entity, which it will tend to fall back to anytime its state changes
		]]

		vassal:SetBaseAttackTime(1.3) --[[Returns:void
		No Description Set
		]]

		vassal:SetBaseDamageMin(30+(lvl*30)) --[[Returns:void
		Sets the minimum base damage.
		]]

		vassal:SetBaseDamageMax(40+(lvl*30)) --[[Returns:void
		Sets the minimum base damage.
		]]

		vassal:SetRangedProjectileName("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_attack.vpcf") --[[Returns:void
		No Description Set
		]]

		local p = vassal:GetHealthPercent()/100

		vassal:SetMaxHealth(400+(lvl*50))
		vassal:SetBaseMaxHealth(400+(lvl*50)) --[[Returns:void
		Set a new base max health value.
		]]
		vassal:SetHealth(p*vassal:GetMaxHealth())

		vassal:SetUnitName("Red Vassal") --[[Returns:void
		No Description Set
		]]

		vassal.mode = RED
	elseif vassal.mode == RED then
		-- Replace abilities

		local ab1 = vassal:AddAbility("vassal_lightning_leash")
		local ab2 = vassal:AddAbility("vassal_shield")

		ab1:SetLevel(lvl)
		ab2:SetLevel(lvl)

		vassal:SetModel("models/summoner/summoner_vassal_blue.vmdl") --[[Returns:void
		No Description Set
		]]
		vassal:SetOriginalModel("models/summoner/summoner_vassal_blue.vmdl") --[[Returns:void
		Sets the original model of this entity, which it will tend to fall back to anytime its state changes
		]]

		vassal:SetRangedProjectileName("particles/units/heroes/hero_templar_assassin/templar_assassin_base_attack.vpcf") --[[Returns:void
		No Description Set
		]]

		vassal:SetBaseAttackTime(1.5) --[[Returns:void
		No Description Set
		]]

		vassal:SetBaseDamageMin(15+(lvl*15)) --[[Returns:void
		Sets the minimum base damage.
		]]

		vassal:SetBaseDamageMax(25+(lvl*15)) --[[Returns:void
		Sets the minimum base damage.
		]]

		local p = vassal:GetHealthPercent()/100

		vassal:SetMaxHealth(400+(lvl*75))
		vassal:SetBaseMaxHealth(400+(lvl*75)) --[[Returns:void
		Set a new base max health value.
		]]
		vassal:SetHealth(p*vassal:GetMaxHealth())

		vassal:SetUnitName("Blue Vassal") --[[Returns:void
		No Description Set
		]]

		vassal.mode = BLUE
	end


end