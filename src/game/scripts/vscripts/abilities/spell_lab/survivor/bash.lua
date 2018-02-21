if spell_lab_survivor_bash == nil then
	spell_lab_survivor_bash = class({})
end

LinkLuaModifier("spell_lab_survivor_bash_modifier", "abilities/spell_lab/survivor/bash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )

function spell_lab_survivor_bash:GetIntrinsicModifierName() return "spell_lab_survivor_bash_modifier" end


if spell_lab_survivor_bash_modifier == nil then
	spell_lab_survivor_bash_modifier  = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_bash_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_bash_modifier:OnAttackLanded(keys)
		if IsServer() then
			local hAbility = self:GetAbility()
			if self:GetParent():PassivesDisabled() then return end
			if hAbility:GetLevel() < 1 then return end
			if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and hAbility:IsCooldownReady() then
					local chance = self:GetStackCount()
					if (math.random(0,100) > chance) then return end
	 	 			local stun_dur = hAbility:GetSpecialValueFor("duration")
					keys.target:AddNewModifier( self:GetCaster(), self, "generic_lua_stun", { duration = stun_dur , stacking = 0 } )
					EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "DOTA_Item.SkullBasher", self:GetParent() )
					hAbility:StartCooldown(hAbility:GetTrueCooldown(hAbility:GetLevel()))
			end
		end
--return self:GetStackCount()
end
