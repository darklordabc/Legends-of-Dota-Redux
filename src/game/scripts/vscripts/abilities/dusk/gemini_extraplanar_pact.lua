gemini_extraplanar_pact = class({})

LinkLuaModifier("modifier_extraplanar_pact_oog","abilities/dusk/gemini_extraplanar_pact",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_extraplanar_pact","abilities/dusk/gemini_extraplanar_pact",LUA_MODIFIER_MOTION_NONE)

function gemini_extraplanar_pact:OnSpellStart()
	local mod = "modifier_extraplanar_pact_oog"
	local mod2 = "modifier_extraplanar_pact"

	local oog_dur = self:GetSpecialValueFor("out_of_game_duration")
	local dur = self:GetSpecialValueFor("duration")

	local hp_mana = self:GetSpecialValueFor("health_and_mana_loss")/100

	local part = "particles/units/heroes/hero_gemini/gemini_extraplanar_pact_oog.vpcf"

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	target:AddNewModifier(caster, self, mod, {Duration = oog_dur}) --[[Returns:void
	No Description Set
	]]

	target:EmitSound("Voidwalker.ExtraplanarEmpowerment")

	Timers:CreateTimer(0.25,function()

		target:AddNoDraw()

		target:AddNewModifier(caster, self, mod2, {Duration = dur}) --[[Returns:void
		No Description Set
		]]

		target:CalculateStatBonus()

	end)

	local unit = FastDummy(target:GetAbsOrigin(),caster:GetTeam(),oog_dur+1,175)

	local p = ParticleManager:CreateParticle(part, PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
	Creates a new particle effect
	]]

	Timers:CreateTimer(oog_dur,function()
		ParticleManager:DestroyParticle(p,false)
		target:RemoveNoDraw()
	end)
end

-- Modifiers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_extraplanar_pact = class({})

function modifier_extraplanar_pact:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
	return func
end

function modifier_extraplanar_pact:GetEffectName()
	local part = "particles/units/heroes/hero_gemini/gemini_extraplanar_pact_unit.vpcf"

	return part
end

function modifier_extraplanar_pact:GetModifierBonusStats_Strength()
	local amt_main = self:GetAbility():GetSpecialValueFor("bonus_main_stat") --[[Returns:table
	No Description Set
	]]
	local amt_lesser = self:GetAbility():GetSpecialValueFor("bonus_secondary")
	if self:GetParent():GetPrimaryAttribute() == 0 then
		return amt_main
	end
	return amt_lesser
end

function modifier_extraplanar_pact:GetModifierBonusStats_Agility()
	local amt_main = self:GetAbility():GetSpecialValueFor("bonus_main_stat") --[[Returns:table
	No Description Set
	]]
	local amt_lesser = self:GetAbility():GetSpecialValueFor("bonus_secondary")
	if self:GetParent():GetPrimaryAttribute() == 1 then
		return amt_main
	end
	return amt_lesser
end

function modifier_extraplanar_pact:GetModifierBonusStats_Intellect()
	local amt_main = self:GetAbility():GetSpecialValueFor("bonus_main_stat") --[[Returns:table
	No Description Set
	]]
	local amt_lesser = self:GetAbility():GetSpecialValueFor("bonus_secondary")
	if self:GetParent():GetPrimaryAttribute() == 2 then
		return amt_main
	end
	return amt_lesser
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_extraplanar_pact_oog = class({})

function modifier_extraplanar_pact_oog:DeclareFunctions()
	local func = {

	}
	
	return func
end

function modifier_extraplanar_pact_oog:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}

	return state
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0.03
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target) -- CreateUnitByName uses only the x and y coordinates so we have to move it with SetAbsOrigin()
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
      Timers:CreateTimer(duration,function()
        if not dummy:IsNull() then
          print("=====================Destroying UNIT=====================")
          dummy:ForceKill(true)
          --dummy:Destroy()
          UTIL_Remove(dummy)
        else
          print("=====================UNIT is already REMOVED=====================")
        end
      end
      )
    
  end
  return dummy
end