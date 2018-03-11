aether_reality_shift = class({})

LinkLuaModifier("modifier_reality_shift_unit","abilities/dusk/aether_reality_shift",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reality_shift_show","abilities/dusk/aether_reality_shift",LUA_MODIFIER_MOTION_NONE)

function aether_reality_shift:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	local m = "modifier_reality_shift_unit"
	local m2 = "modifier_reality_shift_show"

	local predamage = self:GetSpecialValueFor("predamage")

	local delay = 0.4

	caster.teleport_to_monolith = false

	ScreenShake(caster:GetCenter(), 1200, 170, delay, 1200, 0, true)

	local unit = FastDummy(caster:GetAbsOrigin(),caster:GetTeam(),3,200)

	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_aether/aether_reality_shift.vpcf", PATTACH_POINT, unit) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p, 0, caster:GetCenter()+Vector(0,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	--caster:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.End")
	caster:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment")

	Timers:CreateTimer(delay,function()
		ParticleManager:DestroyParticle(p,false)
	end)

	Timers:CreateTimer(0.17,function()
		local found = FindUnitsInRadius( caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_BOTH,
	                                DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO,
	                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                                FIND_ANY_ORDER,
	                                false)

		-- if #found == 1 then
		-- 	caster.teleport_to_monolith = true
		-- 	keys.ability:EndCooldown()
		-- 	keys.ability:StartCooldown(25)
		-- 	duration = 2
		-- end

		for k,v in pairs(found) do
			if v ~= unit and v:GetUnitName() ~= "npc_dummy_unit" then
				v:Interrupt()
				if v:GetTeam() ~= caster:GetTeam() then
					DealDamage(v,caster,predamage,DAMAGE_TYPE_MAGICAL)
				end
				v:AddNewModifier(caster, self, m2, {Duration=duration-0.1}) --[[Returns:void
				No Description Set
				]]
				v:AddNewModifier(caster, self, m, {Duration=duration}) --[[Returns:void
				No Description Set
				]]
				v:AddNoDraw()
			end
		end
	end)
end

function aether_reality_shift:GetCooldown()
	local base_cooldown = self.BaseClass.GetCooldown(self, self:GetLevel())
	return base_cooldown
end

-- Modifiers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_reality_shift_unit = class({})

function modifier_reality_shift_unit:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_reality_shift_unit:CheckState()

	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}

	return state

end

function modifier_reality_shift_unit:IsHidden()
	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_reality_shift_show = class({})

function modifier_reality_shift_show:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_reality_shift_show:OnDestroy()

	--if IsServer() then

		local caster = self:GetAbility():GetCaster()
		local target = self:GetParent()

		local dmg = self:GetAbility():GetSpecialValueFor("damage")
		local stun = self:GetAbility():GetSpecialValueFor("stun")

		local radius = self:GetAbility():GetSpecialValueFor("radius")

		local delay = 0.4

		local pos = caster:GetAbsOrigin()

		local p = 0

		ScreenShake(caster:GetAbsOrigin(), 1200, 170, delay, 1200, 0, true)

		if target:GetTeam() ~= caster:GetTeam() then
			DealDamage(target,caster,dmg,DAMAGE_TYPE_MAGICAL)
		end

		if caster == target then

			local unit = FastDummy(caster:GetAbsOrigin(),caster:GetTeam(),3,200)

			caster:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.End")

			p = ParticleManager:CreateParticle("particles/units/heroes/hero_aether/aether_reality_shift.vpcf", PATTACH_POINT, unit) --[[Returns:int
			Creates a new particle effect
			]]

			ParticleManager:SetParticleControl(p, 0, caster:GetCenter()+Vector(0,0,0)) --[[Returns:void
			Set the control point data for a control on a particle effect
			]]

			local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
			                              caster:GetAbsOrigin(),
			                              nil,
			                                radius,
			                                DOTA_UNIT_TARGET_TEAM_ENEMY,
			                                DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO,
			                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			                                FIND_ANY_ORDER,
			                                false)

			for k,v in pairs(enemy_found) do
				v:AddNewModifier(caster, nil, "modifier_stunned", {Duration=stun}) --[[Returns:void
				No Description Set
				]]
				DealDamage(v,caster,dmg,DAMAGE_TYPE_PURE)
			end

		end

		Timers:CreateTimer(delay,function()
			ParticleManager:DestroyParticle(p,false)
			target:RemoveNoDraw()
		end)

	--end
end

function modifier_reality_shift_show:IsHidden()
	return true
end

function DealDamage(target,attacker,damageAmount,damageType,damageFlags,ability)
  local target = target
  local attacker = attacker or target
  local dmg = damageAmount
  local type = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  if not IsValidEntity(target) and type(target) == "table" then
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = type,
          damage_flags = flags
        })
      end
    end
    return
  end
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = type,
    damage_flags = flags
  })
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0.03
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target)
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
      Timers:CreateTimer(duration,function()
        if not dummy:IsNull() then
          dummy:ForceKill(true)
          --dummy:Destroy()
          UTIL_Remove(dummy)
        end
      end)
  end
  return dummy
end