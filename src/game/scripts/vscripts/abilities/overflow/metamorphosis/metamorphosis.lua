if metamorphosis == nil then
	metamorphosis = class({})
end

LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "metamorphosis_mod", "abilities/overflow/metamorphosis/metamorphosis_mod.lua", LUA_MODIFIER_MOTION_NONE )

function metamorphosis:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	return behav
end

function metamorphosis:OnSpellStart()
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "RoshanDT.Scream", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "metamorphosis_mod", { duration = self:GetDuration() } )
end