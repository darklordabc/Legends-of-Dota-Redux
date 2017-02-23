alchemist_aghnaim_magic_redux = class({})
LinkLuaModifier("modifier_alchemist_aghnaim_magic_redux", "abilities/alchemist_aghnaim_magic", LUA_MODIFIER_MOTION_NONE)


function alchemist_aghnaim_magic_redux:OnSpellStart()
 	local caster = self:GetCaster()
 	local ability = self
 	local target = self:GetCursorTarget()

 	local duration = ability:GetSpecialValueFor("duration")

 	target:AddNewModifier(caster, ability, "modifier_alchemist_aghnaim_magic_redux", {duration = duration}})
 end 



-- Aghnaim modifier
modifier_alchemist_aghnaim_magic_redux = class({})

function modifier_alchemist_aghnaim_magic_redux:IsDebuff()
	return false	
end

function modifier_alchemist_aghnaim_magic_redux:IsHidden()
	return false
end

function modifier_alchemist_aghnaim_magic_redux:IsPurgable()
	return true
end

function modifier_alchemist_aghnaim_magic_redux:DeclareFunctions()	
		local decFuncs = {MODIFIER_PROPERTY_IS_SCEPTER}
		
		return decFuncs	
end

function modifier_alchemist_aghnaim_magic_redux:GetModifierScepter()
	return 1
end