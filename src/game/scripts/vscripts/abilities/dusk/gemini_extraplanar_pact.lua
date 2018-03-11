gemini_extraplanar_pact = class({})

LinkLuaModifier("modifier_extraplanar_pact_oog","abilities/dusk/gemini_extraplanar_pact",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_extraplanar_pact","abilities/dusk/gemini_extraplanar_pact",LUA_MODIFIER_MOTION_NONE)

function gemini_extraplanar_pact:OnSpellStart()
	local mod = "modifier_extraplanar_pact_oog"
	local mod2 = "modifier_extraplanar_pact"

	local oog_dur = self:GetSpecialValueFor("out_of_game_duration")
	local dur = self:GetSpecialValueFor("duration")

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
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		-- MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK
	}
	return func
end

function modifier_extraplanar_pact:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_extraplanar_pact:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

-- function modifier_extraplanar_pact:GetModifierMagical_ConstantBlock()
	-- return self:GetAbility():GetSpecialValueFor("magic_block")
-- end

function modifier_extraplanar_pact:GetEffectName()
	local part = "particles/units/heroes/hero_gemini/gemini_extraplanar_pact_unit.vpcf"

	return part
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
