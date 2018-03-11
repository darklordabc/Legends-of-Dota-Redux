alchemist_aghnaim_magic_redux = class({})
LinkLuaModifier("modifier_alchemist_aghnaim_magic_redux", "abilities/alchemist_aghnaim_magic", LUA_MODIFIER_MOTION_NONE)


function alchemist_aghnaim_magic_redux:OnSpellStart()
 	local caster = self:GetCaster()
 	local ability = self
 	local target = self:GetCursorTarget() 	
 	local sound_cast = "Hero_Alchemist.Scepter.Cast"

 	local duration = ability:GetSpecialValueFor("duration")

 	-- Play cast sound
 	EmitSoundOn(sound_cast, caster)

 	-- Apply scepter modifier
 	target:AddNewModifier(caster, ability, "modifier_alchemist_aghnaim_magic_redux", {duration = duration})
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

function modifier_alchemist_aghnaim_magic_redux:GetEffectName()
	return "particles/alchemist_aghnaim_magic_aghs.vpcf"	
end

function modifier_alchemist_aghnaim_magic_redux:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_alchemist_aghnaim_magic_redux:DeclareFunctions()	
		local decFuncs = {MODIFIER_PROPERTY_IS_SCEPTER}
		
		return decFuncs	
end

function modifier_alchemist_aghnaim_magic_redux:GetModifierScepter()
	return 1
end