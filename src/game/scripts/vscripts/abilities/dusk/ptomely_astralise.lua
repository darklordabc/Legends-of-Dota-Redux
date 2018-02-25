ptomely_astralise = class({})

LinkLuaModifier("modifier_astralise","abilities/dusk/ptomely_astralise",LUA_MODIFIER_MOTION_NONE)

function ptomely_astralise:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")

	local enemy = caster:GetTeam() ~= target:GetTeam()

	if target:TriggerSpellAbsorb(self) then return end

	target:EmitSound("Ptomely.Astralise")

	if enemy then
		InflictDamage(target, caster, self, damage, DAMAGE_TYPE_MAGICAL)
	end

	target:AddNewModifier(caster, self, "modifier_astralise", {Duration=duration})
end

modifier_astralise = class({})

function modifier_astralise:GetEffectName()
	return "particles/units/heroes/hero_ptomely/astralise_unit_buff.vpcf"
end

function modifier_astralise:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true
	}
	return state
end

function modifier_astralise:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL
	}
	return func
end

function modifier_astralise:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_astralise:GetOverrideAnimationRate()
	return 0.5
end

function modifier_astralise:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_astralise:OnCreated(kv)
	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		local target = self:GetParent()
		local duration = self:GetDuration()
		local loc = target:GetAbsOrigin() + target:GetForwardVector()*-150

		loc = loc + Vector(0,0,90)

		local unit = FastDummy(loc,caster:GetTeam(),duration+0.1,0)

		target.astralise_unit = unit

		ParticleManager:CreateParticle("particles/units/heroes/hero_ptomely/astralise_ghost.vpcf",
			PATTACH_ABSORIGIN_FOLLOW, unit)
		local interval = self:GetAbility():GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end
end

function modifier_astralise:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		if target.astralise_unit and not target.astralise_unit:IsNull() then
			local loc = target.astralise_unit:GetAbsOrigin()
			local radius = self:GetAbility():GetSpecialValueFor("radius")
			local pct = self:GetAbility():GetSpecialValueFor("pulse_damage")/100
			local heal_pct = self:GetAbility():GetSpecialValueFor("ally_heal")/100

			local damage = 0
			local heal = 0

			if target:IsHero() then
				damage = self:GetParent():GetIntellect() * pct
				heal = self:GetParent():GetIntellect() * heal_pct
			end

			local enemies = FindEnemies(self:GetAbility():GetCaster(), loc, radius)
			local allies = FindAllies(self:GetAbility():GetCaster(), loc, radius)

			for k,v in pairs(enemies) do
				InflictDamage(v,self:GetAbility():GetCaster(),self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
			end

			for k,v in pairs(allies) do
				v:Heal(heal, self:GetAbility():GetCaster())
			end

			local p = ParticleManager:CreateParticle("particles/units/heroes/hero_ptomely/astralise_pulse.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(p, 0, loc)
			ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0))

			target.astralise_unit:EmitSound("Ptomely.AstralisePulse")
		end
	end
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
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

function FindEnemies(caster,point,radius,targets,flags)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            targets,
                            flags,
                            FIND_CLOSEST,
                            false)
end

function FindAllies(caster,point,radius,targets)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            targets,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)
end