if spell_reflect_op == nil then
	spell_reflect_op = class({})
end

LinkLuaModifier( "spell_reflect_mod", "abilities/overflow/spell_reflect/p_mod.lua", LUA_MODIFIER_MOTION_NONE )

function spell_reflect_op:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function spell_reflect_op:GetIntrinsicModifierName() return "spell_reflect_mod" end


function spell_reflect_op:GetCooldown( nLevel )
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	return cooldown
end
