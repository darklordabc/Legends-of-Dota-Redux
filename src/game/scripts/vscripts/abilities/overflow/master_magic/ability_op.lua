if master_magic_op == nil then
	master_magic_op = class({})
end

LinkLuaModifier( "master_magic_mod", "abilities/overflow/master_magic/modifier.lua", LUA_MODIFIER_MOTION_NONE )

function master_magic_op:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	return behav
end

function master_magic_op:OnSpellStart()
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Brewmaster_Storm.DispelMagic", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "master_magic_mod", { duration = self:GetSpecialValueFor("duration"), stacks= self:GetSpecialValueFor("stacks")})
end