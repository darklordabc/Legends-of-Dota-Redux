function DealDamage(target,attacker,damageAmount,damageType,damageFlags,ability)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local dtype = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  -- Damage Flags are:
  -- DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY
  -- DOTA_DAMAGE_FLAG_HPLOSS
  -- DOTA_DAMAGE_FLAG_IGNORS_COMPOSITE_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
  -- DOTA_DAMAGE_FLAG_NONE
  -- DOTA_DAMAGE_FLAG_NON_LETHAL
  -- DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
  -- DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT
  -- DOTA_DAMAGE_FLAG_REFLECTION
  -- DOTA_DAMAGE_FLAG_USE_COMBAT_PROFICIENCY
  
  if not IsValidEntity(target) and type(target) == "table" then -- assume a table was passed
  print("[DealDamage] Dealing "..dmg.." of type "..dtype.." from attacker "..attacker:GetName().." to the following targets: ")
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
      print("==[DealDamage] Target "..k..": "..v:GetName())
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = dtype,
          damage_flags = flags
        })
      end
    end
    return
  end
  
  print("[DealDamage] Dealing "..dmg.." of type "..dtype.." to "..target:GetName().." from attacker "..attacker:GetName())
  
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = dtype,
    damage_flags = flags
  })
end

function d_waves(keys)
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetSpecialValueFor("radius")
	local healthThreshold = ability:GetSpecialValueFor("hpthreshhold")

	if not ability:IsCooldownReady() then
		return
	end

	if caster:GetHealthPercent() < healthThreshold then
			ability:StartCooldown(ability:GetTrueCooldown())
			local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
	                              caster:GetCenter(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_CREEP,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_CLOSEST,
	                                false)
			local enemy_hero_found = FindUnitsInRadius( caster:GetTeamNumber(),
	                              caster:GetCenter(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_HERO,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_CLOSEST,
	                                false)
			-- If there is any nearby enemies trigger the gigatron
			if (#enemy_found + #enemy_hero_found) > 0 then
				ability:StartCooldown(5)
				Timers:CreateTimer(1,function() -- Have a slight delay so it gives a chance to get more enemies in GetHullRadius()
					--- Refresh the found enemies
					enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
	                              caster:GetCenter(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_CREEP,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_CLOSEST,
	                                false)

					enemy_hero_found = FindUnitsInRadius( caster:GetTeamNumber(),
	                              caster:GetCenter(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_HERO,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_CLOSEST,
	                                false)

					for k,v in pairs(enemy_found) do
						local hp = v:GetMaxHealth()
						local dmg = hp*0.55
						local time = k*0.25
						local rand = RandomFloat(0, 0.25)
						Timers:CreateTimer(rand+time,function()
							DealDamage(v,caster,dmg,DAMAGE_TYPE_PURE)
							local p = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_moonfall.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
							Creates a new particle effect
							]]

							ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 1, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 2, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 3, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 4, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 5, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]

							v:EmitSound("Hero_Luna.LucentBeam.Target")
						end)
					end
					for k,v in pairs(enemy_hero_found) do
						local hp = v:GetMaxHealth()
						local dmg = hp*0.09
						local time = (k-1)*0.25
						local rand = RandomFloat(0, 0.25)
						if dmg >= v:GetHealth() then
							dmg = v:GetHealth() - 1
						end
						Timers:CreateTimer(rand+time,function()
							DealDamage(v,caster,dmg,DAMAGE_TYPE_PURE)
							local p = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_moonfall.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
							Creates a new particle effect
							]]

							ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 1, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 2, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 3, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 4, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]
							ParticleManager:SetParticleControlEnt(p, 5, v, PATTACH_POINT_FOLLOW, "attach_origin", v:GetAbsOrigin(), true) --[[Returns:void
							No Description Set
							]]

							v:EmitSound("Hero_Luna.LucentBeam.Target")
						end)
					end		
				end)
			end
	end
end

function last_resort(keys)
	local caster = keys.caster

	local ab = keys.ability
	-- ab:EndCooldown()

	if ab:IsCooldownReady() and caster:GetHealthPercent() <= 10 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_last_resort_invulnerability_aura", {}) --[[Returns:void
		No Description Set
		]]
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_last_resort_invulnerability_building", {Duration=15}) --[[Returns:void
		No Description Set
		]]
		caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast") --[[Returns:void
		Play named sound for all players
		]]
		local messageinfo = {
			message = "Last Resort!",
			duration = 3
		}
		FireGameEvent("show_center_message",messageinfo)
		local teamname = "team"
		if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
			teamname = "Radiant"
		end
		if caster:GetTeam() == DOTA_TEAM_BADGUYS then
			teamname = "Dire"
		end
		GameRules:SendCustomMessage("The "..teamname.."'s Ancient has just used its <font color='#dd3f4e'>Last Resort</font>!", caster:GetTeam(), 0)
		ab:StartCooldown(keys.ability:GetTrueCooldown())
		local heroes = HeroList:GetAllHeroes()

		for k,v in pairs(heroes) do
			if v:GetTeam() == caster:GetTeam() then
				if v:IsAlive() ~= true then
					v:RespawnHero(false,false,false)
				end
			end
		end
	end

end

function LastResortParticleCreate(keys)
	local caster = keys.caster
	local target = keys.target

	local rad = target:GetModelRadius()

	target.lr_particle = ParticleManager:CreateParticle("particles/units/building/last_resort_ally.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
	Creates a new particle effect
	]]
	ParticleManager:SetParticleControl(target.lr_particle, 1, Vector(rad,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]
end

function LastResortParticleDestroy(keys)
	local caster = keys.caster
	local target = keys.target

	ParticleManager:DestroyParticle(target.lr_particle,false)
end

function frenzy(keys)
	local caster = keys.caster
	if caster:GetHealthPercent() < 35 and caster:GetHealthPercent() > 26 then
		if caster.show_warning == nil or caster.show_warning == false then
			ParticleManager:CreateParticle("particles/units/building/msg_frenzy_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster) --[[Returns:int
			Creates a new particle effect
			]]
			caster.show_warning = true
		end
	end

	if caster:GetHealthPercent() < 25 then
		if keys.ability:IsCooldownReady() then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_frenzy_bonus_effects", {}) --[[Returns:void
			No Description Set
			]]
			keys.ability:StartCooldown(keys.ability:GetTrueCooldown())
		end
	end

	if caster:GetHealthPercent() < 26 then caster:SetCustomHealthLabel("",0,0,0) end
	if caster:HasModifier("modifier_frenzy_bonus_effects") then caster:SetCustomHealthLabel("FRENZIED!",255,0,0) end
	if caster:GetHealthPercent() < 40 and caster:GetHealthPercent() > 26 then caster:SetCustomHealthLabel("Warning!",128,128,0) end
end